class ItemUpdatedEvent<T> {
  final T before;
  final T after;

  ItemUpdatedEvent(this.before, this.after);
}
