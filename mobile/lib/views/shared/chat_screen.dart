import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String? recipientName;
  const ChatScreen({super.key, this.recipientName});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Hello, I am interested in your waste listing.', 'isMine': false, 'time': '09:00'},
    {'text': 'Thank you! The UCO is available for pickup on Monday.', 'isMine': true, 'time': '09:02'},
    {'text': 'Great. Can we agree on RWF 42,000?', 'isMine': false, 'time': '09:03'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipientName ?? 'Chat'),
        backgroundColor: const Color(0xFF0F4C3A),
        foregroundColor: Colors.white,
      ),
      body: Column(children: [
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _messages.length,
          itemBuilder: (_, i) {
            final m = _messages[i];
            return Align(
              alignment: m['isMine'] ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                decoration: BoxDecoration(
                  color: m['isMine'] ? const Color(0xFF0F4C3A) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(m['text'], style: TextStyle(color: m['isMine'] ? Colors.white : const Color(0xFF111827))),
                  Text(m['time'], style: TextStyle(fontSize: 10, color: m['isMine'] ? Colors.white70 : const Color(0xFF9CA3AF))),
                ]),
              ),
            );
          },
        )),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _msgCtrl,
              decoration: InputDecoration(hintText: 'Type a message...', filled: true, fillColor: const Color(0xFFF3F4F6), border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
            )),
            const SizedBox(width: 8),
            CircleAvatar(backgroundColor: const Color(0xFF0F4C3A), child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 18), onPressed: _send)),
          ]),
        ),
      ]),
    );
  }

  void _send() {
    if (_msgCtrl.text.isEmpty) return;
    setState(() { _messages.add({'text': _msgCtrl.text, 'isMine': true, 'time': 'Now'}); _msgCtrl.clear(); });
  }

  @override
  void dispose() { _msgCtrl.dispose(); super.dispose(); }
}
