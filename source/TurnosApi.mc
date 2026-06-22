import Toybox.Communications;
import Toybox.Lang;

class TurnosApiClient {
  const OP_LOGIN = 1;
  const OP_PANEL = 2;
  const OP_LIST = 3;
  const OP_PLANI = 4;

  var _op as Number = 0;
  var _lastUrl as String = "";
  var _callback as Method or Null = null;

  function baseUrl(domain as String) as String {
    return "https://" + domain + ".turnosweb.com";
  }

  function jsonHeaders() as Lang.Dictionary {
    return {
      "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
      "X-Requested-With" => "com.turnosweb.lite"
    };
  }

  function authFields() as Lang.Dictionary or Null {
    var app1 = SessionStore.getApp1();
    var app2 = SessionStore.getApp2();
    if (app1 == null || app2 == null) {
      return null;
    }
    return {
      "app1" => app1,
      "app2" => app2,
      "cookieios" => "",
      "en" => 0
    };
  }

  function login(callback as Method) as Void {
    _op = OP_LOGIN;
    _callback = callback;
    var domain = Credentials.domain();
    var body = {
      "username" => Credentials.username(),
      "password" => Credentials.password(),
      "en" => 0
    };
    var opts = {
      :method => Communications.HTTP_REQUEST_METHOD_POST,
      :headers => jsonHeaders(),
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
    };
    var url = baseUrl(domain) + "/pwa/login";
    _lastUrl = url;
    HttpDebug.logRequest(url, body, opts);
    Communications.makeWebRequest(url, body, opts, method(:onHttpResponse));
  }

  function panelMensajes(callback as Method) as Void {
    var auth = authFields();
    if (auth == null) {
      notifyCallback(false, null, 0);
      return;
    }
    _op = OP_PANEL;
    _callback = callback;
    var domain = Credentials.domain();
    var opts = {
      :method => Communications.HTTP_REQUEST_METHOD_POST,
      :headers => jsonHeaders(),
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
    };
    var url = baseUrl(domain) + "/pwa2/panelmensajes";
    _lastUrl = url;
    HttpDebug.logRequest(url, auth, opts);
    Communications.makeWebRequest(url, auth, opts, method(:onHttpResponse));
  }

  function listTraining(workoutId as String, callback as Method) as Void {
    var auth = authFields();
    if (auth == null) {
      notifyCallback(false, null, 0);
      return;
    }
    _op = OP_LIST;
    _callback = callback;
    var domain = Credentials.domain();
    var body = copyAuth(auth);
    body.put("id", workoutId);
    var opts = {
      :method => Communications.HTTP_REQUEST_METHOD_POST,
      :headers => jsonHeaders(),
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
    };
    var url = baseUrl(domain) + "/pwa3/listtraining";
    _lastUrl = url;
    HttpDebug.logRequest(url, body, opts);
    Communications.makeWebRequest(url, body, opts, method(:onHttpResponse));
  }

  function getPlani(
    trainingId as String,
    wod as String,
    tipoWod as String,
    callback as Method
  ) as Void {
    var auth = authFields();
    if (auth == null) {
      notifyCallback(false, null, 0);
      return;
    }
    _op = OP_PLANI;
    _callback = callback;
    var domain = Credentials.domain();
    var body = copyAuth(auth);
    body.put("id", trainingId);
    body.put("wod", wod);
    body.put("tipo_wod", tipoWod);
    body.put("tipo", 1);
    var opts = {
      :method => Communications.HTTP_REQUEST_METHOD_POST,
      :headers => jsonHeaders(),
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
    };
    var url = baseUrl(domain) + "/pwa3/getplani";
    _lastUrl = url;
    HttpDebug.logRequest(url, body, opts);
    Communications.makeWebRequest(url, body, opts, method(:onHttpResponse));
  }

  function copyAuth(auth as Lang.Dictionary) as Lang.Dictionary {
    return {
      "app1" => auth.get("app1"),
      "app2" => auth.get("app2"),
      "cookieios" => "",
      "en" => 0
    };
  }

