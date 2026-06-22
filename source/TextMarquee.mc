import Toybox.Lang;

// Horizontal marquee for a single line of text that exceeds its clip width.
class TextMarquee {
  const SCROLL_STEP = 2;
  const PAUSE_TICKS = 14;
  const END_GAP = 28;

  var _offset as Number = 0;
  var _pause as Number = 0;

  function reset() as Void {
    _offset = 0;
    _pause = PAUSE_TICKS;
  }

  function getOffset() as Number {
    return _offset;
  }

  function tick(textWidth as Number, clipWidth as Number) as Void {
    if (textWidth <= clipWidth) {
      _offset = 0;
      _pause = PAUSE_TICKS;
      return;
    }
    if (_pause > 0) {
      _pause -= 1;
      return;
    }
    _offset -= SCROLL_STEP;
    var minOffset = clipWidth - textWidth - END_GAP;
    if (_offset < minOffset) {
      _offset = 0;
      _pause = PAUSE_TICKS;
    }
  }
}
