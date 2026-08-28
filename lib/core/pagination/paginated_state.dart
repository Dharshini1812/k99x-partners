class PaginatedState<T> {
  final List<T> items;
  final bool hasMore;
  final bool isLoadingMore;

  const PaginatedState({
    this.items = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  PaginatedState<T> copyWith({
    List<T>? items,
    bool? hasMore,
    bool? isLoadingMore,
  }) =>
      PaginatedState(
        items: items ?? this.items,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}
