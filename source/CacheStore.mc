import Toybox.Application.Storage;
import Toybox.Lang;

module CacheStore {
  const KEY_PANEL = "cache_panel";
  const KEY_LIST_PREFIX = "cache_list_";
  const KEY_PLANI_PREFIX = "cache_plani_";
  const KEY_LIST_INDEX = "cache_list_index";
  const KEY_PLANI_INDEX = "cache_plani_index";

  function clearAllData() as Void {
    safeDel(KEY_PANEL);
    var listIds = getIdIndex(KEY_LIST_INDEX);
    for (var i = 0; i < listIds.size(); i++) {
      var wid = listIds[i];
      if (wid instanceof String) {
        safeDel(KEY_LIST_PREFIX + (wid as String));
      }
    }
    safeDel(KEY_LIST_INDEX);
    var planiIds = getIdIndex(KEY_PLANI_INDEX);
    for (var j = 0; j < planiIds.size(); j++) {
      var tid = planiIds[j];
      if (tid instanceof String) {
        safeDel(KEY_PLANI_PREFIX + (tid as String));
      }
    }
    safeDel(KEY_PLANI_INDEX);
  }

  function savePanel(data as Lang.Array) as Void {
    Storage.setValue(KEY_PANEL, data);
  }

  function getPanel() as Lang.Array or Null {
    return getArray(KEY_PANEL);
  }

  function saveTrainings(workoutId as String, data as Lang.Array) as Void {
    if (workoutId.length() == 0) {
      return;
    }
    Storage.setValue(KEY_LIST_PREFIX + workoutId, data);
    addToIndex(KEY_LIST_INDEX, workoutId);
  }

  function getTrainings(workoutId as String) as Lang.Array or Null {
    if (workoutId.length() == 0) {
      return null;
    }
    return getArray(KEY_LIST_PREFIX + workoutId);
  }

  function savePlani(trainingId as String, data as Lang.Dictionary) as Void {
    if (trainingId.length() == 0) {
      return;
    }
    Storage.setValue(KEY_PLANI_PREFIX + trainingId, data);
    addToIndex(KEY_PLANI_INDEX, trainingId);
  }

  function getPlani(trainingId as String) as Lang.Dictionary or Null {
    if (trainingId.length() == 0) {
      return null;
    }
    try {
      var v = Storage.getValue(KEY_PLANI_PREFIX + trainingId);
      if (v != null && v instanceof Lang.Dictionary) {
        return v as Lang.Dictionary;
      }
    } catch (ex) {
    }
    return null;
  }

  function pruneTrainingsForWorkouts(workouts as Lang.Array) as Void {
    var valid = workoutIdSet(workouts);
    var ids = getIdIndex(KEY_LIST_INDEX);
    var kept = [] as Lang.Array;
    for (var i = 0; i < ids.size(); i++) {
      var raw = ids[i];
      if (!(raw instanceof String)) {
        continue;
      }
      var wid = raw as String;
      if (valid.get(wid) != null) {
        kept.add(wid);
      } else {
        safeDel(KEY_LIST_PREFIX + wid);
      }
    }
    Storage.setValue(KEY_LIST_INDEX, kept);
  }

  function prunePlaniForTrainings(trainings as Lang.Array) as Void {
    var valid = trainingIdSet(trainings);
    var ids = getIdIndex(KEY_PLANI_INDEX);
    var kept = [] as Lang.Array;
    for (var i = 0; i < ids.size(); i++) {
      var raw = ids[i];
      if (!(raw instanceof String)) {
        continue;
      }
      var tid = raw as String;
      if (valid.get(tid) != null) {
        kept.add(tid);
      } else {
        safeDel(KEY_PLANI_PREFIX + tid);
      }
    }
    Storage.setValue(KEY_PLANI_INDEX, kept);
  }

  function workoutIdSet(workouts as Lang.Array) as Lang.Dictionary {
    var out = {} as Lang.Dictionary;
    for (var i = 0; i < workouts.size(); i++) {
      var item = workouts[i];
      if (item instanceof Lang.Dictionary) {
        var id = AppState.workoutId(item as Lang.Dictionary);
        if (id.length() > 0) {
          out.put(id, true);
        }
      }
    }
    return out;
  }

  function trainingIdSet(trainings as Lang.Array) as Lang.Dictionary {
    var out = {} as Lang.Dictionary;
    for (var i = 0; i < trainings.size(); i++) {
      var item = trainings[i];
      if (item instanceof Lang.Dictionary) {
        var id = AppState.trainingId(item as Lang.Dictionary);
        if (id.length() > 0) {
          out.put(id, true);
        }
      }
    }
    return out;
  }

  function getIdIndex(key as String) as Lang.Array {
    var arr = getArray(key);
    if (arr != null) {
      return arr;
    }
    return [] as Lang.Array;
  }

  function addToIndex(indexKey as String, id as String) as Void {
    var ids = getIdIndex(indexKey);
    for (var i = 0; i < ids.size(); i++) {
      var existing = ids[i];
      if (existing instanceof String && (existing as String).equals(id)) {
        return;
      }
    }
    ids.add(id);
    Storage.setValue(indexKey, ids);
  }

  function getArray(key as String) as Lang.Array or Null {
    try {
      var v = Storage.getValue(key);
      if (v != null && v instanceof Lang.Array) {
        return v as Lang.Array;
      }
    } catch (ex) {
    }
    return null;
  }

  function safeDel(key as String) as Void {
    try {
      Storage.deleteValue(key);
    } catch (e) {
    }
  }
}
