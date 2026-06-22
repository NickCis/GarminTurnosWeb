import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

module ListUi {
  const STYLE_WORKOUTS = 0;
  const STYLE_TRAININGS = 1;
  const TICK_MS = 33;
  const KIND_HEADER = "header";
  const KIND_ITEM = "item";
  const TEXT_LEFT = 32;

  function headerEntry(text as String) as Lang.Dictionary {
    return {
      "kind" => KIND_HEADER,
      "text" => text,
      "subtitle" => "",
      "tidx" => -1
    };
  }

  function itemEntry(text as String, subtitle as String, tidx as Number) as Lang.Dictionary {
    return {
      "kind" => KIND_ITEM,
      "text" => text,
      "subtitle" => subtitle,
      "tidx" => tidx
    };
  }

  function isHeader(entry as Lang.Dictionary) as Boolean {
    var k = entry.get("kind");
    return k != null && k instanceof String && (k as String).equals(KIND_HEADER);
  }
}

class ItemListView extends WatchUi.View {
  const VISIBLE_ROWS = 3;
  const CENTER_ROW = 1;
  const BAR_GAP = 6;
  const BAR_WIDTH = 3;

  var _title as String;
  var _entries as Lang.Array;
  var _emptyMsg as String;
  var _style as Number;
  var _centerIndex as Number = 0;
  var _pendingCenter as Number or Null = null;
  var _rowHeight as Number = 80;
  var _anim as SlotScrollAnimator or Null = null;
  var _listTimer as Timer.Timer or Null = null;

  function initialize(title as String, entries as Lang.Array, emptyMsg as String, style as Number) {
    View.initialize();
    _title = title;
    _entries = entries;
    _emptyMsg = emptyMsg;
    _style = style;
    if (_style == ListUi.STYLE_TRAININGS) {
      _anim = new SlotScrollAnimator();
      _centerIndex = minCenterIndex();
    }
  }

  function minCenterIndex() as Number {
    if (_entries.size() > 1) {
      return 1;
    }
    return 0;
  }

  function maxCenterIndex() as Number {
    if (_entries.size() == 0) {
      return 0;
    }
    return _entries.size() - 1;
  }

  function isTrainingsList() as Boolean {
    return _style == ListUi.STYLE_TRAININGS;
  }

  function getIndex() as Number {
    return _centerIndex;
  }

  function usesListTimer() as Boolean {
    return _anim != null;
  }

  function onShow() as Void {
    startListTimer();
  }

  function onHide() as Void {
    stopListTimer();
  }

  function startListTimer() as Void {
    if (!usesListTimer()) {
      return;
    }
    stopListTimer();
    var t = new Timer.Timer();
    _listTimer = t;
    t.start(method(:tickListFrame), ListUi.TICK_MS, true);
  }

  function stopListTimer() as Void {
    if (_listTimer != null) {
      _listTimer.stop();
      _listTimer = null;
    }
  }

  function getSelectedEntry() as Lang.Dictionary or Null {
    return entryAtIndex(_centerIndex);
  }

  function canMove(delta as Number) as Boolean {
    var next = _centerIndex + delta;
    return next >= minCenterIndex() && next <= maxCenterIndex();
  }

  function moveSelection(delta as Number) as Void {
    if (_style == ListUi.STYLE_TRAININGS) {
      moveTrainingsSelection(delta);
      return;
    }
    moveWorkoutsSelection(delta);
  }

  function moveTrainingsSelection(delta as Number) as Void {
    if (_entries.size() == 0 || !canMove(delta)) {
      return;
    }
    if (_anim != null && _anim.isAnimating()) {
      return;
    }
    _pendingCenter = _centerIndex + delta;
    if (_anim != null) {
      _anim.startSlide(_rowHeight, -delta);
    } else {
      _centerIndex = _pendingCenter;
      _pendingCenter = null;
    }
    WatchUi.requestUpdate();
  }

  function moveWorkoutsSelection(delta as Number) as Void {
    if (_entries.size() == 0) {
      return;
    }
    _centerIndex += delta;
    if (_centerIndex < 0) {
      _centerIndex = 0;
    }
    if (_centerIndex >= _entries.size()) {
      _centerIndex = _entries.size() - 1;
    }
    WatchUi.requestUpdate();
  }

  function tickListFrame() as Void {
    if (_anim == null) {
      return;
    }
    if (_anim.tick()) {
      WatchUi.requestUpdate();
    }
    if (!_anim.isAnimating() && _pendingCenter != null) {
      _centerIndex = _pendingCenter;
      _pendingCenter = null;
      _anim.reset();
      WatchUi.requestUpdate();
    }
  }

