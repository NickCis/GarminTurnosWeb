import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class ConfigureView extends WatchUi.View {

  function initialize() {
    View.initialize();
  }

  function onUpdate(dc as Graphics.Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();
    var w = dc.getWidth();
    var h = dc.getHeight();
    dc.drawText(
      w / 2,
      30,
      Graphics.FONT_SMALL,
      L10n.t(Rez.Strings.ConfigureTitle),
      Graphics.TEXT_JUSTIFY_CENTER
    );
    dc.drawText(
      w / 2,
      h / 2 - 10,
      Graphics.FONT_XTINY,
      L10n.t(Rez.Strings.ConfigureHint),
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
    if (Credentials.hasAll()) {
      dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
      dc.drawText(
        w / 2,
        h - 36,
        Graphics.FONT_XTINY,
        L10n.t(Rez.Strings.ConfigureDone),
        Graphics.TEXT_JUSTIFY_CENTER
      );
    }
    RoundUi.drawMenuHint(dc);
  }
}

class ConfigureDelegate extends WatchUi.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onMenu() as Boolean {
    openConfigureMenu();
    return true;
  }

  function onKey(evt as WatchUi.KeyEvent) as Boolean {
    if (evt.getKey() == WatchUi.KEY_MENU) {
      openConfigureMenu();
      return true;
    }
    return false;
  }

  function onSelect() as Boolean {
    openConfigureMenu();
    return true;
  }

  function onStart() as Boolean {
    if (Credentials.hasAll()) {
      AppController.openMainAfterLogin();
      return true;
    }
    openConfigureMenu();
    return true;
  }

  function openConfigureMenu() as Void {
    WatchUi.pushView(new ConfigureMenu(), new ConfigureMenuDelegate(), WatchUi.SLIDE_UP);
  }
}

class ConfigureMenu extends WatchUi.Menu2 {
  function initialize() {
    Menu2.initialize({ :title => L10n.t(Rez.Strings.ConfigureTitle) });
    addItem(new WatchUi.MenuItem(L10n.t(Rez.Strings.ConfigureDomain), domainSummary(), 0, null));
    addItem(new WatchUi.MenuItem(L10n.t(Rez.Strings.ConfigureUsername), userSummary(), 1, null));
    addItem(new WatchUi.MenuItem(L10n.t(Rez.Strings.ConfigurePassword), passSummary(), 2, null));
    if (Credentials.hasAll()) {
      addItem(new WatchUi.MenuItem(L10n.t(Rez.Strings.ConfigureContinue), null, 3, null));
    }
  }

  function domainSummary() as String or Null {
    return summary(Credentials.domain());
  }

  function userSummary() as String or Null {
    return summary(Credentials.username());
  }

  function passSummary() as String or Null {
    var p = Credentials.password();
    if (p.length() == 0) {
      return null;
    }
    return "****";
  }

  function summary(v as String) as String or Null {
    if (v.length() == 0) {
      return null;
    }
    if (v.length() <= 18) {
      return v;
    }
    return v.substring(0, 15) + "...";
  }
}

class ConfigureMenuDelegate extends WatchUi.Menu2InputDelegate {
  function initialize() {
    Menu2InputDelegate.initialize();
  }

  function onKey(evt as WatchUi.KeyEvent) as Boolean {
    return MenuInput.handleKey(evt);
  }

  function onBack() as Void {
    WatchUi.popView(WatchUi.SLIDE_DOWN);
  }

  function onSelect(item as WatchUi.MenuItem) as Void {
    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    var id = item.getId();
    if (id == null || !(id instanceof Number)) {
      return;
    }
    var n = id as Number;
    if (n == 0) {
      var domainView = new StringInputView(0);
      WatchUi.pushView(domainView, new StringInputDelegate(domainView), WatchUi.SLIDE_LEFT);
    } else if (n == 1) {
      var userView = new StringInputView(1);
      WatchUi.pushView(userView, new StringInputDelegate(userView), WatchUi.SLIDE_LEFT);
    } else if (n == 2) {
      var passView = new StringInputView(2);
      WatchUi.pushView(passView, new StringInputDelegate(passView), WatchUi.SLIDE_LEFT);
    } else if (n == 3) {
      AppController.openMainAfterLogin();
    }
  }
}
