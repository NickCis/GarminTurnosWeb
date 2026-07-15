import Toybox.Lang;

module HtmlUtil {
  function cleanHtml(html as String) as String {
    if (html == null || html.length() == 0) {
      return "";
    }
    var s = stripHtmlToText(html);
    s = decodeEntities(s);
    return normalizeLines(s);
  }

  function stripHtmlToText(s as String) as String {
    var out = "";
    var pos = 0;
    var n = s.length();
    while (pos < n) {
      var rel = s.substring(pos, n).find("<");
      if (rel == null) {
        out += s.substring(pos, n);
        break;
      }
      var tagStart = pos + (rel as Number);
      if (tagStart > pos) {
        out += s.substring(pos, tagStart);
      }
      if (tagStart + 3 < n && s.substring(tagStart, tagStart + 4).equals("<!--")) {
        var commentEnd = findFrom(s, "-->", tagStart + 4);
        if (commentEnd == null) {
          break;
        }
        pos = (commentEnd as Number) + 3;
        continue;
      }

      var tagEnd = findFrom(s, ">", tagStart + 1);
      if (tagEnd == null) {
        break;
      }
      var tag = s.substring(tagStart, (tagEnd as Number) + 1);
      if (isLineBreakTag(tag)) {
        out += "\n";
      }
      pos = (tagEnd as Number) + 1;
    }
    return out;
  }

  function isLineBreakTag(tag as String) as Boolean {
    if (tag.length() < 3) {
      return false;
    }
    return tag.equals("<br>") ||
      tag.equals("<br/>") ||
      tag.equals("<br />") ||
      tag.equals("<BR>") ||
      tag.equals("<BR/>") ||
      tag.equals("<BR />") ||
      tag.equals("</p>") ||
      tag.equals("</P>") ||
      tag.equals("</div>") ||
      tag.equals("</DIV>") ||
      tag.equals("</li>") ||
      tag.equals("</LI>");
  }

  function findFrom(s as String, needle as String, start as Number) as Number or Null {
    if (start >= s.length()) {
      return null;
    }
    var rel = s.substring(start, s.length()).find(needle);
    if (rel == null) {
      return null;
    }
    return start + (rel as Number);
  }

  function decodeEntities(s as String) as String {
    var out = s;
    out = replaceAll(out, "&nbsp;", " ");
    out = replaceAll(out, "&amp;", "&");
    out = replaceAll(out, "&lt;", "<");
    out = replaceAll(out, "&gt;", ">");
    out = replaceAll(out, "&iacute;", "í");
    out = replaceAll(out, "&Iacute;", "Í");
    out = replaceAll(out, "&aacute;", "á");
    out = replaceAll(out, "&Aacute;", "Á");
    out = replaceAll(out, "&eacute;", "é");
    out = replaceAll(out, "&Eacute;", "É");
    out = replaceAll(out, "&oacute;", "ó");
    out = replaceAll(out, "&Oacute;", "Ó");
    out = replaceAll(out, "&uacute;", "ú");
    out = replaceAll(out, "&Uacute;", "Ú");
    out = replaceAll(out, "&ntilde;", "ñ");
    out = replaceAll(out, "&Ntilde;", "Ñ");
    out = replaceAll(out, "&uuml;", "ü");
    out = replaceAll(out, "&Uuml;", "Ü");
    out = replaceAll(out, "&#237;", "í");
    out = replaceAll(out, "&#225;", "á");
    out = replaceAll(out, "&#233;", "é");
    out = replaceAll(out, "&#243;", "ó");
    out = replaceAll(out, "&#250;", "ú");
    out = replaceAll(out, "&#241;", "ñ");
    return out;
  }

  function normalizeLines(s as String) as String {
    var out = "";
    var start = 0;
    var n = s.length();
    while (start <= n) {
      var end = nextLineEnd(s, start);
      var line = trim(s.substring(start, end));
      if (line.length() == 0) {
        if (end >= n) {
          break;
        }
        start = end + 1;
        continue;
      } else if (!line.equals("-")) {
        if (line.substring(0, 1).equals("-")) {
          line = trim(line.substring(1, line.length()));
        }
        if (line.length() > 0) {
          if (out.length() > 0) {
            out += "\n";
          }
          out += line;
        }
      }
      if (end >= n) {
        break;
      }
      start = end + 1;
    }
    return out;
  }

  function nextLineEnd(s as String, start as Number) as Number {
    var n = s.length();
    for (var i = start; i < n; i++) {
      var ch = s.substring(i, i + 1);
      if (ch.equals("\n") || ch.equals("\r")) {
        return i;
      }
    }
    return n;
  }

  function trim(s as String) as String {
    var start = 0;
    var end = s.length();
    while (start < end) {
      var c = s.substring(start, start + 1);
      if (c.equals(" ") || c.equals("\t")) {
        start += 1;
      } else {
        break;
      }
    }
    while (end > start) {
      var c2 = s.substring(end - 1, end);
      if (c2.equals(" ") || c2.equals("\t")) {
        end -= 1;
      } else {
        break;
      }
    }
    if (start >= end) {
      return "";
    }
    return s.substring(start, end);
  }

  function replaceAll(s as String, find as String, repl as String) as String {
    var idx = s.find(find);
    while (idx != null) {
      var i = idx as Number;
      s = s.substring(0, i) + repl + s.substring(i + find.length(), s.length());
      var nextStart = i + repl.length();
      if (nextStart >= s.length()) {
        break;
      }
      var rest = s.substring(nextStart, s.length());
      var nextIdx = rest.find(find);
      if (nextIdx == null) {
        break;
      }
      idx = nextStart + (nextIdx as Number);
    }
    return s;
  }
}
