import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.WatchUi;

// Layout helpers for round displays (e.g. fenix 7s, 240×240).
module RoundUi {
  const EDGE_MARGIN = 14;
  const MENU_HINT_X = 20;

  function drawMenuHint(dc as Graphics.Dc) as Void {
    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
    var cy = dc.getHeight() / 2;
    var x = MENU_HINT_X;
    dc.fillCircle(x, cy - 7, 2);
    dc.fillCircle(x, cy, 2);
    dc.fillCircle(x, cy + 7, 2);
  }

  function centerX(dc as Graphics.Dc) as Number {
    return dc.getWidth() / 2;
  }

  function centerY(dc as Graphics.Dc) as Number {
    return dc.getHeight() / 2;
  }

  function radius(dc as Graphics.Dc) as Number {
    var cy = centerY(dc);
    return cy - EDGE_MARGIN;
  }

  // Chord width of the circular screen at row Y (pixels).
  function maxWidthAtY(dc as Graphics.Dc, y as Number) as Number {
    var cy = centerY(dc);
    var r = radius(dc);
    var dy = y - cy;
    if (dy < 0) {
      dy = -dy;
    }
    if (dy >= r) {
      return 48;
    }
    var half = Math.sqrt(r * r - dy * dy).toNumber();
    var w = half * 2 - 20;
    if (w < 48) {
      w = 48;
    }
    return w;
  }

  (:typecheck(false))
  function wrapToWidth(
    dc as Graphics.Dc,
    text as String,
    font as Graphics.FontDefinition,
    maxWidth as Number
  ) as Lang.Array {
    if (text == null || text.length() == 0) {
      return [] as Lang.Array;
    }
    var lineH = dc.getFontHeight(font);
    var result = Graphics.fitTextToArea(text, font, maxWidth, lineH * 6, true);
    if (result == null) {
      return [] as Lang.Array;
    }
    if (result instanceof Lang.Array) {
      return result as Lang.Array;
    }
    if (result instanceof String) {
      return [result] as Lang.Array;
    }
    return [] as Lang.Array;
  }

  (:typecheck(false))
  function ellipsizeLine(
    dc as Graphics.Dc,
    text as String,
    font as Graphics.FontDefinition,
    maxWidth as Number
  ) as String {
    if (text.length() == 0) {
      return "";
    }
    var lineH = dc.getFontHeight(font);
    var result = Graphics.fitTextToArea(text, font, maxWidth, lineH, true);
    var lines = [] as Lang.Array;
    if (result instanceof Lang.Array) {
      lines = result as Lang.Array;
    } else if (result instanceof String) {
      lines = [result] as Lang.Array;
    }
    if (lines.size() == 0) {
      return text;
    }
    var line = lines[0];
    if (!(line instanceof String)) {
      return text;
    }
    var lineStr = line as String;
    if (lines.size() > 1 && lineStr.length() < text.length()) {
      if (lineStr.length() > 1) {
        return lineStr.substring(0, lineStr.length() - 1) + "…";
      }
    }
    return lineStr;
  }

  function drawCenteredLine(
    dc as Graphics.Dc,
    y as Number,
    text as String,
    font as Graphics.FontDefinition,
    color as Number
  ) as Void {
    if (text.length() == 0) {
      return;
    }
    dc.setColor(color, Graphics.COLOR_TRANSPARENT);
    var maxW = maxWidthAtY(dc, y);
    var line = ellipsizeLine(dc, text, font, maxW);
    dc.drawText(centerX(dc), y, font, line, Graphics.TEXT_JUSTIFY_CENTER);
  }

  function drawSelectionBar(
    dc as Graphics.Dc,
    x as Number,
    y as Number,
    rowH as Number,
    color as Number
  ) as Void {
    dc.setColor(color, Graphics.COLOR_TRANSPARENT);
    var barH = rowH - 8;
    if (barH < 8) {
      barH = 8;
    }
    dc.fillRectangle(x, y - barH / 2, 3, barH);
  }

  function drawClippedText(
    dc as Graphics.Dc,
    x as Number,
    y as Number,
    clipW as Number,
    rowH as Number,
    text as String,
    font as Graphics.FontDefinition,
    color as Number,
    xOffset as Number
  ) as Void {
    if (text.length() == 0 || clipW <= 0) {
      return;
    }
    dc.setColor(color, Graphics.COLOR_TRANSPARENT);
    var top = y - rowH / 2;
    if (top < 0) {
      top = 0;
    }
    dc.setClip(x, top, clipW, rowH);
    dc.drawText(
      x + xOffset,
      y,
      font,
      text,
      Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );
    dc.clearClip();
  }

  function textWidth(dc as Graphics.Dc, text as String, font as Graphics.FontDefinition) as Number {
    if (text.length() == 0) {
      return 0;
    }
    return dc.getTextWidthInPixels(text, font);
  }
}
