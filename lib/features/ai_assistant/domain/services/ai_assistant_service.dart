import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yemen_stor/features/ai_assistant/domain/models/chat_message.dart';
import 'dart:math';

class AiAssistantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ChatMessage>> processUserInput(String input) async {
    final text = input.toLowerCase().trim();
    final List<ChatMessage> responses = [];

    // 1. حساب التاجر
    if (_containsAny(text, ['تاجر', 'حساب تاجر', 'كيف اصير تاجر', 'فتح متجر', 'افتح متجر'])) {
      responses.add(ChatMessage(
        text: 'لفتح حساب تاجر وبدء البيع على تطبيقنا، يمكنك الانتقال إلى "القائمة الجانبية" > "الخدمات الرقمية" واختيار "إنشاء متجر". ستحتاج إلى إدخال تفاصيل متجرك مثل الاسم، الوصف، والموقع. هل تود أن أعرض لك خطوات إضافية؟',
        isUser: false,
      ));
      return responses;
    }

    // 2. حساب المهني (صنايعي، مهندس الخ)
    if (_containsAny(text, ['مهني', 'حساب مهني', 'صنايعي', 'مهندس', 'دكتور', 'خدمات مهنية'])) {
      responses.add(ChatMessage(
        text: 'التسجيل كمهني يسمح لك بتقديم خدماتك لآلاف العملاء! يمكنك التسجيل بالذهاب إلى "الخدمات الرقمية" واختيار "تسجيل كمهني"، ثم رفع سيرتك الذاتية واختيار تخصصك (مثل: مهندس، طبيب، حرفي).',
        isUser: false,
      ));
      return responses;
    }

    // 3. تتبع الطلبات
    if (_containsAny(text, ['تتبع', 'طلبي', 'اين الطلب', 'طلباتي'])) {
      responses.add(ChatMessage(
        text: 'يمكنك تتبع حالة طلباتك الحالية والسابقة بكل سهولة عبر الانتقال إلى شاشة "سجل طلباتي" من الصفحة الرئيسية. ستتمكن من رؤية حالة الطلب (قيد المعالجة، في الطريق، أو مكتمل).',
        isUser: false,
      ));
      return responses;
    }

    // 4. اقتراح المنتجات
    if (_containsAny(text, ['اقتراح', 'منتجات', 'اقترح', 'منتج', 'تسوق', 'عروض', 'اشتري'])) {
      responses.add(ChatMessage(
        text: 'بالتأكيد! سأقوم بالبحث في متجرنا عن بعض المنتجات المميزة لك...',
        isUser: false,
      ));

      try {
        final QuerySnapshot query = await _firestore
            .collection('products')
            .limit(10)
            .get();

        if (query.docs.isNotEmpty) {
          final docs = query.docs.toList()..shuffle(Random());
          final selectedDocs = docs.take(3).toList();

          responses.add(ChatMessage(
            text: 'إليك بعض المنتجات الرائعة التي وجدتها لك:',
            isUser: false,
          ));

          for (var doc in selectedDocs) {
            final data = doc.data() as Map<String, dynamic>;
            responses.add(ChatMessage(
              text: 'هل يعجبك هذا المنتج؟',
              isUser: false,
              hasProduct: true,
              productName: data['name'] ?? 'منتج غير معروف',
              productPrice: '${data['price'] ?? ''} ريال',
              productDetails: data['description'] ?? 'تفاصيل المنتج غير متوفرة',
            ));
          }
        } else {
          responses.add(ChatMessage(
            text: 'عذراً، لم أتمكن من العثور على منتجات حالياً. حاول مجدداً لاحقاً!',
            isUser: false,
          ));
        }
      } catch (e) {
        responses.add(ChatMessage(
          text: 'حدث خطأ أثناء الاتصال بقاعدة البيانات لجلب المنتجات.',
          isUser: false,
        ));
      }
      return responses;
    }

    // 5. البحث عن محلات / أسواق
    if (_containsAny(text, ['محلات', 'سوق', 'اسواق', 'متجر'])) {
      responses.add(ChatMessage(
        text: 'تطبيقنا يضم العديد من الأسواق والمحلات الرائعة! يمكنك زيارة صفحة "الأسواق" من الشاشة الرئيسية لاستعراض المحلات المتوفرة. سأحضر لك قائمة ببعضها قريباً.',
        isUser: false,
      ));
      return responses;
    }

    // 6. التحيات
    if (_containsAny(text, ['مرحبا', 'السلام', 'اهلا', 'هلا'])) {
      responses.add(ChatMessage(
        text: 'وعليكم السلام! أنا "صراط"، مساعدك الذكي في المتجر. كيف يمكنني مساعدتك اليوم؟ يمكنك أن تطلب مني اقتراح منتجات أو تسألني عن كيفية فتح الحسابات.',
        isUser: false,
      ));
      return responses;
    }

    // 7. الرد الافتراضي
    responses.add(ChatMessage(
      text: 'عذراً، لم أفهم طلبك بالكامل. يمكنك سؤالي عن: \n- اقتراح منتجات\n- كيفية فتح حساب تاجر أو مهني\n- كيفية تتبع الطلبات.',
      isUser: false,
    ));
    
    return responses;
  }

  bool _containsAny(String text, List<String> keywords) {
    for (String keyword in keywords) {
      if (text.contains(keyword)) {
        return true;
      }
    }
    return false;
  }
}