  function rowHeight(dc as Graphics.Dc or Null) as Number {
    if (dc != null) {
      return dc.getHeight() / 3;
    }
    return 80;
  }

  function slotCenterY(dc as Graphics.Dc, slot as Number) as Number {
    var rh = rowHeight(dc);
    return rh * slot + rh / 2;
  }

  function entryAtIndex(idx as Number) as Lang.Dictionary or Null {
    if (idx < 0 || idx >= _entries.size()) {
      return null;
    }
    var e = _entries[idx];
    if (e instanceof Lang.Dictionary) {
      return e as Lang.Dictionary;
    }
    return null;
  }

  function entryAt(offset as Number) as Lang.Dictionary or Null {
    return entryAtIndex(_centerIndex + offset);
  }

  function entryText(entry as Lang.Dictionary) as String {
    var t = entry.get("text");
    if (t instanceof String) {
      return t as String;
    }
    return t != null ? t.toString() : "";
  }

  function entrySubtitle(entry as Lang.Dictionary) as String {
    var sub = entry.get("subtitle");
    if (sub instanceof String) {
      return sub as String;
    }
    return "";
  }

  function onUpdate(dc as Graphics.Dc) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();

    RoundUi.drawMenuHint(dc);

    if (_entries.size() == 0) {
      RoundUi.drawCenteredLine(
        dc,
        RoundUi.centerY(dc),
        _emptyMsg,
        Graphics.FONT_SMALL,
        Graphics.COLOR_LT_GRAY
      );
      return;
    }

    if (_style == ListUi.STYLE_TRAININGS) {
      drawTrainingsSlots(dc);
    } else {
      RoundUi.drawCenteredLine(dc, 36, _title, Graphics.FONT_SMALL, Graphics.COLOR_WHITE);
      drawWorkoutsCarousel(dc);
    }

