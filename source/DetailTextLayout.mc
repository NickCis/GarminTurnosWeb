import Toybox.Graphics;
import Toybox.Lang;

module DetailUi {
  const SIDE_MARGIN = 20;
  const TITLE_TOP = 36;
  const TITLE_BODY_GAP = 12;
  const SAFE_BOTTOM_Y = 52;
}

module DetailTextLayout {

  function lineHeight(dc as Graphics.Dc) as Number {
    return dc.getFontHeight(Graphics.FONT_XTINY) + 6;
  }

  function titleLineHeight(dc as Graphics.Dc) as Number {
    return dc.getFontHeight(Graphics.FONT_SMALL) + 2;
  }

  function maxWidthAt(dc as Graphics.Dc, y as Number) as Number {
    var w = dc.getWidth() - DetailUi.SIDE_MARGIN * 2;
    if (w < 48) {
      w = 48;
    }
    return w;
  }

  function textXAt(dc as Graphics.Dc, y as Number) as Number {
    return DetailUi.SIDE_MARGIN;
  }

  function trimLeading(s as String) as String {
    var n = s.length();
    var i = 0;
    while (i < n) {
      var ch = s.substring(i, i + 1);
      if (ch.equals(" ") || ch.equals("\t")) {
        i += 1;
      } else {
        break;
      }
    }
    if (i >= n) {
      return "";
    }
    return s.substring(i, n);
  }

  function textFits(dc as Graphics.Dc, text as String, maxW as Number) as Boolean {
    if (text.length() == 0) {
      return true;
    }
    return dc.getTextWidthInPixels(text, Graphics.FONT_XTINY) <= maxW;
  }

  function splitWords(text as String) as Lang.Array {
    var words = [] as Lang.Array;
    var cur = "";
    var n = text.length();
    for (var i = 0; i < n; i++) {
      var ch = text.substring(i, i + 1);
      if (ch.equals(" ") || ch.equals("\t")) {
        if (cur.length() > 0) {
          words.add(cur);
          cur = "";
        }
      } else {
        cur += ch;
      }
    }
    if (cur.length() > 0) {
      words.add(cur);
    }
    return words;
  }

  function takeLongWordPrefix(dc as Graphics.Dc, word as String, maxW as Number) as String {
    var n = word.length();
    for (var len = n; len > 0; len--) {
      var part = word.substring(0, len);
      if (textFits(dc, part, maxW)) {
        return part;
      }
    }
    if (n > 0) {
      return word.substring(0, 1);
    }
    return "";
  }

  function takeFirstLine(
    dc as Graphics.Dc,
    text as String,
    maxW as Number
  ) as String {
    var source = trimLeading(text);
    if (source.length() == 0) {
      return "";
    }
    if (textFits(dc, source, maxW)) {
      return source;
    }

    var words = splitWords(source);
    if (words.size() == 0) {
      return takeLongWordPrefix(dc, source, maxW);
    }

    var line = "";
    for (var i = 0; i < words.size(); i++) {
      var word = words[i];
      if (!(word instanceof String)) {
        continue;
      }
      var w = word as String;
      var candidate = line.length() == 0 ? w : line + " " + w;
      if (textFits(dc, candidate, maxW)) {
        line = candidate;
      } else if (line.length() > 0) {
        return line;
      } else {
        return takeLongWordPrefix(dc, w, maxW);
      }
    }
    return line;
  }

  function remainderAfterLine(full as String, line as String) as String {
    var source = trimLeading(full);
    if (line.length() == 0 || source.length() == 0) {
      return "";
    }
    if (source.length() >= line.length()) {
      var prefix = source.substring(0, line.length());
      if (prefix.equals(line)) {
        return trimLeading(source.substring(line.length(), source.length()));
      }
    }
    var idx = source.find(line);
    if (idx != null) {
      var pos = (idx as Number) + line.length();
      if (pos >= source.length()) {
        return "";
      }
      return trimLeading(source.substring(pos, source.length()));
    }
    return "";
  }

  function breakIntoVisualLines(dc as Graphics.Dc, text as String, startY as Number) as Lang.Array {
    var out = [] as Lang.Array;
    if (text.length() == 0) {
      return out;
    }
    var lineH = lineHeight(dc);
    var y = startY;
    var paragraphs = splitParagraphs(text);
    for (var p = 0; p < paragraphs.size(); p++) {
      var para = paragraphs[p];
      if (!(para instanceof String)) {
        continue;
      }
      var remaining = trimLeading(para as String);
      if (remaining.length() == 0) {
        continue;
      }
      var guard = 0;
      while (remaining.length() > 0) {
        guard += 1;
        if (guard > 500) {
          break;
        }
        var maxW = maxWidthAt(dc, y);
        var line = takeFirstLine(dc, remaining, maxW);
        if (line.length() == 0) {
          break;
        }
        out.add(line);
        var next = remainderAfterLine(remaining, line);
        if (next.length() == 0 || next.equals(remaining)) {
          break;
        }
        remaining = next;
        y += lineH;
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

  function maxScrollOffset(
    dc as Graphics.Dc,
    lineCount as Number,
    bodyTop as Number,
    lineH as Number
  ) as Number {
    if (lineCount == 0) {
      return 0;
    }
    var bodyBottom = dc.getHeight() - DetailUi.SAFE_BOTTOM_Y;
    var maxLastY = bodyBottom - lineH;
    var offset = lineCount - 1 - (maxLastY - bodyTop) / lineH;
    if (offset < 0) {
      return 0;
    }
    return offset;
  }
}
