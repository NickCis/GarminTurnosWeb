import Toybox.Lang;
import Toybox.WatchUi;

module AppController {
  const SCREEN_NONE = 0;
  const SCREEN_WORKOUTS = 1;
  const SCREEN_TRAININGS = 2;
  const SCREEN_DETAIL = 3;

  var currentScreen as Number = SCREEN_NONE;
  var _flows as FlowCoordinator or Null = null;

  function flows() as FlowCoordinator {
    if (_flows == null) {
      _flows = new FlowCoordinator();
    }
    return _flows;
  }

  function setScreen(screen as Number) as Void {
    currentScreen = screen;
  }

  function refreshCurrent() as Void {
    if (currentScreen == SCREEN_WORKOUTS) {
      flows().startWorkouts(true);
    } else if (currentScreen == SCREEN_TRAININGS) {
      flows().openTrainings(true);
    } else if (currentScreen == SCREEN_DETAIL) {
      flows().refreshDetail();
    }
  }

  function logout() as Void {
    SessionStore.clearSession();
    CacheStore.clearAllData();
    Credentials.clearStored();
    AppState.resetLists();
    UiState.setLoading(false);
    UiState.resetError();
    WatchUi.switchToView(new ConfigureView(), new ConfigureDelegate(), WatchUi.SLIDE_IMMEDIATE);
  }

  function openMainAfterLogin() as Void {
    AppState.resetLists();
    WatchUi.switchToView(new WorkoutsView(), new WorkoutsDelegate(), WatchUi.SLIDE_LEFT);
  }

  function loginFromConfigure() as Void {
    flows().loginFromConfigure();
  }

  function showAppMenu() as Void {
    if (UiState.loading) {
      return;
    }
    var menu = new AppMenu();
    WatchUi.pushView(menu, new AppMenuDelegate(), WatchUi.SLIDE_UP);
  }
}

class FlowCoordinator {

  function loginFromConfigure() as Void {
    if (!Credentials.hasAll()) {
      UiState.setError(L10n.t(Rez.Strings.ErrorMissingCredentials));
      WatchUi.requestUpdate();
      return;
    }
    UiState.setLoading(true);
    UiState.resetError();
    WatchUi.switchToView(new WorkoutsView(), new WorkoutsBootstrapDelegate(), WatchUi.SLIDE_LEFT);
    TurnosApi.login(method(:afterConfigureLogin));
  }

  function afterConfigureLogin(args as Lang.Array) as Void {
    if (!handleLoginResult(args)) {
      WatchUi.requestUpdate();
      return;
    }
    AppController.openMainAfterLogin();
  }

  function startWorkouts(forceRefresh as Boolean) as Void {
    AppController.setScreen(AppController.SCREEN_WORKOUTS);
    if (!SessionStore.hasSession()) {
      UiState.setError(L10n.t(Rez.Strings.ErrorNoSession));
      WatchUi.requestUpdate();
      return;
    }
    UiState.setLoading(true);
    WatchUi.requestUpdate();
    fetchPanel();
  }

  function openTrainings(forceRefresh as Boolean) as Void {
    AppController.setScreen(AppController.SCREEN_TRAININGS);
    if (AppState.selectedWorkout == null) {
      return;
    }
    if (!SessionStore.hasSession()) {
      UiState.setError(L10n.t(Rez.Strings.ErrorNoSession));
      WatchUi.requestUpdate();
      return;
    }
    var wid = AppState.workoutId(AppState.selectedWorkout);
    if (forceRefresh) {
      UiState.setLoading(true);
      WatchUi.requestUpdate();
      fetchTrainings();
      return;
    }
    var cached = CacheStore.getTrainings(wid);
    if (cached != null && cached.size() > 0) {
        AppState.trainings = cached;
        UiState.setReady(true);
        WatchUi.requestUpdate();
      ItemListFactory.pushTrainingsList();
      return;
    }
    AppState.trainings = [] as Lang.Array;
    AppState.selectedTraining = null;
    WatchUi.pushView(new TrainingsView(), new TrainingsDelegate(), WatchUi.SLIDE_LEFT);
    UiState.setLoading(true);
    WatchUi.requestUpdate();
    fetchTrainings();
  }

