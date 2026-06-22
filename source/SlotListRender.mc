import Toybox.Graphics;
import Toybox.Lang;

module SlotListRender {
  const VISIBLE_ROWS = 3;
  const CENTER_ROW = 1;
  const BAR_GAP = 6;
  const BAR_WIDTH = 3;
  const TEXT_LEFT = 42;
  const KIND_HEADER = "header";

  function headerEntry(text as String) as Lang.Dictionary {
    return { "kind" => KIND_HEADER, "text" => text, "subtitle" => "" };
  }

  function itemEntry(text as String, subtitle as String) as Lang.Dictionary {
    return { "kind" => "item", "text" => text, "subtitle" => subtitle };
  }

  function isHeader(entry as Lang.Dictionary) as Boolean {
    var k = entry.get("kind");
    return k != null && k instanceof String && (k as String).equals(KIND_HEADER);
  }

  function rowHeight(dc as Graphics.Dc) as Number {
    return dc.getHeight() / 3;
  }

  function slotCenterY(dc as Graphics.Dc, slot as Number) as Number {
    var rh = rowHeight(dc);
    return rh * slot + rh / 2;
  }

  function drawSlots(
    dc as Graphics.Dc,
    entries as Lang.Array,
    centerIndex as Number,
    offsetY as Number
  ) as Void {
    var rh = rowHeight(dc);
    var w = dc.getWidth();

    for (var slot = 0; slot < VISIBLE_ROWS; slot++) {
      var entryIdx = centerIndex + slot - CENTER_ROW;
      if (entryIdx < 0 || entryIdx >= entries.size()) {
        continue;
      }
      var entry = entries[entryIdx];
      if (!(entry instanceof Lang.Dictionary)) {
        continue;
      }
      var e = entry as Lang.Dictionary;
      var y = slotCenterY(dc, slot) + offsetY;
      if (isHeader(e)) {
        drawHeaderSlot(dc, y, entryText(e), rh);
      } else {
        drawItemSlot(dc, y, entryText(e), entrySubtitle(e), rh, w);
      }
    }

    drawFixedBar(dc, rh, entries, centerIndex);
  }

  function entryText(entry as Lang.Dictionary) as String {
    var t = entry.get("text");
    if (t instanceof String) {
      return t as String;
    }
    return t != null ? t.toString() : "";
  }

  function entrySubtitle(entry as Lang.Dictionary) as String {
    var sub = entry.get("subtitle");
    if (sub instanceof String) {
      return sub as String;
    }
    return "";
  }

  function drawFixedBar(
    dc as Graphics.Dc,
    slotH as Number,
    entries as Lang.Array,
    centerIndex as Number
  ) as Void {
    if (centerIndex < 0 || centerIndex >= entries.size()) {
      return;
    }
    var entry = entries[centerIndex];
    if (!(entry instanceof Lang.Dictionary)) {
      return;
    }
    if (isHeader(entry as Lang.Dictionary)) {
      return;
    }
    var fixedY = slotCenterY(dc, CENTER_ROW);
    drawBar(dc, TEXT_LEFT - BAR_GAP - BAR_WIDTH, fixedY, slotH);
  }

  function drawHeaderSlot(
    dc as Graphics.Dc,
    y as Number,
    text as String,
    slotH as Number
  ) as Void {
    var cx = dc.getWidth() / 2;
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    var fontH = dc.getFontHeight(Graphics.FONT_SMALL);
    var textY = y - fontH / 2 - 4;
    dc.drawText(cx, textY, Graphics.FONT_SMALL, text, Graphics.TEXT_JUSTIFY_CENTER);

    var lineY = textY + fontH + 8;
    var lineW = dc.getWidth() * 2 / 3;
    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
    dc.drawLine(cx - lineW / 2, lineY, cx + lineW / 2, lineY);
  }

  function drawItemSlot(
    dc as Graphics.Dc,
    y as Number,
    title as String,
    subtitle as String,
    slotH as Number,
    w as Number
  ) as Void {
    var textX = TEXT_LEFT;
    var clipW = w - textX - 16;
    if (subtitle.length() == 0) {
      drawWrappedInSlot(dc, textX, y, clipW, slotH, title, Graphics.FONT_SMALL, Graphics.COLOR_WHITE);
      return;
    }

    var tituloFont = Graphics.FONT_SMALL;
    var fechaFont = Graphics.FONT_XTINY;
    var tituloLineH = dc.getFontHeight(tituloFont) + 2;
    var dateY = y + dc.getFontHeight(tituloFont) / 2 + 2;
    var slotTop = y - slotH / 2;

    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      textX,
      dateY,
      fechaFont,
      subtitle,
      Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );

    var titleBottom = dateY - dc.getFontHeight(fechaFont) / 2 - 4;
    var titleAreaTop = slotTop + 6;
    var titleAreaH = titleBottom - titleAreaTop;
    if (titleAreaH < tituloLineH) {
      titleAreaH = tituloLineH;
    }
    var maxTitleLines = titleAreaH / tituloLineH;
    if (maxTitleLines < 1) {
      maxTitleLines = 1;
    }
    var titleLines = RoundUi.wrapTextLines(dc, title, tituloFont, clipW, maxTitleLines);
    if (titleLines.size() == 0) {
      return;
    }
    var titleBlockH = titleLines.size() * tituloLineH;
    var titleStartY = titleBottom - titleBlockH;

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    for (var i = 0; i < titleLines.size(); i++) {
      var line = titleLines[i];
      if (line instanceof String) {
        dc.drawText(
          textX,
          titleStartY + i * tituloLineH,
          tituloFont,
          line as String,
          Graphics.TEXT_JUSTIFY_LEFT
        );
      }
    }
  }

  function drawWrappedInSlot(
    dc as Graphics.Dc,
    x as Number,
    y as Number,
    clipW as Number,
    slotH as Number,
    text as String,
    font as Graphics.FontDefinition,
    color as Number
  ) as Void {
    if (text.length() == 0 || clipW <= 0) {
      return;
    }
    var lineH = dc.getFontHeight(font) + 2;
    var maxLines = slotH / lineH;
    if (maxLines < 1) {
      maxLines = 1;
    }
    var lines = RoundUi.wrapTextLines(dc, text, font, clipW, maxLines);
    if (lines.size() == 0) {
      return;
    }
    var blockH = lines.size() * lineH;
    var slotTop = y - slotH / 2 + 4;
    var slotBottom = y + slotH / 2 - 4;
    var startY = y - blockH / 2;
    if (startY < slotTop) {
      startY = slotTop;
    }
    if (startY + blockH > slotBottom) {
      startY = slotBottom - blockH;
    }
    if (startY < slotTop) {
      startY = slotTop;
    }

    dc.setColor(color, Graphics.COLOR_TRANSPARENT);
    for (var i = 0; i < lines.size(); i++) {
      var line = lines[i];
      if (line instanceof String) {
        dc.drawText(
          x,
          startY + i * lineH,
          font,
          line as String,
          Graphics.TEXT_JUSTIFY_LEFT
        );
      }
    }
  }

  function drawBar(dc as Graphics.Dc, x as Number, y as Number, slotH as Number) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    var barH = slotH - 12;
    if (barH < 16) {
      barH = 16;
    }
    dc.fillRectangle(x, y - barH / 2, BAR_WIDTH, barH);
  }

  function drawMoreHint(dc as Graphics.Dc) as Void {
    var h = dc.getHeight();
    RoundUi.drawCenteredLine(dc, h - 32, "...", Graphics.FONT_MEDIUM, Graphics.COLOR_LT_GRAY);
  }
}
