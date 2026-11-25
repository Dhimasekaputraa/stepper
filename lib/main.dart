import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'services/ai_instructor_service.dart';

void main() {
  const apiKey = String.fromEnvironment('GEMINI_API_KEY');
  runApp(const MyApp(apiKey: apiKey));
}

class MyApp extends StatelessWidget {
  final String apiKey;
  const MyApp({super.key, required this.apiKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: AiInstructorTest(apiKey: apiKey),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class AiInstructorTest extends StatefulWidget {
  final String apiKey;
  const AiInstructorTest({super.key, required this.apiKey});
  
  @override
  State<AiInstructorTest> createState() => _AiInstructorTest();
}

class _AiInstructorTest extends State<AiInstructorTest> {
  late final AiInstructorService _instructorService;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Hi stepper, Mau mulai dari mana?',
      isUser: false)
  ];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _instructorService = AiInstructorService(
      apiKey: widget.apiKey,
      age: 21,
      weight: 50,
      dailyTarget: 7000,
      last7DaysSteps: [4200, 3000, 7000, 8200, 2500, 3100],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(_scrollController.hasClients){
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          );
        }
    });
  }

  Future<void> _askInstructor() async {
    final userText = _controller.text.trim();
    if (userText.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: userText, isUser: true));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    final reply = await _instructorService.sendMessage(userText);

    setState(() {
      _messages.add(ChatMessage(text: reply, isUser: false));
      _isLoading = false;
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Stepper Instructor',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          Row(children: [
            Icon(Icons.auto_awesome, size: 12, color: colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              'Model: ${_instructorService.modelName}',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ]
    )
  ),
  body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatBubble(msg, colorScheme);
              },
            ),
          ),

      if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(minHeight: 2),
            ),

          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1, 
                    maxLines: 5, 
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Tanyakan kepada instructor',
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _isLoading ? null : _askInstructor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message, ColorScheme colorScheme) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
        ),
        child: isUser
            ? Text(
                message.text,
                style: TextStyle(
                  fontSize: 15,
                  color: colorScheme.onPrimaryContainer,
                ),
              )
            : MarkdownBody(
                data: message.text,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: colorScheme.onSurface,
                  ),
                  strong: const TextStyle(fontWeight: FontWeight.bold),
                  em: const TextStyle(fontStyle: FontStyle.italic),
                  listBullet: TextStyle(color: colorScheme.primary),
                ),
              ),
      ),
    );
  }
}