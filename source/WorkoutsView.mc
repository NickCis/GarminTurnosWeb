import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class WorkoutsView extends WatchUi.View {

  function initialize() {
    View.initialize();
  }

  function onShow() as Void {
    WatchUi.requestUpdate();
  }

  function onUpdate(dc as Graphics.Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();
    var h = dc.getHeight();

    RoundUi.drawMenuHint(dc);

    if (UiState.loading) {
      var lv = new LoadingView();
      lv.onUpdate(dc);
      return;
    }

    if (UiState.error != null) {
      dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
      RoundUi.drawCenteredLine(dc, h / 2, UiState.error, Graphics.FONT_SMALL, Graphics.COLOR_RED);
      return;
    }

    if (AppState.workouts.size() == 0) {
      RoundUi.drawCenteredLine(
        dc,
        h / 2,
        L10n.t(Rez.Strings.EmptyWorkouts),
        Graphics.FONT_SMALL,
        Graphics.COLOR_LT_GRAY
      );
      return;
    }

    RoundUi.drawCenteredLine(
      dc,
      h / 2,
      L10n.t(Rez.Strings.WorkoutsTitle),
      Graphics.FONT_SMALL,
      Graphics.COLOR_LT_GRAY
    );
  }
}

class WorkoutsDelegate extends WatchUi.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
    AppController.setScreen(AppController.SCREEN_WORKOUTS);
    AppController.flows().startWorkouts(false);
  }

  function onMenu() as Boolean {
    return MenuInput.handleMenuBehavior();
  }

  function onKey(evt as WatchUi.KeyEvent) as Boolean {
    return MenuInput.handleKey(evt);
  }

  function onBack() as Boolean {
    return false;
  }
}

class WorkoutsBootstrapDelegate extends WatchUi.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
    AppController.setScreen(AppController.SCREEN_WORKOUTS);
  }

  function onMenu() as Boolean {
    return MenuInput.handleMenuBehavior();
  }

  function onKey(evt as WatchUi.KeyEvent) as Boolean {
    return MenuInput.handleKey(evt);
  }

  function onBack() as Boolean {
    if (!SessionStore.hasSession()) {
      UiState.setLoading(false);
      UiState.resetError();
      WatchUi.switchToView(new ConfigureView(), new ConfigureDelegate(), WatchUi.SLIDE_RIGHT);
      return true;
    }
    return false;
  }
}