    if (UiState.fromCache) {
      RoundUi.drawCenteredLine(
        dc,
        dc.getHeight() - 22,
        L10n.t(Rez.Strings.CachedData),
        Graphics.FONT_XTINY,
        Graphics.COLOR_YELLOW
      );
    }
  }

  function drawTrainingsSlots(dc as Graphics.Dc) as Void {
    _rowHeight = rowHeight(dc);
    var offsetY = _anim != null ? _anim.getOffsetY() : 0;
    var rh = rowHeight(dc);
    var w = dc.getWidth();

    for (var slot = 0; slot < VISIBLE_ROWS; slot++) {
      var entryIdx = _centerIndex + slot - CENTER_ROW;
      var entry = entryAtIndex(entryIdx);
      if (entry == null) {
        continue;
      }
      var y = slotCenterY(dc, slot) + offsetY;
      if (ListUi.isHeader(entry)) {
        drawHeaderSlot(dc, y, entryText(entry), rh);
      } else {
        drawTrainingSlot(dc, y, entry, rh, w);
      }
    }

    drawFixedSelectionBar(dc, rh);
  }

  function drawFixedSelectionBar(dc as Graphics.Dc, slotH as Number) as Void {
    var centerEntry = entryAtIndex(_centerIndex);
    if (centerEntry == null || ListUi.isHeader(centerEntry)) {
      return;
    }
    var fixedY = slotCenterY(dc, CENTER_ROW);
    drawBar(dc, ListUi.TEXT_LEFT - BAR_GAP - BAR_WIDTH, fixedY, slotH);
  }

  function drawHeaderSlot(
    dc as Graphics.Dc,
    y as Number,
    text as String,
    slotH as Number
  ) as Void {
    var cx = dc.getWidth() / 2;

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    var fontH = dc.getFontHeight(Graphics.FONT_SMALL);
    var textY = y - fontH / 2 - 4;
    dc.drawText(cx, textY, Graphics.FONT_SMALL, text, Graphics.TEXT_JUSTIFY_CENTER);

    var lineY = textY + fontH + 8;
    var lineW = dc.getWidth() * 2 / 3;
    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
    dc.drawLine(cx - lineW / 2, lineY, cx + lineW / 2, lineY);
  }

  function drawTrainingSlot(
    dc as Graphics.Dc,
    y as Number,
    entry as Lang.Dictionary,
    slotH as Number,
    w as Number
  ) as Void {
    var title = entryText(entry);
    var fecha = entrySubtitle(entry);
    var textX = ListUi.TEXT_LEFT;
    var clipW = w - textX - 16;
    var titleY = y - dc.getFontHeight(Graphics.FONT_XTINY) / 2 - 2;
    var dateY = y + dc.getFontHeight(Graphics.FONT_SMALL) / 2 + 2;

    RoundUi.drawClippedText(
      dc, textX, titleY, clipW, slotH, title, Graphics.FONT_SMALL, Graphics.COLOR_WHITE, 0
    );
    if (fecha.length() > 0) {
      RoundUi.drawClippedText(
        dc, textX, dateY, clipW, slotH, fecha, Graphics.FONT_XTINY, Graphics.COLOR_LT_GRAY, 0
      );
    }
  }

  function drawBar(dc as Graphics.Dc, x as Number, y as Number, slotH as Number) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    var barH = slotH - 12;
    if (barH < 16) {
      barH = 16;
    }
    dc.fillRectangle(x, y - barH / 2, BAR_WIDTH, barH);
  }

  function drawWorkoutsCarousel(dc as Graphics.Dc) as Void {
    var cy = RoundUi.centerY(dc);
    var slotHeights = [0, 0, 0] as Lang.Array;
    var offsets = [-1, 0, 1] as Lang.Array;
    for (var r = 0; r < VISIBLE_ROWS; r++) {
      if (entryAt(offsets[r] as Number) == null) {
        slotHeights[r] = dc.getFontHeight(Graphics.FONT_XTINY) + 8;
      } else if (r == CENTER_ROW) {
        slotHeights[r] = dc.getFontHeight(Graphics.FONT_SMALL) + 8;
      } else {
        slotHeights[r] = dc.getFontHeight(Graphics.FONT_XTINY) + 8;
      }
    }
    var h0 = slotHeights[0] as Number;
    var h1 = slotHeights[1] as Number;
    var h2 = slotHeights[2] as Number;
    var rowYs = [
      cy - h1 / 2 - h0 / 2,
      cy,
      cy + h1 / 2 + h2 / 2
    ] as Lang.Array;

    for (var row = 0; row < VISIBLE_ROWS; row++) {
      var entry = entryAt(offsets[row] as Number);
      if (entry == null) {
        continue;
      }
      var isSel = row == CENTER_ROW;
      var y = rowYs[row] as Number;
      var text = entryText(entry);
      if (!isSel) {
        RoundUi.drawCenteredLine(dc, y, text, Graphics.FONT_XTINY, Graphics.COLOR_LT_GRAY);
        continue;
      }
      var layout = rowLayout(dc, y);
      drawBar(dc, layout[:barX] as Number, y, slotHeights[row] as Number);
      RoundUi.drawClippedText(
        dc,
        layout[:textX] as Number,
        y,
        layout[:clipW] as Number,
        slotHeights[row] as Number,
        text,
        Graphics.FONT_SMALL,
        Graphics.COLOR_WHITE,
        0
      );
    }
  }

  function rowLayout(dc as Graphics.Dc, y as Number) as Lang.Dictionary {
    var maxW = RoundUi.maxWidthAtY(dc, y);
    var cx = RoundUi.centerX(dc);
    var textX = cx - maxW / 2 + 10;
    var barX = textX - BAR_GAP - BAR_WIDTH;
    return {
      :barX => barX,
      :textX => textX,
      :clipW => maxW - 20
    };
  }
}

class ItemListDelegate extends WatchUi.BehaviorDelegate {

  var _view as ItemListView;
  var _onSelect as Method;

  function initialize(view as ItemListView, onSelect as Method) {
    BehaviorDelegate.initialize();
    _view = view;
    _onSelect = onSelect;
  }

  function onMenu() as Boolean {
    MenuInput.undoSpuriousUpScroll(method(:undoUpScroll));
    return MenuInput.handleMenuBehavior();
  }

  function undoUpScroll(_ as Lang.Object or Null) as Void {
    _view.moveSelection(1);
  }

  function onKey(evt as WatchUi.KeyEvent) as Boolean {
    if (MenuInput.handleKey(evt)) {
      return true;
    }
    var key = evt.getKey();
    if (key == WatchUi.KEY_DOWN) {
      _view.moveSelection(1);
      return true;
    }
    if (key == WatchUi.KEY_UP) {
      MenuInput.markUpPress();
      _view.moveSelection(-1);
      return true;
    }
    return false;
  }

  function onUp() as Boolean {
    MenuInput.markUpPress();
    _view.moveSelection(-1);
    return true;
  }

  function onDown() as Boolean {
    _view.moveSelection(1);
    return true;
  }

  function onPreviousPage() as Boolean {
    MenuInput.markUpPress();
    _view.moveSelection(-1);
    return true;
  }

  function onNextPage() as Boolean {
    _view.moveSelection(1);
    return true;
  }

