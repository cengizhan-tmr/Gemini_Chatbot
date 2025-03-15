import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/message.dart';

class ChatProvider extends ChangeNotifier {
  final List<Message> _messages = [];
  List<Message> get messages => _messages;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  late final GenerativeModel model;

  ChatProvider() {
    final apiKey = dotenv.env['API_KEY'] ?? '';
    final model = dotenv.env['MODEL'] ?? '';

    if (apiKey.isEmpty) {
      print('API key is not set. Please add API_KEY to your .env file.');
    }
     if (model.isEmpty) {
      print('MODEL is not set. Please add MODEL to your .env file.');
    }
    model = GenerativeModel(
      model: model,
      apiKey: apiKey,
    );
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Kullanıcı mesajını ekle
    _messages.insert(0, Message(content: content, isUser: true));
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    try {
      final prompt = Content.text('''
      Sen yardımsever bir ebeveynlik danışmanı yapay zekasın. Şu konu hakkında tavsiye ver: $content
      Yanıtların şu özelliklere sahip olmalı:
      - Kısa ve pratik olmalı
      - Kanıta dayalı olmalı
      - Pozitif ebeveynlik tekniklerine odaklanmalı
      - Çocuk gelişimi konusunda bilgi içermeli
      - Tıbbi konularda doktora başvurulması gerektiğini belirtmeli
      ''');

      final response = await model.generateContent([prompt]);
      final botMessage = response.text;

      _messages.insert(
        0,
        Message(content: botMessage ?? 'Üzgünüm, yanıt oluşturulamadı.', isUser: false),
      );
    } catch (e) {
      _messages.insert(
        0,
        Message(
          content: 'Üzgünüm, yanıt oluşturulurken bir hata oluştu.',
          isUser: false,
        ),
      );
    }

    _isLoading = false;
    notifyListeners();
  }
}
