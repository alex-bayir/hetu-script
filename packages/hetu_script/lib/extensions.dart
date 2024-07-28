extension Convert<K,V> on Iterable<MapEntry<K,V>>{
  Map<K,V> toMap()=>Map.fromEntries(this);
}
extension Iterables<E> on Iterable<E>{
  Map<K,V> toMap<K,V>(K Function(E element) key,V Function(E element) value)=>map((e) => MapEntry(key(e), value(e))).toMap();
}
