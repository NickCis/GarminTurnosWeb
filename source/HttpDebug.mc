import Toybox.Communications;
import Toybox.Lang;
import Toybox.System;

module HttpDebug {
  const ENABLED = true;
  const REDACT_SECRETS = true;

  function logRequest(url as String, body as Lang.Dictionary or Null, opts as Lang.Dictionary or Null) as Void {
    if (!ENABLED) {
      return;
    }
    System.println("[HTTP] >>> " + url);
    if (opts != null) {
      var m = opts.get(:method);
      if (m != null) {
        System.println("[HTTP]     method: " + m.toString());
      }
      var hdrs = opts.get(:headers);
      if (hdrs != null && hdrs instanceof Lang.Dictionary) {
        System.println("[HTTP]     headers: " + formatHeadersForLog(hdrs as Lang.Dictionary));
      }
    }
    if (body == null) {
      System.println("[HTTP]     body: null");
    } else {
      System.println("[HTTP]     body: " + formatDictForLog(body));
    }
  }

  function communicationsErrorLabel(code as Number) as String {
    if (code == Communications.INVALID_HTTP_HEADER_FIELDS_IN_REQUEST) {
      return "INVALID_HTTP_HEADER_FIELDS_IN_REQUEST";
    }
    if (code == Communications.INVALID_HTTP_BODY_IN_REQUEST) {
      return "INVALID_HTTP_BODY_IN_REQUEST";
    }
    if (code == Communications.INVALID_HTTP_METHOD_IN_REQUEST) {
      return "INVALID_HTTP_METHOD_IN_REQUEST";
    }
    if (code == Communications.NETWORK_REQUEST_TIMED_OUT) {
      return "NETWORK_REQUEST_TIMED_OUT";
    }
    if (code == Communications.INVALID_HTTP_BODY_IN_NETWORK_RESPONSE) {
      return "INVALID_HTTP_BODY_IN_NETWORK_RESPONSE";
    }
    if (code == Communications.INVALID_HTTP_HEADER_FIELDS_IN_NETWORK_RESPONSE) {
      return "INVALID_HTTP_HEADER_FIELDS_IN_NETWORK_RESPONSE";
    }
    if (code == Communications.NETWORK_RESPONSE_TOO_LARGE) {
      return "NETWORK_RESPONSE_TOO_LARGE";
    }
    return "Communications error " + code.toString();
  }

  (:typecheck(false))
  function logResponse(url as String, code as Number, data) as Void {
    if (!ENABLED) {
      return;
    }
    System.println("[HTTP] <<< " + url + " responseCode=" + code.toString());
    if (code < 0) {
      System.println("[HTTP]     " + communicationsErrorLabel(code));
    }
    if (data == null) {
      System.println("[HTTP]     body: null");
      return;
    }
    var s = data.toString();
    var maxLen = 1200;
    if (s.length() > maxLen) {
      s = s.substring(0, maxLen) + "...<truncated>";
    }
    System.println("[HTTP]     body: " + s);
  }

  function formatDictForLog(d as Lang.Dictionary) as String {
    var keys = d.keys();
    var out = "{";
    for (var i = 0; i < keys.size(); i++) {
      if (i > 0) {
        out += ",";
      }
      var k = keys[i];
      var keyStr = k != null ? k.toString() : "?";
      var v = d.get(k);
      if (REDACT_SECRETS && (keyStr.equals("password") || keyStr.equals("app2"))) {
        out += keyStr + "=***";
      } else {
        out += keyStr + "=" + (v != null ? v.toString() : "null");
      }
    }
    out += "}";
    return out;
  }

  function formatHeadersForLog(h as Lang.Dictionary) as String {
    var keys = h.keys();
    var out = "{";
    for (var i = 0; i < keys.size(); i++) {
      if (i > 0) {
        out += ",";
      }
      var k = keys[i];
      var keyStr = k != null ? k.toString() : "?";
      var v = h.get(k);
      out += keyStr + "=" + (v != null ? v.toString() : "null");
    }
    out += "}";
    return out;
  }
}
