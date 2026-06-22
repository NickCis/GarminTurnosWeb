import Toybox.Application.Storage;
import Toybox.Lang;

module CacheStore {
  const KEY_PANEL = "cache_panel";
  const KEY_LIST_PREFIX = "cache_list_";
  const KEY_PLANI_PREFIX = "cache_plani_";

  function clearAll() as Void {
    safeDel(KEY_PANEL);
    // Individual list/plani keys remain until overwritten; logout clears session only.
    // For full logout we rely on SessionStore + Credentials; stale cache is acceptable
    // until keys are reused, but we clear panel at minimum.
  }

  function clearAllData() as Void {
    // Best-effort wipe of known keys; dynamic keys expire naturally.
    safeDel(KEY_PANEL);
  }

  function savePanel(data as Lang.Array) as Void {
    Storage.setValue(KEY_PANEL, data);
  }

  function getPanel() as Lang.Array or Null {
    return getArray(KEY_PANEL);
  }

  function saveTrainings(workoutId as String, data as Lang.Array) as Void {
    Storage.setValue(KEY_LIST_PREFIX + workoutId, data);
  }

  function getTrainings(workoutId as String) as Lang.Array or Null {
    return getArray(KEY_LIST_PREFIX + workoutId);
  }

  function savePlani(trainingId as String, data as Lang.Dictionary) as Void {
    Storage.setValue(KEY_PLANI_PREFIX + trainingId, data);
  }

  function getPlani(trainingId as String) as Lang.Dictionary or Null {
    try {
      var v = Storage.getValue(KEY_PLANI_PREFIX + trainingId);
      if (v != null && v instanceof Lang.Dictionary) {
        return v as Lang.Dictionary;
      }
    } catch (ex) {
    }
    return null;
  }

  function getArray(key as String) as Lang.Array or Null {
    try {
      var v = Storage.getValue(key);
      if (v != null && v instanceof Lang.Array) {
        return v as Lang.Array;
      }
    } catch (ex) {
    }
    return null;
  }

  function safeDel(key as String) as Void {
    try {
      Storage.deleteValue(key);
    } catch (e) {
    }
  }
}
