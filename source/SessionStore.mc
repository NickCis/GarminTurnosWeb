import Toybox.Application.Storage;
import Toybox.Lang;

module SessionStore {
  const KEY_APP1 = "tw_app1";
  const KEY_APP2 = "tw_app2";

  function clearSession() as Void {
    safeDel(KEY_APP1);
    safeDel(KEY_APP2);
  }

  function saveCk(app1 as Number, app2 as String) as Void {
    Storage.setValue(KEY_APP1, app1);
    Storage.setValue(KEY_APP2, app2);
  }

  function hasSession() as Boolean {
    return getApp1() != null && getApp2() != null;
  }

  function getApp1() as Number or Null {
    try {
      var v = Storage.getValue(KEY_APP1);
      if (v == null) {
        return null;
      }
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
    } catch (ex) {
    }
    return null;
  }

  function getApp2() as String or Null {
    try {
      var v = Storage.getValue(KEY_APP2);
      if (v == null) {
        return null;
      }
      if (v instanceof String) {
        return v as String;
      }
      return v.toString();
    } catch (ex) {
    }
    return null;
  }

  function safeDel(key as String) as Void {
    try {
      Storage.deleteValue(key);
    } catch (e) {
    }
  }
}
