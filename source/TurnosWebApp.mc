import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class TurnosWebApp extends Application.AppBase {

  function initialize() {
    AppBase.initialize();
  }

  function onStart(state as Dictionary or Null) as Void {
  }

  function onStop(state as Dictionary or Null) as Void {
  }

  function onSettingsChanged() as Void {
    WatchUi.requestUpdate();
    if (Credentials.hasAll()) {
      try {
        var cur = WatchUi.getCurrentView();
        if (cur != null && cur instanceof Lang.Array) {
          var arr = cur as Lang.Array;
          if (arr.size() > 0 && arr[0] instanceof ConfigureView) {
            AppController.openMainAfterLogin();
          }
        }
      } catch (ex) {
      }
    }
  }

  function getInitialView() {
    if (!Credentials.hasAll()) {
      return [ new ConfigureView(), new ConfigureDelegate() ];
    }
    return [ new WorkoutsView(), new WorkoutsDelegate() ];
  }
}
