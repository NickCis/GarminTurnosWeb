import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class StringInputView extends WatchUi.View {
  const FIELD_DOMAIN = 0;
  const FIELD_USERNAME = 1;
  const FIELD_PASSWORD = 2;

  const CHARSET =
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-@!#$%&*+=?";

  var _field as Number;
  var _value as String = "";
  var _charIndex as Number = 0;

  function initialize(field as Number) {
    View.initialize();
    _field = field;
    _value = initialValue(field);
  }

  function initialValue(field as Number) as String {
    if (field == FIELD_DOMAIN) {
      return Credentials.domain();
    }
    if (field == FIELD_USERNAME) {
      return Credentials.username();
    }
    return Credentials.password();
  }

  function fieldTitle() as String {
    if (_field == FIELD_DOMAIN) {
      return L10n.t(Rez.Strings.ConfigureDomain);
    }
    if (_field == FIELD_USERNAME) {
      return L10n.t(Rez.Strings.ConfigureUsername);
    }
    return L10n.t(Rez.Strings.ConfigurePassword);
  }

  function currentChar() as String {
    return CHARSET.substring(_charIndex, _charIndex + 1);
  }

  function appendChar() as Void {
    _value += currentChar();
    WatchUi.requestUpdate();
  }

  function deleteChar() as Void {
    if (_value.length() == 0) {
      return;
    }
    _value = _value.substring(0, _value.length() - 1);
    WatchUi.requestUpdate();
  }

  function moveChar(delta as Number) as Void {
    _charIndex += delta;
    if (_charIndex < 0) {
      _charIndex = CHARSET.length() - 1;
    }
    if (_charIndex >= CHARSET.length()) {
      _charIndex = 0;
    }
    WatchUi.requestUpdate();
  }

  function save() as Void {
    if (_field == FIELD_DOMAIN) {
      Credentials.saveDomain(_value);
    } else if (_field == FIELD_USERNAME) {
      Credentials.saveUsername(_value);
    } else {
      Credentials.savePassword(_value);
    }
  }

  function onUpdate(dc as Graphics.Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();
    var w = dc.getWidth();
    var h = dc.getHeight();
    var cx = w / 2;

    dc.drawText(cx, 24, Graphics.FONT_SMALL, fieldTitle(), Graphics.TEXT_JUSTIFY_CENTER);

    var display = _value;
    if (_field == FIELD_PASSWORD && display.length() > 0) {
      display = maskPassword(display.length());
    }
    dc.drawText(cx, 70, Graphics.FONT_XTINY, display, Graphics.TEXT_JUSTIFY_CENTER);

    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      cx,
      110,
      Graphics.FONT_LARGE,
      currentChar(),
      Graphics.TEXT_JUSTIFY_CENTER
    );

    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      cx,
      h - 50,
      Graphics.FONT_XTINY,
      L10n.t(Rez.Strings.InputHint),
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
    RoundUi.drawMenuHint(dc);
  }

  function maskPassword(len as Number) as String {
    var out = "";
    for (var i = 0; i < len; i++) {
      out += "*";
    }
    return out;
  }
}

class StringInputDelegate extends WatchUi.BehaviorDelegate {
  var _view as StringInputView;

  function initialize(view as StringInputView) {
    BehaviorDelegate.initialize();
    _view = view;
  }

  function onUp() as Boolean {
    _view.moveChar(-1);
    return true;
  }

  function onDown() as Boolean {
    _view.moveChar(1);
    return true;
  }

  function onStart() as Boolean {
    _view.appendChar();
    return true;
  }

  function onBack() as Boolean {
    _view.deleteChar();
    return true;
  }

  function onMenu() as Boolean {
    _view.save();
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
    return true;
  }

  function onKey(evt as WatchUi.KeyEvent) as Boolean {
    return false;
  }
}
