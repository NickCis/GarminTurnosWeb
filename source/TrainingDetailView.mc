import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

module DetailUi {
  const LINES_PER_PAGE = 5;
}

class TrainingDetailView extends WatchUi.View {

  var _linesCacheKey as String = "";

  function initialize() {
    View.initialize();
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
      RoundUi.drawCenteredLine(dc, h / 2, UiState.error, Graphics.FONT_SMALL, Graphics.COLOR_RED);
      return;
    }

    var titleY = 40;
    if (AppState.detailTitle.length() > 0) {
      RoundUi.drawCenteredLine(
        dc,
        titleY,
        AppState.detailTitle,
        Graphics.FONT_SMALL,
        Graphics.COLOR_WHITE
      );
    }

    var lines = getDisplayLines(dc);
    var start = AppState.scrollOffset;
    var rowH = dc.getFontHeight(Graphics.FONT_XTINY) + 4;
    var y = 68;
    for (var i = 0; i < DetailUi.LINES_PER_PAGE; i++) {
      var idx = start + i;
      if (idx >= lines.size()) {
        break;
      }
      var line = lines[idx];
      if (line instanceof String) {
        RoundUi.drawCenteredLine(
          dc,
          y,
          line as String,
          Graphics.FONT_XTINY,
          Graphics.COLOR_WHITE
        );
      }
      y += rowH;
    }

    var hasMore = start + DetailUi.LINES_PER_PAGE < lines.size();
    if (hasMore) {
      var dotsY = h - (UiState.fromCache ? 34 : 22);
      RoundUi.drawCenteredLine(dc, dotsY, "...", Graphics.FONT_SMALL, Graphics.COLOR_LT_GRAY);
    }

    if (UiState.fromCache) {
      RoundUi.drawCenteredLine(
        dc,
        h - 20,
        L10n.t(Rez.Strings.CachedData),
        Graphics.FONT_XTINY,
        Graphics.COLOR_YELLOW
      );
    }
  }

  function getDisplayLines(dc as Graphics.Dc) as Lang.Array {
    var key = AppState.detailBody;
    if (!_linesCacheKey.equals(key)) {
      _linesCacheKey = key;
      AppState.detailLines = buildDisplayLines(dc, key);
      if (AppState.scrollOffset >= AppState.detailLines.size()) {
        AppState.scrollOffset = 0;
      }
    }
    return AppState.detailLines;
  }

  (:typecheck(false))
  function buildDisplayLines(dc as Graphics.Dc, text as String) as Lang.Array {
    var out = [] as Lang.Array;
    if (text.length() == 0) {
      return out;
    }
    var paragraphs = splitParagraphs(text);
    for (var p = 0; p < paragraphs.size(); p++) {
      var para = paragraphs[p];
      if (!(para instanceof String)) {
        continue;
      }
      var paraText = para as String;
      if (paraText.length() == 0) {
        continue;
      }
      var y = 68 + out.size() * (dc.getFontHeight(Graphics.FONT_XTINY) + 4);
      var maxW = RoundUi.maxWidthAtY(dc, y);
      var lineH = dc.getFontHeight(Graphics.FONT_XTINY);
      var wrapped = Graphics.fitTextToArea(paraText, Graphics.FONT_XTINY, maxW, lineH * 8, false);
      if (wrapped == null) {
        continue;
      }
      if (wrapped instanceof Lang.Array) {
        var arr = wrapped as Lang.Array;
        for (var w = 0; w < arr.size(); w++) {
          out.add(arr[w]);
        }
      } else if (wrapped instanceof String) {
        out.add(wrapped);
      }
    }
    return out;
  }

  function splitParagraphs(text as String) as Lang.Array {
    var lines = [] as Lang.Array;
    var cur = "";
    var n = text.length();
    for (var i = 0; i < n; i++) {
      var ch = text.substring(i, i + 1);
      if (ch.equals("\n")) {
        lines.add(cur);
        cur = "";
      } else {
        cur += ch;
      }
    }
    lines.add(cur);
    return lines;
  }
}

class TrainingDetailDelegate extends WatchUi.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
    AppController.setScreen(AppController.SCREEN_DETAIL);
  }

  function onMenu() as Boolean {
    MenuInput.undoSpuriousUpScroll(method(:undoUpScroll));
    return MenuInput.handleMenuBehavior();
  }

  function undoUpScroll(_ as Lang.Object or Null) as Void {
    scrollBy(1);
  }

  function onKey(evt as WatchUi.KeyEvent) as Boolean {
    return MenuInput.handleKey(evt);
  }

  function onBack() as Boolean {
    return NavHelper.handleBackFromDetail();
  }

  function onNextPage() as Boolean {
    scrollBy(DetailUi.LINES_PER_PAGE);
    return true;
  }

  function onPreviousPage() as Boolean {
    MenuInput.markUpPress();
    scrollBy(-DetailUi.LINES_PER_PAGE);
    return true;
  }

  function onUp() as Boolean {
    MenuInput.markUpPress();
    scrollBy(-1);
    return true;
  }

  function onDown() as Boolean {
    scrollBy(1);
    return true;
  }

  function scrollBy(delta as Number) as Void {
    var lines = AppState.detailLines;
    if (lines.size() == 0) {
      return;
    }
    var maxOffset = lines.size() - 1;
    if (maxOffset < 0) {
      maxOffset = 0;
    }
    var next = AppState.scrollOffset + delta;
    if (next < 0) {
      next = 0;
    }
    if (next > maxOffset) {
      next = maxOffset;
    }
    AppState.scrollOffset = next;
    WatchUi.requestUpdate();
  }
}
