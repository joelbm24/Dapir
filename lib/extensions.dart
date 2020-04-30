part of dapir;

extension MapMerge<K,V> on Map<K,V> {
  /// Like `addAll()`, but returns a new Map instead of modifying this one.
  /// When both maps contain the same key, [other] values overwrite the original ones.
  Map<K,V> merge(Map<K,V> other) {
    Map<K,V> newMap = {};
    newMap.addAll(this);
    newMap.addAll(other);
    return newMap;
  }
}