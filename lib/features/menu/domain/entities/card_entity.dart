class CardEntity {
  final String category;
  final int remaining;
  final int sold;
  final String revenue;
  final int total;
  final String colorHex;

  CardEntity({
    required this.category,
    required this.remaining,
    required this.sold,
    required this.revenue,
    required this.total,
    required this.colorHex,
  });
}
