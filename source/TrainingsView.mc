import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class TrainingsView extends WatchUi.View {
  var _loadingAnimation as LoadingAnimationController;

  function initialize() {
    View.initialize();
    _loadingAnimation = new LoadingAnimationController();
  }

  function onHide() as Void {
    _loadingAnimation.stop(self);
  }

  function onUpdate(dc as Graphics.Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();
    var h = dc.getHeight();

    RoundUi.drawMenuHint(dc);

    if (UiState.loading) {
      var lv = new LoadingView();
      lv.onUpdate(dc);
      _loadingAnimation.ensure(self, dc);
      return;
    }

    _loadingAnimation.stop(self);

    if (UiState.error != null) {
      RoundUi.drawCenteredLine(dc, h / 2, UiState.error, Graphics.FONT_SMALL, Graphics.COLOR_RED);
      return;
    }

    if (AppState.trainings.size() == 0) {
      RoundUi.drawCenteredLine(
        dc,
        h / 2,
        L10n.t(Rez.Strings.EmptyTrainings),
        Graphics.FONT_SMALL,
        Graphics.COLOR_LT_GRAY
      );
      return;
    }

    RoundUi.drawCenteredLine(
      dc,
      h / 2,
      L10n.t(Rez.Strings.TrainingsTitle),
      Graphics.FONT_SMALL,
      Graphics.COLOR_LT_GRAY
    );
  }
}

class TrainingsDelegate extends WatchUi.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
    AppController.setScreen(AppController.SCREEN_TRAININGS);
  }

  function onMenu() as Boolean {
    return MenuInput.handleMenuBehavior();
  }

  function onKey(evt as WatchUi.KeyEvent) as Boolean {
    return MenuInput.handleKey(evt);
  }

  function onBack() as Boolean {
    return NavHelper.handleBackFromLoadingTrainings();
  }
}
