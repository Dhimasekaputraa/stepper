import 'package:google_generative_ai/google_generative_ai.dart';

class AiInstructorService {

  final String modelName = 'gemini-2.5-flash';
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  AiInstructorService({
    required String apiKey,
    required int age,
    required double weight,
    required int dailyTarget,
    required List<int> last7DaysSteps,
  })
  {
    final systemPrompt = '''
Kamu adalah seorang asisten pelatih kebugaran dan jalan kaki yang suportif, ringkas, dan praktis.
Data pengguna saat ini :
- Usia : $age tahun
- Berat badan : $weight kg
- Target langkah harian : $dailyTarget langkah
- Riwayat 7 hari terakhir (hari terlama ke hari terbaru) : ${last7DaysSteps.join(',')}

Tugasmu :
1. Berikan evaluasi berdasarkan step langkah di dalam satu hari
2. Berikan evaluasi berdasarkan step langkah dalam kurun waktu 7 hari terakhir
3. Jika diminta mengatur jadwal jalan atau peregangan, berikan saran jam spesifik yang realistis beserta durasi atau target langkahnya.
4. Jawab dalam bahasa Indonesia yang santai, memotivasi, lugas, dan tidak bertele-tele.
''';

  _model = GenerativeModel(
    model: modelName,
    apiKey: apiKey,
    systemInstruction: Content.system(systemPrompt),
    );

    _chatSession = _model.startChat();
  }

  Future<String> sendMessage(String userMessage) async {
    try{
      final response = await _chatSession.sendMessage(
        Content.text(userMessage),
      );
      return response.text ?? 'Maaf, asisten tidak dapat merespons.';
    } catch (e) {
      return 'Terjadi kesalahan koneksi AI : $e';
    }
  }
}