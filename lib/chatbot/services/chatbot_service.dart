import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timberr/chatbot/models/chat_message.dart';
import 'package:timberr/chatbot/services/chatbot_rules_engine.dart';
import 'package:timberr/models/user_onboarding_data.dart';
import 'package:timberr/models/personalization_data.dart';

class ChatbotService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Initialize chatbot for new user (send welcome message)
  Future<void> initializeChatbot() async {
    if (_userId == null) return;

    final chatRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('chatbot_messages');

    final existingMessages = await chatRef.limit(1).get();

    if (existingMessages.docs.isEmpty) {
      // First-time user - send welcome message
      final welcomeMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: "👋 Hi! I'm your sofa expert. I've analyzed your preferences and can help you find the perfect sofa. Ask me anything about your personalized recommendations!",
        sender: MessageSender.bot,
        timestamp: DateTime.now(),
        isRead: false,
      );

      await chatRef.doc(welcomeMessage.id).set(welcomeMessage.toJson());

      // Mark that chatbot has been initialized
      await _firestore.collection('users').doc(_userId).update({
        'chatbot_initialized': true,
        'chatbot_last_message_at': FieldValue.serverTimestamp(),
      });
    }
  }

  // Check if user has unread messages
  Future<int> getUnreadMessageCount() async {
    if (_userId == null) return 0;

    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('chatbot_messages')
        .where('sender', isEqualTo: 'bot')
        .where('is_read', isEqualTo: false)
        .get();

    return snapshot.docs.length;
  }

  // Mark all messages as read
  Future<void> markAllMessagesAsRead() async {
    if (_userId == null) return;

    final unreadMessages = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('chatbot_messages')
        .where('sender', isEqualTo: 'bot')
        .where('is_read', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in unreadMessages.docs) {
      batch.update(doc.reference, {'is_read': true});
    }

    await batch.commit();
  }

  // Send user message
  Future<void> sendUserMessage(String content) async {
    if (_userId == null) return;

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      isRead: true,
    );

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('chatbot_messages')
        .doc(message.id)
        .set(message.toJson());

    // Update last message timestamp
    await _firestore.collection('users').doc(_userId).update({
      'chatbot_last_message_at': FieldValue.serverTimestamp(),
    });

    // Generate bot response
    await _generateBotResponse(content);
  }

  // Generate bot response based on user message
  Future<void> _generateBotResponse(String userMessage) async {
    if (_userId == null) return;

    // Fetch user data
    final userDoc = await _firestore.collection('users').doc(_userId).get();
    final userData = userDoc.data();

    if (userData == null) {
      await _sendBotMessage("I couldn't find your profile. Please complete your onboarding first.");
      return;
    }

    // Parse onboarding and personalization data
    UserOnboardingData? onboarding;
    PersonalizationData? personalization;

    if (userData['onboarding_data'] != null) {
      onboarding = UserOnboardingData.fromJson(userData['onboarding_data']);
    }

    if (userData['personalization_data'] != null) {
      personalization = PersonalizationData.fromJson(userData['personalization_data']);
    }

    // Generate response based on message content
    final response = _processUserQuery(userMessage, onboarding, personalization);
    await _sendBotMessage(response);
  }

  Future<void> _sendBotMessage(String content) async {
    if (_userId == null) return;

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      sender: MessageSender.bot,
      timestamp: DateTime.now(),
      isRead: false,
    );

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('chatbot_messages')
        .doc(message.id)
        .set(message.toJson());

    // Update last message timestamp
    await _firestore.collection('users').doc(_userId).update({
      'chatbot_last_message_at': FieldValue.serverTimestamp(),
    });
  }

  // Process user query and generate response
  String _processUserQuery(
    String query,
    UserOnboardingData? onboarding,
    PersonalizationData? personalization,
  ) {
    final lowerQuery = query.toLowerCase();

    // Check if user hasn't completed onboarding
    if (onboarding == null) {
      return "I see you haven't completed your onboarding yet. Please finish the onboarding process so I can provide personalized recommendations!";
    }

    // Greeting - check for greeting words but exclude if asking questions
    if (!_isAskingQuestion(lowerQuery) && 
        (lowerQuery.contains('hello') ||
        lowerQuery.contains('hi ') ||
        lowerQuery.contains('hey') ||
        lowerQuery.startsWith('hi') ||
        lowerQuery == 'hi')) {
      return "Hello! 👋 I'm here to help you with your sofa selection. What would you like to know?";
    }

    // Color questions - check various color-related keywords
    if (_containsAny(lowerQuery, [
      'color', 'colour', 'shade', 'tone', 'hue',
      'what color', 'which color', 'best color',
      'sofa color', 'color sofa'
    ])) {
      return _generateColorResponse(onboarding, personalization);
    }

    // Material questions - check fabric/material keywords
    if (_containsAny(lowerQuery, [
      'material', 'fabric', 'leather', 'velvet', 'linen',
      'what material', 'which material', 'best material',
      'what fabric', 'which fabric'
    ])) {
      return _generateMaterialResponse(onboarding, personalization);
    }

    // Size/capacity questions
    if (_containsAny(lowerQuery, [
      'size', 'seater', 'capacity', 'big', 'small', 'large',
      'how big', 'how many', 'seat', 'people',
      '2 seater', '3 seater', 'sofa size'
    ])) {
      return _generateSizeResponse(onboarding, personalization);
    }

    // Comfort questions
    if (_containsAny(lowerQuery, [
      'comfort', 'soft', 'firm', 'cushion', 'plush',
      'comfortable', 'cozy', 'support', 'firmness'
    ])) {
      return _generateComfortResponse(onboarding, personalization);
    }

    // Pet-related questions
    if (_containsAny(lowerQuery, [
      'pet', 'dog', 'cat', 'animal', 'fur', 'hair',
      'pet friendly', 'pet-friendly', 'with pets'
    ])) {
      return _generatePetResponse(onboarding, personalization);
    }

    // Style questions
    if (_containsAny(lowerQuery, [
      'style', 'look', 'design', 'aesthetic', 'vibe',
      'modern', 'classic', 'traditional', 'contemporary'
    ])) {
      return _generateStyleResponse(onboarding, personalization);
    }

    // Price/budget questions
    if (_containsAny(lowerQuery, [
      'price', 'cost', 'budget', 'expensive', 'cheap',
      'how much', 'pricing'
    ])) {
      return "Our pricing varies based on customization options. I recommend browsing our catalog to see options that match your preferences. Would you like me to explain your personalized recommendations?";
    }

    // Recommendation request - this should be after specific questions
    if (_containsAny(lowerQuery, [
      'recommend', 'suggestion', 'suggest', 'best',
      'what sofa', 'which sofa', 'help me', 'advice',
      'should i get', 'what do you think'
    ])) {
      return _generateRecommendationResponse(onboarding, personalization);
    }

    // Default response
    return "I can help you with:\n• Sofa recommendations\n• Color suggestions\n• Material options\n• Size and capacity\n• Comfort preferences\n• Style guidance\n\nWhat would you like to know?";
  }

  // Helper to check if query contains any of the keywords
  bool _containsAny(String query, List<String> keywords) {
    return keywords.any((keyword) => query.contains(keyword));
  }

  // Helper to check if user is asking a question
  bool _isAskingQuestion(String query) {
    return query.contains('?') ||
        query.startsWith('what') ||
        query.startsWith('which') ||
        query.startsWith('how') ||
        query.startsWith('why') ||
        query.startsWith('when') ||
        query.startsWith('where');
  }

  String _generateRecommendationResponse(
    UserOnboardingData onboarding,
    PersonalizationData? personalization,
  ) {
    personalization ??= PersonalizationData();
    final recommendation = ChatbotRulesEngine.generateRecommendation(
      onboarding: onboarding,
      personalization: personalization,
    );

    return """Based on your profile, here's what I recommend:

🛋️ Sofa Type: ${recommendation.capacityChoice}
🎨 Color: ${recommendation.baseColor} (shade ${recommendation.shade}/100)
✨ Material: ${recommendation.materialChoice}
📐 Pattern: ${recommendation.patternChoice}
💺 Comfort: ${recommendation.cushionDensity} cushions, ${recommendation.seatDepthCm}cm seat depth
🦵 Style Details: ${recommendation.legs} legs, ${recommendation.stitching} stitching

${recommendation.featureSet.isNotEmpty ? '🔒 Features: ${recommendation.featureSet.join(", ")}' : ''}

This matches your ${recommendation.styleTags.join(", ")} style preference! Would you like more details about any aspect?""";
  }

  String _generateColorResponse(
    UserOnboardingData onboarding,
    PersonalizationData? personalization,
  ) {
    personalization ??= PersonalizationData();
    final recommendation = ChatbotRulesEngine.generateRecommendation(
      onboarding: onboarding,
      personalization: personalization,
    );

    final feeling = onboarding.livingRoomFeeling ?? 'your desired vibe';
    return """For your ${feeling.toLowerCase()} living room, I recommend:

🎨 Base Color: ${recommendation.baseColor} (shade ${recommendation.shade}/100)
✨ Accent Color: ${recommendation.accentColor}

This color choice reflects your ${onboarding.livingStyle ?? 'style'} aesthetic and creates the ${feeling.toLowerCase()} atmosphere you're looking for!""";
  }

  String _generateMaterialResponse(
    UserOnboardingData onboarding,
    PersonalizationData? personalization,
  ) {
    personalization ??= PersonalizationData();
    final recommendation = ChatbotRulesEngine.generateRecommendation(
      onboarding: onboarding,
      personalization: personalization,
    );

    String reasoning = '';
    if (onboarding.hasPets == true) {
      reasoning = ' This is especially good for pet owners as it\'s durable and easy to clean.';
    } else if (onboarding.livingStyle?.toLowerCase().contains('modern') == true) {
      reasoning = ' This complements your modern aesthetic beautifully.';
    } else if (onboarding.livingStyle?.toLowerCase().contains('classic') == true) {
      reasoning = ' This adds elegance to your classic style.';
    }

    return """I recommend ${recommendation.materialChoice} with a ${recommendation.patternChoice} pattern.$reasoning

${recommendation.featureSet.isNotEmpty ? '\nAdditional Features: ${recommendation.featureSet.join(", ")}' : ''}""";
  }

  String _generateSizeResponse(
    UserOnboardingData onboarding,
    PersonalizationData? personalization,
  ) {
    personalization ??= PersonalizationData();
    final recommendation = ChatbotRulesEngine.generateRecommendation(
      onboarding: onboarding,
      personalization: personalization,
    );

    String reasoning = '';
    if (onboarding.hostingFrequency?.toLowerCase().contains('frequent') == true) {
      reasoning = ' Perfect for your frequent hosting needs!';
    } else if (onboarding.homeType?.toLowerCase().contains('apartment') == true) {
      reasoning = ' Ideal for your apartment space.';
    }

    return """Based on your lifestyle, I recommend a ${recommendation.capacityChoice}.$reasoning

This will give you ${recommendation.seatDepthCm}cm of seat depth for optimal comfort.""";
  }

  String _generateComfortResponse(
    UserOnboardingData onboarding,
    PersonalizationData? personalization,
  ) {
    personalization ??= PersonalizationData();
    final recommendation = ChatbotRulesEngine.generateRecommendation(
      onboarding: onboarding,
      personalization: personalization,
    );

    return """For your comfort, I recommend:

💺 Cushion Density: ${recommendation.cushionDensity}
📏 Seat Depth: ${recommendation.seatDepthCm}cm
🪑 Back Support: ${recommendation.backSupport}

This configuration is based on your usage patterns${onboarding.sofaUsageTime != null ? ' (${onboarding.sofaUsageTime} daily use)' : ''} and comfort preferences!""";
  }

  String _generatePetResponse(
    UserOnboardingData onboarding,
    PersonalizationData? personalization,
  ) {
    if (onboarding.hasPets == true) {
      personalization ??= PersonalizationData();
      final recommendation = ChatbotRulesEngine.generateRecommendation(
        onboarding: onboarding,
        personalization: personalization,
      );

      return """Since you have pets, I've selected:

✅ ${recommendation.materialChoice} - durable and easy to clean
✅ ${recommendation.patternChoice} pattern - hides pet hair and marks
✅ Special features: ${recommendation.featureSet.join(", ")}

Your sofa will be both stylish and practical for life with pets! 🐾""";
    } else {
      return "You indicated you don't have pets, so I've focused on comfort and style in my recommendations. If this changes, let me know and I can suggest pet-friendly options!";
    }
  }

  String _generateStyleResponse(
    UserOnboardingData onboarding,
    PersonalizationData? personalization,
  ) {
    personalization ??= PersonalizationData();
    final recommendation = ChatbotRulesEngine.generateRecommendation(
      onboarding: onboarding,
      personalization: personalization,
    );

    return """Your sofa will embody a ${recommendation.styleTags.join(", ")} style with:

🦵 ${recommendation.legs} legs
🧵 ${recommendation.stitching} stitching
🎨 ${recommendation.baseColor} color scheme

This perfectly captures your ${onboarding.livingStyle ?? 'aesthetic'} preferences!""";
  }

  // Stream messages for real-time updates
  Stream<List<ChatMessage>> streamMessages() {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('chatbot_messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromJson(doc.data()))
          .toList();
    });
  }

  // Check if user is first-time (for showing welcome popup)
  Future<bool> isFirstTimeUser() async {
    if (_userId == null) return true;

    final userDoc = await _firestore.collection('users').doc(_userId).get();
    final data = userDoc.data();

    return data?['chatbot_initialized'] != true;
  }
}
