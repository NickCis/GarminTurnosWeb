import Toybox.Lang;
import Toybox.WatchUi;

module L10n {
  (:typecheck(false))
  function t(res as Lang.Object) as String {
    return WatchUi.loadResource(res) as String;
  }

  (:typecheck(false))
  function tf(res as Lang.Object, args as Lang.Array) as String {
    return Lang.format(t(res), args);
  }
}
