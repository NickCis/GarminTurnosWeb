import Toybox.Lang;
import Toybox.WatchUi;

class AppMenu extends WatchUi.Menu2 {
  function initialize() {
    Menu2.initialize({ :title => L10n.t(Rez.Strings.MenuTitle) });
    addItem(new WatchUi.MenuItem(L10n.t(Rez.Strings.MenuRefresh), null, 0, null));
    addItem(new WatchUi.MenuItem(L10n.t(Rez.Strings.MenuLogout), null, 1, null));
  }
}

class AppMenuDelegate extends WatchUi.Menu2InputDelegate {
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
      AppController.refreshCurrent();
    } else if (n == 1) {
      AppController.logout();
    }
  }
}
