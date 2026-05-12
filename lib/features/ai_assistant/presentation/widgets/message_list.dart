import 'package:flutter/material.dart';
import 'package:yemen_store/features/ai_assistant/domain/models/chat_message.dart';

import 'chat_bubble.dart';
import 'product_suggestion_card.dart';
import 'typing_indicator.dart';

class MessageList extends StatelessWidget {
  const MessageList({
    super.key,
    required this.messages,
    required this.isBotTyping,
    required this.scrollController,
  });

  final List<ChatMessage> messages;
  final bool isBotTyping;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      itemCount: messages.length + (isBotTyping ? 1 : 0),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        if (index >= messages.length) {
          return const Padding(
            padding: EdgeInsets.only(top: 16),
            child: TypingIndicator(),
          );
        }

        final message = messages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: message.isUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              ChatBubble(text: message.text, isSender: message.isUser),
              if (message.hasProduct) ...[
                const SizedBox(height: 10),
                ProductSuggestionCard(
                  productName: message.productName ?? 'منتج مميز',
                  productPrice: message.productPrice ?? 'سعر خاص',
                  productDetails: message.productDetails ?? '',
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
