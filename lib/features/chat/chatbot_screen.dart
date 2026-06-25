import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _messages.add({'from': 'user', 'text': text}));
    _ctrl.clear();
    _scrollToBottom();

    // rule-based bot reply with simple location and app-info handling
    Future.delayed(const Duration(milliseconds: 500), () {
      final lower = text.toLowerCase();
      final isBangla = RegExp(r'[\u0980-\u09FF]').hasMatch(text);
      String reply;

      // Location-based queries (English and Bangla keywords)
      final locationKeywords = [
        'location',
        'nearby',
        'near',
        'kasakasi',
        'kasakase',
        'kache',
        'kothai',
        'kothay',
        'nikot',
      ];

      bool mentionsLocation = locationKeywords.any((k) => lower.contains(k));

      if (mentionsLocation) {
        if (isBangla) {
          reply =
              'Apnar location er kache kichu chakri ache:\n'
              '- Dhanmondi: Painter (2 seat)\n'
              '- Gulshan: Rajmistri (3 seat)\n'
              '- Mirpur: Helper (5 seat)\n\n'
              'App e aro details dekhte login korun ba job details dekhar jonno "job details <name>" likhun.';
        } else {
          reply =
              'Nearby jobs found:\n- Dhanmondi: Painter (2 positions)\n- Gulshan: Rajmistri (3 positions)\n- Mirpur: Helper (5 positions)\n\n'
              'To see more details open the job in the app or type "job details <name>".';
        }
      } else if (lower.contains('kormo') ||
          lower.contains('kormobd') ||
          lower.contains('app')) {
        // App information
        if (isBangla) {
          reply =
              'KormoBD app holo ekta local job marketplace: '
              'karmochari/majdoor er jonno job khuja, apply kora, ebong employer der sathe jogajog kora jay. '
              'Profile, job listing, chat, ebong location-based search ache.';
        } else {
          reply =
              'KormoBD is a local job marketplace app: find and apply for nearby jobs, chat with employers, and manage your profile. It supports location-based search and job details.';
        }
      } else if (lower.contains('help') || lower.contains('commands')) {
        reply = isBangla
            ? 'Commands: "job" - list jobs, "nearby" - jobs near you, "kormobd" - about app.'
            : 'Commands: "job" - list jobs, "nearby" - jobs near you, "kormobd" - about app.';
      } else if (lower.contains('job')) {
        reply = isBangla
            ? 'Available jobs: Rajmistri, Painter, Helper. Type "nearby" to see nearby openings.'
            : 'Available jobs: Rajmistri, Painter, Helper. Type "nearby" to see nearby openings.';
      } else if (lower.startsWith('job details')) {
        // simple job details lookup
        final parts = text.split(RegExp(r'\s+'));
        final name = parts.length > 2 ? parts.sublist(2).join(' ') : '';
        if (name.isEmpty) {
          reply = isBangla
              ? 'Job name din. (e.g. job details Painter)'
              : 'Please provide job name. (e.g. job details Painter)';
        } else {
          reply = isBangla
              ? 'Job: $name\nLocation: Dhanmondi\nWage: 500 TK/day\nContact via app.'
              : 'Job: $name\nLocation: Dhanmondi\nWage: 500 TK/day\nContact via app.';
        }
      } else {
        reply = isBangla
            ? 'Dukkho: bujhte pari nai. "help" likhun.'
            : "Sorry, I didn't understand. Type 'help' for options.";
      }

      setState(() => _messages.add({'from': 'bot', 'text': reply}));
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(Map<String, String> m) {
    final isUser = m['from'] == 'user';
    final color = isUser ? Colors.blueAccent : Colors.grey.shade200;
    final textColor = isUser ? Colors.white : Colors.black87;

    return Row(
      mainAxisAlignment: isUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          constraints: const BoxConstraints(maxWidth: 320),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(m['text'] ?? '', style: TextStyle(color: textColor)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chatbot')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) =>
                    _buildMessage(_messages[index]),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _sendMessage,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(14),
                    ),
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
