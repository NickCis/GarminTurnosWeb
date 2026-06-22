import Toybox.Lang;

module HtmlUtil {
  function cleanHtml(html as String) as String {
    if (html == null || html.length() == 0) {
      return "";
    }
    var s = html;
    s = replaceAll(s, "<br/>", "\n");
    s = replaceAll(s, "<br>", "\n");
    s = replaceAll(s, "<br />", "\n");
    s = replaceAll(s, "</p>", "\n");
    s = replaceAll(s, "</P>", "\n");
    s = removeComments(s);
    s = stripTags(s);
    s = decodeEntities(s);
    return normalizeLines(s);
  }

  function removeComments(s as String) as String {
    var out = "";
    var i = 0;
    var n = s.length();
    while (i < n) {
      if (i + 3 < n && s.substring(i, i + 4).equals("<!--")) {
        var j = i + 4;
        var found = false;
        while (j + 2 < n) {
          if (s.substring(j, j + 3).equals("-->")) {
            i = j + 3;
            found = true;
            break;
          }
          j += 1;
        }
        if (!found) {
          break;
        }
      } else {
        out += s.substring(i, i + 1);
        i += 1;
      }
    }
    return out;
  }

  function stripTags(s as String) as String {
    var out = "";
    var inTag = false;
    var n = s.length();
    for (var i = 0; i < n; i++) {
      var ch = s.substring(i, i + 1);
      if (ch.equals("<")) {
        inTag = true;
      } else if (ch.equals(">")) {
        inTag = false;
      } else if (!inTag) {
        out += ch;
      }
    }
    return out;
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
    var lines = splitLines(s);
    var out = "";
    for (var i = 0; i < lines.size(); i++) {
      var line = trim(lines[i]);
      if (line.length() == 0) {
        continue;
      }
      if (line.equals("-")) {
        continue;
      }
      if (out.length() > 0) {
        out += "\n";
      }
      if (line.substring(0, 1).equals("-")) {
        line = trim(line.substring(1, line.length()));
      }
      out += line;
    }
    return out;
  }

  function splitLines(s as String) as Lang.Array {
    var lines = [] as Lang.Array;
    var cur = "";
    var n = s.length();
    for (var i = 0; i < n; i++) {
      var ch = s.substring(i, i + 1);
      if (ch.equals("\n") || ch.equals("\r")) {
        lines.add(cur);
        cur = "";
      } else {
        cur += ch;
      }
    }
    lines.add(cur);
    return lines;
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