  (:typecheck(false))
  function onHttpResponse(responseCode as Number, data as Lang.Dictionary or Lang.String or Null) as Void {
    HttpDebug.logResponse(_lastUrl, responseCode, data);
    var ok = responseCode == 200 && data != null && data instanceof Lang.Dictionary;
    notifyCallback(ok, data, responseCode);
  }

  function notifyCallback(ok as Boolean, data as Lang.Object or Null, code as Number) as Void {
    if (_callback == null) {
      return;
    }
    var cb = _callback;
    _callback = null;
    cb.invoke([ok, data, code] as Lang.Array);
  }
}

module TurnosApi {
  var _client as TurnosApiClient or Null = null;

  function client() as TurnosApiClient {
    if (_client == null) {
      _client = new TurnosApiClient();
    }
    return _client;
  }

  function login(callback as Method) as Void {
    client().login(callback);
  }

  function panelMensajes(callback as Method) as Void {
    client().panelMensajes(callback);
  }

  function listTraining(workoutId as String, callback as Method) as Void {
    client().listTraining(workoutId, callback);
  }

  function getPlani(
    trainingId as String,
    wod as String,
    tipoWod as String,
    callback as Method
  ) as Void {
    client().getPlani(trainingId, wod, tipoWod, callback);
  }

  function parseCk(data as Lang.Dictionary) as Boolean {
    var ck = data.get("ck");
    if (ck == null || !(ck instanceof Lang.Dictionary)) {
      return false;
    }
    var ckD = ck as Lang.Dictionary;
    var app1Raw = ckD.get("0");
    var app2Raw = ckD.get("1");
    if (app1Raw == null || app2Raw == null) {
      return false;
    }
    var app1 = toNumber(app1Raw);
    var app2 = app2Raw.toString();
    if (app1 == null || app2.length() == 0) {
      return false;
    }
    SessionStore.saveCk(app1, app2);
    return true;
  }

  function extractWorkouts(data as Lang.Dictionary) as Lang.Array or Null {
    var w = data.get("w");
    if (w == null || !(w instanceof Lang.Array)) {
      return null;
    }
    return w as Lang.Array;
  }

  function extractTrainings(data as Lang.Dictionary) as Lang.Array or Null {
    var l = data.get("l");
    if (l == null || !(l instanceof Lang.Array)) {
      return null;
    }
    return l as Lang.Array;
  }

  function extractPlaniItem(data as Lang.Dictionary, trainingId as String) as Lang.Dictionary or Null {
    var l = data.get("l");
    if (l == null || !(l instanceof Lang.Array)) {
      return null;
    }
    var arr = l as Lang.Array;
    for (var i = 0; i < arr.size(); i++) {
      var item = arr[i];
      if (item instanceof Lang.Dictionary) {
        var d = item as Lang.Dictionary;
        var id = dictString(d, "id");
        if (id.equals(trainingId)) {
          return d;
        }
      }
    }
    if (arr.size() > 0 && arr[0] instanceof Lang.Dictionary) {
      return arr[0] as Lang.Dictionary;
    }
    return null;
  }

  function loginOk(data as Lang.Dictionary) as Boolean {
    var okVal = data.get("ok");
    if (okVal != null) {
      if (okVal instanceof Boolean) {
        return okVal as Boolean;
      }
      if (okVal instanceof Number) {
        return (okVal as Number) != 0;
      }
    }
    return parseCk(data);
  }

  function loginError(data as Lang.Dictionary) as String {
    return dictString(data, "err");
  }

  function dictString(d as Lang.Dictionary, key as String) as String {
    var v = d.get(key);
    if (v == null) {
      return "";
    }
    if (v instanceof String) {
      return v as String;
    }
    return v.toString();
  }

  function toNumber(v as Lang.Object) as Number or Null {
    if (v instanceof Number) {
      return v as Number;
    }
    if (v instanceof Float) {
      return (v as Float).toNumber();
    }
    if (v instanceof Long) {
      return (v as Long).toNumber();
    }
    if (v instanceof String) {
      return (v as String).toNumber();
    }
    return null;
  }
}
