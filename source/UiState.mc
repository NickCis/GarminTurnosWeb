import Toybox.Lang;

module UiState {
  var loading as Boolean = false;
  var error as String or Null = null;
  var fromCache as Boolean = false;

  function resetError() as Void {
    error = null;
  }

  function setError(msg as String) as Void {
    error = msg;
    loading = false;
    fromCache = false;
  }

  function setLoading(v as Boolean) as Void {
    loading = v;
    if (v) {
      error = null;
      fromCache = false;
    }
  }

  function setReady(cached as Boolean) as Void {
    loading = false;
    error = null;
    fromCache = cached;
  }
}

module AppState {
  var workouts as Lang.Array = [] as Lang.Array;
  var trainings as Lang.Array = [] as Lang.Array;
  var selectedWorkout as Lang.Dictionary or Null = null;
  var selectedTraining as Lang.Dictionary or Null = null;
  var detailTitle as String = "";
  var detailBody as String = "";
  var detailLines as Lang.Array = [] as Lang.Array;
  var scrollOffset as Number = 0;

  function resetLists() as Void {
    workouts = [] as Lang.Array;
    trainings = [] as Lang.Array;
    selectedWorkout = null;
    selectedTraining = null;
    detailTitle = "";
    detailBody = "";
    detailLines = [] as Lang.Array;
    scrollOffset = 0;
  }

  function workoutId(item as Lang.Dictionary) as String {
    return dictString(item, "id");
  }

  function workoutLabel(item as Lang.Dictionary) as String {
    return HtmlUtil.cleanHtml(dictString(item, "detalle"));
  }

  function workoutsWithCleanLabels(source as Lang.Array) as Lang.Array {
    var out = [] as Lang.Array;
    for (var i = 0; i < source.size(); i++) {
      var item = source[i];
      if (item instanceof Lang.Dictionary) {
        var d = item as Lang.Dictionary;
        out.add({
          "id" => dictString(d, "id"),
          "detalle" => HtmlUtil.cleanHtml(dictString(d, "detalle"))
        });
      }
    }
    return out;
  }

  function trainingLabel(item as Lang.Dictionary) as String {
    var fecha = dictString(item, "fecha");
    var titulo = dictString(item, "titulo");
    return L10n.tf(Rez.Strings.TrainingLineFormat, [fecha, titulo] as Lang.Array);
  }

  function trainingId(item as Lang.Dictionary) as String {
    return dictString(item, "id");
  }

  function dictString(d as Lang.Dictionary, key as String) as String {
    var v = d.get(key);
    if (v == null) {
      return "";
    }
    if (v instanceof String) {
      return v as String;
    }
    return v.toString();
  }
}
