import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class LoadingView extends WatchUi.View {

  function initialize() {
    View.initialize();
  }

  function onUpdate(dc as Graphics.Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();
  }
}