  function openDetail(forceRefresh as Boolean) as Void {
    AppController.setScreen(AppController.SCREEN_DETAIL);
    if (AppState.selectedTraining == null) {
      return;
    }
    if (!SessionStore.hasSession()) {
      UiState.setError(L10n.t(Rez.Strings.ErrorNoSession));
      WatchUi.requestUpdate();
      return;
    }
    var tid = AppState.trainingId(AppState.selectedTraining);
    if (!forceRefresh) {
      var cached = CacheStore.getPlani(tid);
      if (cached != null) {
        applyPlaniItem(cached, true);
        var detailView = new TrainingDetailView();
        WatchUi.pushView(detailView, new TrainingDetailDelegate(detailView), WatchUi.SLIDE_LEFT);
        return;
      }
    }
    var detail = new TrainingDetailView();
    WatchUi.pushView(detail, new TrainingDetailDelegate(detail), WatchUi.SLIDE_LEFT);
    UiState.setLoading(true);
    WatchUi.requestUpdate();
    fetchPlani();
  }

  function refreshDetail() as Void {
    AppController.setScreen(AppController.SCREEN_DETAIL);
    if (AppState.selectedTraining == null) {
      return;
    }
    if (!SessionStore.hasSession()) {
      UiState.setError(L10n.t(Rez.Strings.ErrorNoSession));
      WatchUi.requestUpdate();
      return;
    }
    AppState.detailLines = [] as Lang.Array;
    AppState.scrollOffset = 0;
    UiState.setLoading(true);
    WatchUi.requestUpdate();
    fetchPlani();
  }

  function handleLoginResult(args as Lang.Array) as Boolean {
    var ok = args[0] as Boolean;
    var data = args[1];
    var code = args[2] as Number;
    if (!ok || data == null || !(data instanceof Lang.Dictionary)) {
      handleLoginFailure(code, data);
      return false;
    }
    var d = data as Lang.Dictionary;
    if (!TurnosApi.loginOk(d) || !TurnosApi.parseCk(d)) {
      var err = TurnosApi.loginError(d);
      if (err.length() == 0) {
        err = L10n.t(Rez.Strings.ErrorLoginNoSession);
      }
      UiState.setError(L10n.tf(Rez.Strings.ErrorLoginFailed, [err] as Lang.Array));
      WatchUi.requestUpdate();
      return false;
    }
    return true;
  }

  function handleLoginFailure(code as Number, data as Lang.Object or Null) as Void {
    if (code < 0) {
      UiState.setError(L10n.tf(Rez.Strings.ErrorNetwork, [HttpDebug.communicationsErrorLabel(code)] as Lang.Array));
    } else if (data instanceof Lang.Dictionary) {
      var err = TurnosApi.loginError(data as Lang.Dictionary);
      UiState.setError(L10n.tf(Rez.Strings.ErrorLoginWithDetail, [code.toString(), err] as Lang.Array));
    } else {
      UiState.setError(L10n.tf(Rez.Strings.ErrorLoginHttp, [code.toString()] as Lang.Array));
    }
    WatchUi.requestUpdate();
  }

  function fetchPanel() as Void {
    TurnosApi.panelMensajes(method(:afterPanel));
  }

  function afterPanel(args as Lang.Array) as Void {
    var ok = args[0] as Boolean;
    var data = args[1];
    var code = args[2] as Number;
    var cached = CacheStore.getPanel();
    if (ok && data != null && data instanceof Lang.Dictionary) {
      var workouts = TurnosApi.extractWorkouts(data as Lang.Dictionary);
      if (workouts != null && workouts.size() > 0) {
        workouts = AppState.workoutsWithCleanLabels(workouts);
        CacheStore.savePanel(workouts);
        CacheStore.pruneTrainingsForWorkouts(workouts);
        AppState.workouts = workouts;
        UiState.setReady(false);
        WatchUi.requestUpdate();
        openWorkoutsMenu();
        return;
      }
    }
    if (cached != null && cached.size() > 0) {
      AppState.workouts = AppState.workoutsWithCleanLabels(cached);
      UiState.setReady(true);
      WatchUi.requestUpdate();
      openWorkoutsMenu();
      return;
    }
    if (!ok) {
      if (code < 0) {
        UiState.setError(L10n.t(Rez.Strings.ErrorOfflineNoCache));
      } else {
        UiState.setError(L10n.tf(Rez.Strings.ErrorDataHttp, [code.toString()] as Lang.Array));
      }
    } else {
      UiState.setError(L10n.t(Rez.Strings.ErrorNoWorkouts));
    }
    WatchUi.requestUpdate();
  }

