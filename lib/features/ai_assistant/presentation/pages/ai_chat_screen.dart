import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yemen_stor/features/ai_assistant/domain/models/chat_message.dart';

import '../widgets/chat_input.dart';
import '../widgets/message_list.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'مرحباً بك! انا صراط مساعدك الذكي كيف أستطيع مساعدتك اليوم؟',
      isUser: false,
      hasProduct: false,
    ),
  ];
  bool _isBotTyping = false;
  bool _hasInput = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _messageController.clear();
      _hasInput = false;
      _isBotTyping = true;
    });

    _scrollToEnd();

    Timer(const Duration(milliseconds: 900), () {
      setState(() {
        _isBotTyping = false;
        _messages.add(
          ChatMessage(
            text: 'إليك هذا الاختيار من المتجر، جاهز للمراجعة؟',
            isUser: false,
            hasProduct: true,
            productName: 'سماعات بلوتوث لاسلكية',
            productPrice: '299 ريال',
            productDetails: 'تصميم مريح وجودة صوت عالية',
          ),
        );
      });
      _scrollToEnd();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme, isDark),
      body: Column(
        children: [
          Expanded(
            child: MessageList(
              messages: _messages,
              isBotTyping: _isBotTyping,
              scrollController: _scrollController,
            ),
          ),
          ChatInput(
            controller: _messageController,
            isActive: _hasInput,
            onChanged: (value) {
              setState(() {
                _hasInput = value.trim().isNotEmpty;
              });
            },
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, bool isDark) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pop(context),
      ),
      elevation: 0,
      backgroundColor: theme.colorScheme.surface,
      iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'نور',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'متصل الآن',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.72),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
