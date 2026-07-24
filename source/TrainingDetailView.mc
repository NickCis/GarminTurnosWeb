import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class TrainingDetailView extends WatchUi.View {

  var _linesKey as String = "";
  var _bodyTop as Number = 68;
  var _lineH as Number = 14;
  var _maxScrollOffset as Number = 0;
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

    RoundUi.drawMenuHint(dc);

    if (UiState.loading) {
      var lv = new LoadingView();
      lv.onUpdate(dc);
      _loadingAnimation.ensure(self, dc);
      return;
    }

    _loadingAnimation.stop(self);

    if (UiState.error != null) {
      RoundUi.drawCenteredLine(
        dc,
        RoundUi.centerY(dc),
        UiState.error,
        Graphics.FONT_SMALL,
        Graphics.COLOR_RED
      );
      return;
    }

    var titleMaxW = DetailTextLayout.maxWidthAt(dc, DetailUi.TITLE_TOP);
    _bodyTop = drawTitleBlock(dc, titleMaxW);
    var lines = getDisplayLines(dc, _bodyTop);
    _lineH = DetailTextLayout.lineHeight(dc);
    _maxScrollOffset = DetailTextLayout.maxScrollOffset(dc, lines.size(), _bodyTop, _lineH);

    if (AppState.scrollOffset > _maxScrollOffset) {
      AppState.scrollOffset = _maxScrollOffset;
    }

    var start = AppState.scrollOffset;
    var bodyBottom = dc.getHeight();
    var idx = start;

    while (idx < lines.size()) {
      var lineY = _bodyTop + (idx - start) * _lineH;
      if (lineY >= bodyBottom) {
        break;
      }
      var line = lines[idx];
      if (line instanceof String) {
        drawBodyLine(dc, line as String, lineY);
      }
      idx += 1;
    }
  }

  function drawBodyLine(dc as Graphics.Dc, text as String, y as Number) as Void {
    var textX = DetailTextLayout.textXAt(dc, y);
    var maxW = DetailTextLayout.maxWidthAt(dc, y);
    RoundUi.drawClippedText(
      dc,
      textX,
      y + _lineH / 2,
      maxW,
      _lineH,
      text,
      DetailUi.BODY_FONT,
      Graphics.COLOR_WHITE,
      0
    );
  }

  function drawTitleBlock(dc as Graphics.Dc, maxW as Number) as Number {
    if (AppState.detailTitle.length() == 0) {
      return DetailUi.TITLE_TOP;
    }
    var lineH = DetailTextLayout.titleLineHeight(dc);
    var titleLines = RoundUi.wrapTextLines(
      dc, AppState.detailTitle, DetailUi.TITLE_FONT, maxW, 2
    );
    var y = DetailUi.TITLE_TOP;
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    var cx = RoundUi.centerX(dc);
    for (var i = 0; i < titleLines.size(); i++) {
      var line = titleLines[i];
      if (line instanceof String) {
        dc.drawText(
          cx,
          y,
          DetailUi.TITLE_FONT,
          line as String,
          Graphics.TEXT_JUSTIFY_CENTER
        );
      }
      y += lineH;
    }
    return y + DetailUi.TITLE_BODY_GAP;
  }

  function getDisplayLines(dc as Graphics.Dc, bodyTop as Number) as Lang.Array {
    var key = AppState.detailTitle + "\n" + AppState.detailBody + "\n" + bodyTop.toString();
    if (key.equals(_linesKey) && AppState.detailLines.size() > 0) {
      return AppState.detailLines;
    }
    _linesKey = key;
    AppState.detailLines = DetailTextLayout.breakIntoVisualLines(dc, AppState.detailBody, bodyTop);
    return AppState.detailLines;
  }

  function scrollLine(delta as Number) as Void {
    var lines = AppState.detailLines;
    if (lines.size() == 0) {
      return;
    }
    var next = AppState.scrollOffset + delta;
    if (next < 0) {
      next = 0;
    }
    if (next > _maxScrollOffset) {
      next = _maxScrollOffset;
    }
    if (next != AppState.scrollOffset) {
      AppState.scrollOffset = next;
      WatchUi.requestUpdate();
    }
  }
}

class TrainingDetailDelegate extends WatchUi.BehaviorDelegate {

  var _view as TrainingDetailView;

  function initialize(view as TrainingDetailView) {
    BehaviorDelegate.initialize();
    _view = view;
    AppController.setScreen(AppController.SCREEN_DETAIL);
  }

  function onMenu() as Boolean {
    return MenuInput.handleMenuBehavior();
  }

  function onKey(evt as WatchUi.KeyEvent) as Boolean {
    if (MenuInput.handleKey(evt)) {
      return true;
    }
    var key = evt.getKey();
    if (key == WatchUi.KEY_DOWN) {
      _view.scrollLine(1);
      return true;
    }
    if (key == WatchUi.KEY_UP) {
      _view.scrollLine(-1);
      return true;
    }
    return false;
  }

  function onBack() as Boolean {
    return NavHelper.handleBackFromDetail();
  }

  function onUp() as Boolean {
    _view.scrollLine(-1);
    return true;
  }

  function onDown() as Boolean {
    _view.scrollLine(1);
    return true;
  }

  function onPreviousPage() as Boolean {
    _view.scrollLine(-1);
    return true;
  }

  function onNextPage() as Boolean {
    _view.scrollLine(1);
    return true;
  }
}
