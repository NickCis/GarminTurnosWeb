import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class LoadingAnimationController {
  var _layer as WatchUi.AnimationLayer or Null = null;
  var _textLayer as WatchUi.Layer or Null = null;
  var _playing as Lang.Boolean = false;

  function ensure(view as WatchUi.View, dc as Graphics.Dc) as Void {
    if (!(Rez.Drawables has :LoadingSpinner)) {
      drawTextOnly(dc);
      return;
    }

    if (_layer == null) {
      _layer = new WatchUi.AnimationLayer(
        Rez.Drawables.LoadingSpinner,
        {
          :locX => 0,
          :locY => 0,
          :visibility => true
        }
      );
      view.addLayer(_layer);
    }
    if (_textLayer == null) {
      _textLayer = new WatchUi.Layer({
        :locX => 0,
        :locY => 0,
        :width => dc.getWidth(),
        :height => dc.getHeight(),
        :visibility => true
      });
      view.addLayer(_textLayer);
    }
    drawTextLayer(dc);
    play();
  }

  function drawTextOnly(dc as Graphics.Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      dc.getWidth() / 2,
      dc.getHeight() / 2,
      Graphics.FONT_SMALL,
      L10n.t(Rez.Strings.LoadingLabel),
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  function drawTextLayer(dc as Graphics.Dc) as Void {
    if (_textLayer == null) {
      return;
    }
    var layerDc = _textLayer.getDc();
    if (layerDc == null) {
      return;
    }
    layerDc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    layerDc.clear();
    layerDc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    layerDc.drawText(
      dc.getWidth() / 2,
      dc.getHeight() / 2,
      Graphics.FONT_SMALL,
      L10n.t(Rez.Strings.LoadingLabel),
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  function play() as Void {
    if (_layer == null || _playing) {
      return;
    }
    _playing = true;
    _layer.play({ :delegate => new LoadingAnimationDelegate(self) });
  }

  function didFinish() as Void {
    _playing = false;
    play();
  }

  function stop(view as WatchUi.View) as Void {
    if (_layer != null) {
      _layer.stop();
      try {
        view.removeLayer(_layer);
      } catch (ex) {
      }
      _layer = null;
    }
    if (_textLayer != null) {
      try {
        view.removeLayer(_textLayer);
      } catch (ex2) {
      }
      _textLayer = null;
    }
    _playing = false;
  }
}

class LoadingAnimationDelegate extends WatchUi.AnimationDelegate {
  var _controller as LoadingAnimationController;

  function initialize(controller as LoadingAnimationController) {
    AnimationDelegate.initialize();
    _controller = controller;
  }

  function onAnimationEvent(event as WatchUi.AnimationEvent, options as Lang.Dictionary) as Void {
    if (event == WatchUi.ANIMATION_EVENT_COMPLETE) {
      _controller.didFinish();
    } else if (event == WatchUi.ANIMATION_EVENT_CANCELED) {
      _controller.didFinish();
    }
  }
}
