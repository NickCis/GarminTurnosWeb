import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class LoadingView extends WatchUi.View {

  function initialize() {
    View.initialize();
  }

  function onUpdate(dc as Graphics.Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();
    var w = dc.getWidth();
    var h = dc.getHeight();
    var cx = w / 2;
    var cy = h / 2 - 10;
    drawSpinner(dc, cx, cy);
    dc.drawText(
      cx,
      h - 40,
      Graphics.FONT_SMALL,
      L10n.t(Rez.Strings.LoadingLabel),
      Graphics.TEXT_JUSTIFY_CENTER
    );
  }

  function drawSpinner(dc as Graphics.Dc, cx as Number, cy as Number) as Void {
    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    var t = System.getTimer();
    var start = (t / 20) % 360;
    dc.drawArc(cx, cy, 28, Graphics.ARC_COUNTER_CLOCKWISE, start, start + 60);
    dc.drawArc(cx, cy, 22, Graphics.ARC_COUNTER_CLOCKWISE, start + 180, start + 240);
  }
}
