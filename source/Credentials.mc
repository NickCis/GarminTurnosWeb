import Toybox.Application.Properties;
import Toybox.Application.Storage;
import Toybox.Lang;

module Credentials {
  const KEY_DOMAIN = "cfg_domain";
  const KEY_USERNAME = "cfg_username";
  const KEY_PASSWORD = "cfg_password";

  function hasAll() as Boolean {
    return nonempty(domain()) && nonempty(username()) && nonempty(password());
  }

  function domain() as String {
    return readValue(KEY_DOMAIN, "domain");
  }

  function username() as String {
    return readValue(KEY_USERNAME, "username");
  }

  function password() as String {
    return readValue(KEY_PASSWORD, "password");
  }

  function saveDomain(value as String) as Void {
    Storage.setValue(KEY_DOMAIN, value);
  }

  function saveUsername(value as String) as Void {
    Storage.setValue(KEY_USERNAME, value);
  }

  function savePassword(value as String) as Void {
    Storage.setValue(KEY_PASSWORD, value);
  }

  function clearStored() as Void {
    safeDel(KEY_DOMAIN);
    safeDel(KEY_USERNAME);
    safeDel(KEY_PASSWORD);
  }

  function readValue(storageKey as String, propKey as String) as String {
    try {
      var stored = Storage.getValue(storageKey);
      if (stored != null && stored instanceof String) {
        var ss = stored as String;
        if (ss.length() > 0) {
          return ss;
        }
      }
    } catch (ex) {
    }
    return getStringProp(propKey);
  }

  function nonempty(s as String) as Boolean {
    return s != null && s.length() > 0;
  }

  function getStringProp(key as String) as String {
    var v = Properties.getValue(key);
    if (v instanceof String) {
      return v as String;
    }
    return v.toString();
  }

  function safeDel(key as String) as Void {
    try {
      Storage.deleteValue(key);
    } catch (e) {
    }
  }
}
