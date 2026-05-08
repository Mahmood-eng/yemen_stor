class ChatMessage {
  final String text;
  final bool isUser;
  final bool hasProduct;
  final String? productName;
  final String? productPrice;
  final String? productDetails;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.hasProduct = false,
    this.productName,
    this.productPrice,
    this.productDetails,
  });
}
