import Toybox.Lang;

// Vertical slide between list rows (one row = one third of screen height).
class SlotScrollAnimator {
  const STEP = 10;

  var _offsetY as Number = 0;
  var _targetY as Number = 0;

  function reset() as Void {
    _offsetY = 0;
    _targetY = 0;
  }

  function startSlide(rowHeight as Number, direction as Number) as Void {
    _offsetY = 0;
    _targetY = rowHeight * direction;
  }

  function isAnimating() as Boolean {
    return _offsetY != _targetY;
  }

  function getOffsetY() as Number {
    return _offsetY;
  }

  function tick() as Boolean {
    if (_offsetY == _targetY) {
      return false;
    }
    if (_offsetY < _targetY) {
      _offsetY += STEP;
      if (_offsetY > _targetY) {
        _offsetY = _targetY;
      }
    } else {
      _offsetY -= STEP;
      if (_offsetY < _targetY) {
        _offsetY = _targetY;
      }
    }
    return true;
  }
}
