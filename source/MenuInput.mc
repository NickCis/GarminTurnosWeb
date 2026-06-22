import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

module MenuInput {
  var _lastUpMs as Number = 0;

  function markUpPress() as Void {
    _lastUpMs = System.getTimer();
  }

  function undoSpuriousUpScroll(undoFn as Method) as Void {
    if (_lastUpMs > 0 && System.getTimer() - _lastUpMs < 450) {
      undoFn.invoke(null);
    }
  }

  function showMenu() as Boolean {
    AppController.showAppMenu();
    return true;
  }

  function handleMenuBehavior() as Boolean {
    return showMenu();
  }

  function handleKey(evt as WatchUi.KeyEvent) as Boolean {
    if (evt.getKey() == WatchUi.KEY_MENU) {
      return showMenu();
    }
    return false;
  }
}

module NavHelper {
  const LIST_WORKOUTS = 1;
  const LIST_TRAININGS = 2;

  function handleBackFromList(listKind as Number) as Boolean {
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
    if (listKind == LIST_TRAININGS) {
      AppController.setScreen(AppController.SCREEN_WORKOUTS);
    }
    return true;
  }

  function handleBackFromDetail() as Boolean {
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
    AppController.setScreen(AppController.SCREEN_TRAININGS);
    return true;
  }

  function handleBackFromLoadingTrainings() as Boolean {
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
    AppController.setScreen(AppController.SCREEN_WORKOUTS);
    return true;
  }
}
