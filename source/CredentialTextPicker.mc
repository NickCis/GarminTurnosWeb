import Toybox.Lang;
import Toybox.WatchUi;

module CredentialFields {
  const DOMAIN = 0;
  const USERNAME = 1;
  const PASSWORD = 2;

  function initialValue(field as Number) as String {
    if (field == DOMAIN) {
      return Credentials.domain();
    }
    if (field == USERNAME) {
      return Credentials.username();
    }
    return Credentials.password();
  }

  function save(field as Number, value as String) as Void {
    if (field == DOMAIN) {
      Credentials.saveDomain(value);
    } else if (field == USERNAME) {
      Credentials.saveUsername(value);
    } else {
      Credentials.savePassword(value);
    }
    SessionStore.clearSession();
  }

  function openPicker(field as Number) as Void {
    WatchUi.pushView(
      new WatchUi.TextPicker(initialValue(field)),
      new CredentialTextPickerDelegate(field),
      WatchUi.SLIDE_LEFT
    );
  }
}

class CredentialTextPickerDelegate extends WatchUi.TextPickerDelegate {

  var _field as Number;

  function initialize(field as Number) {
    TextPickerDelegate.initialize();
    _field = field;
  }

  function onTextEntered(text as String, changed as Boolean) as Boolean {
    CredentialFields.save(_field, text);
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
    WatchUi.requestUpdate();
    return true;
  }

  function onCancel() as Boolean {
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
    return true;
  }
}