  function onSelect() as Boolean {
    invokeSelect();
    return true;
  }

  function onStart() as Boolean {
    invokeSelect();
    return true;
  }

  function invokeSelect() as Void {
    _onSelect.invoke([_view] as Lang.Array);
  }
}

class WorkoutsItemListDelegate extends ItemListDelegate {

  function initialize(view as ItemListView) {
    ItemListDelegate.initialize(view, method(:onWorkoutSelected));
    AppController.setScreen(AppController.SCREEN_WORKOUTS);
  }

  function onWorkoutSelected(args as Lang.Array) as Void {
    var view = args[0] as ItemListView;
    var entry = view.getSelectedEntry();
    if (entry == null) {
      return;
    }
    var tidx = entry.get("tidx");
    if (tidx == null || !(tidx instanceof Number)) {
      return;
    }
    var idx = tidx as Number;
    if (idx < 0 || idx >= AppState.workouts.size()) {
      return;
    }
    var sel = AppState.workouts[idx];
    if (!(sel instanceof Lang.Dictionary)) {
      return;
    }
    AppState.selectedWorkout = sel as Lang.Dictionary;
    AppState.trainings = [] as Lang.Array;
    AppState.selectedTraining = null;
    WatchUi.pushView(new TrainingsView(), new TrainingsDelegate(), WatchUi.SLIDE_LEFT);
    AppController.flows().startTrainings(true);
  }

  function onBack() as Boolean {
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
    return true;
  }
}

class TrainingsItemListDelegate extends ItemListDelegate {

  function initialize(view as ItemListView) {
    ItemListDelegate.initialize(view, method(:onTrainingSelected));
    AppController.setScreen(AppController.SCREEN_TRAININGS);
  }

  function onTrainingSelected(args as Lang.Array) as Void {
    var view = args[0] as ItemListView;
    var entry = view.getSelectedEntry();
    if (entry == null || ListUi.isHeader(entry)) {
      return;
    }
    var tidx = entry.get("tidx");
    if (tidx == null || !(tidx instanceof Number)) {
      return;
    }
    var idx = tidx as Number;
    if (idx < 0 || idx >= AppState.trainings.size()) {
      return;
    }
    var sel = AppState.trainings[idx];
    if (!(sel instanceof Lang.Dictionary)) {
      return;
    }
    AppState.selectedTraining = sel as Lang.Dictionary;
    WatchUi.pushView(new TrainingDetailView(), new TrainingDetailDelegate(), WatchUi.SLIDE_LEFT);
    AppController.flows().startDetail(true);
  }

  function onBack() as Boolean {
    return NavHelper.handleBackFromList(NavHelper.LIST_TRAININGS);
  }
}

module ItemListFactory {
  function workoutEntries() as Lang.Array {
    var entries = [] as Lang.Array;
    for (var i = 0; i < AppState.workouts.size(); i++) {
      var item = AppState.workouts[i];
      if (item instanceof Lang.Dictionary) {
        entries.add(
          ListUi.itemEntry(AppState.workoutLabel(item as Lang.Dictionary), "", i)
        );
      }
    }
    return entries;
  }

  function trainingEntries() as Lang.Array {
    var entries = [] as Lang.Array;
    entries.add(ListUi.headerEntry(L10n.t(Rez.Strings.TrainingsTitle)));
    for (var i = 0; i < AppState.trainings.size(); i++) {
      var item = AppState.trainings[i];
      if (!(item instanceof Lang.Dictionary)) {
        continue;
      }
      var d = item as Lang.Dictionary;
      entries.add(
        ListUi.itemEntry(
          AppState.dictString(d, "titulo"),
          AppState.dictString(d, "fecha"),
          i
        )
      );
    }
    return entries;
  }

  function openWorkoutsList() as Void {
    var view = new ItemListView(
      L10n.t(Rez.Strings.WorkoutsTitle),
      workoutEntries(),
      L10n.t(Rez.Strings.EmptyWorkouts),
      ListUi.STYLE_WORKOUTS
    );
    WatchUi.pushView(view, new WorkoutsItemListDelegate(view), WatchUi.SLIDE_LEFT);
  }

  function openTrainingsList() as Void {
    var view = new ItemListView(
      L10n.t(Rez.Strings.TrainingsTitle),
      trainingEntries(),
      L10n.t(Rez.Strings.EmptyTrainings),
      ListUi.STYLE_TRAININGS
    );
    WatchUi.pushView(view, new TrainingsItemListDelegate(view), WatchUi.SLIDE_LEFT);
  }
}