  function fetchTrainings() as Void {
    if (AppState.selectedWorkout == null) {
      return;
    }
    var wid = AppState.workoutId(AppState.selectedWorkout);
    TurnosApi.listTraining(wid, method(:afterTrainings));
  }

  function afterTrainings(args as Lang.Array) as Void {
    var ok = args[0] as Boolean;
    var data = args[1];
    var code = args[2] as Number;
    var wid = AppState.selectedWorkout != null ? AppState.workoutId(AppState.selectedWorkout) : "";
    var cached = wid.length() > 0 ? CacheStore.getTrainings(wid) : null;
    if (ok && data != null && data instanceof Lang.Dictionary) {
      var list = TurnosApi.extractTrainings(data as Lang.Dictionary);
      if (list != null && list.size() > 0) {
        CacheStore.saveTrainings(wid, list);
        CacheStore.prunePlaniForTrainings(list);
        AppState.trainings = list;
        UiState.setReady(false);
        WatchUi.requestUpdate();
        openTrainingsMenu();
        return;
      }
    }
    if (cached != null && cached.size() > 0) {
      AppState.trainings = cached;
      UiState.setReady(true);
      WatchUi.requestUpdate();
      openTrainingsMenu();
      return;
    }
    if (!ok) {
      if (code < 0) {
        UiState.setError(L10n.t(Rez.Strings.ErrorOfflineNoCache));
      } else {
        UiState.setError(L10n.tf(Rez.Strings.ErrorDataHttp, [code.toString()] as Lang.Array));
      }
    } else {
      UiState.setError(L10n.t(Rez.Strings.ErrorNoTrainings));
    }
    WatchUi.requestUpdate();
  }

  function fetchPlani() as Void {
    if (AppState.selectedTraining == null) {
      return;
    }
    var tr = AppState.selectedTraining;
    var tid = AppState.trainingId(tr);
    var wod = AppState.dictString(tr, "wod");
    var tipoWod = AppState.dictString(tr, "tipo_wod");
    TurnosApi.getPlani(tid, wod, tipoWod, method(:afterPlani));
  }

  function afterPlani(args as Lang.Array) as Void {
    var ok = args[0] as Boolean;
    var data = args[1];
    var tid = AppState.selectedTraining != null ? AppState.trainingId(AppState.selectedTraining) : "";
    var cached = tid.length() > 0 ? CacheStore.getPlani(tid) : null;
    if (ok && data != null && data instanceof Lang.Dictionary) {
      var item = TurnosApi.extractPlaniItem(data as Lang.Dictionary, tid);
      if (item != null) {
        applyPlaniItem(item, false);
        return;
      }
    }
    if (cached != null) {
      applyPlaniItem(cached, true);
      return;
    }
    if (!ok) {
      UiState.setError(L10n.t(Rez.Strings.ErrorOfflineNoCache));
    } else {
      UiState.setError(L10n.t(Rez.Strings.ErrorNoDetail));
    }
    WatchUi.requestUpdate();
  }

  function applyPlaniItem(item as Lang.Dictionary, cached as Boolean) as Void {
    var tid = AppState.dictString(item, "id");
    if (tid.length() == 0 && AppState.selectedTraining != null) {
      tid = AppState.trainingId(AppState.selectedTraining);
    }
    AppState.detailTitle = AppState.dictString(item, "titulo");
    var body = HtmlUtil.cleanHtml(AppState.dictString(item, "detalle"));
    AppState.detailBody = body;
    AppState.detailLines = [] as Lang.Array;
    AppState.scrollOffset = 0;
    var stored = {
      "id" => tid,
      "titulo" => AppState.detailTitle,
      "detalle" => body
    };
    CacheStore.savePlani(tid, stored);
    UiState.setReady(false);
    WatchUi.requestUpdate();
  }

  function openWorkoutsMenu() as Void {
    ItemListFactory.openWorkoutsList();
  }

  function openTrainingsMenu() as Void {
    ItemListFactory.replaceLoadingWithTrainingsList();
  }
}
