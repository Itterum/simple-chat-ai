import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_chat_ai/chat_model.dart';
import 'package:simple_chat_ai/logger.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});

  @override
  ChatWidgetState createState() => ChatWidgetState();
}

class ChatWidgetState extends State<ChatWidget> {
  final TextEditingController _controller = TextEditingController();
  final Chat _chat = Chat(title: 'codeLlama:7b');
  final String _currentUser = "Ryan Gosling";
  final String _title = 'Ollama Chat';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _chat.messageStream.listen(
      (messages) {
        setState(() {});
      },
      onError: (error) {
        logger.warning('Error in chat stream: $error');
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _chat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          Expanded(
            child: _chat.messages.isEmpty
                ? const Center(child: Text('No messages yet'))
                : ListView.builder(
                    itemCount: _chat.messages.length,
                    itemBuilder: (context, index) {
                      final message = _chat.messages[index];
                      final isCurrentUser = message.sender == _currentUser;
                      return Align(
                        alignment: isCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? Colors.blue[100]
                                : Colors.grey[300],
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(10),
                              topRight: const Radius.circular(10),
                              bottomLeft:
                                  Radius.circular(isCurrentUser ? 10 : 0),
                              bottomRight:
                                  Radius.circular(isCurrentUser ? 0 : 10),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: isCurrentUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.sender,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isCurrentUser
                                      ? Colors.blue[800]
                                      : Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 5),
                              !isCurrentUser && message == _chat.messages.last
                                  ? StreamBuilder<String>(
                                      stream: _simulateMessageTyping(
                                          message.content),
                                      builder: (context, snapshot) {
                                        return Text(snapshot.data ?? '',
                                            style:
                                                const TextStyle(fontSize: 16));
                                      },
                                    )
                                  : Text(message.content,
                                      style: const TextStyle(fontSize: 16)),
                              const SizedBox(height: 5),
                              Text(
                                DateFormat('HH:mm').format(message.timestamp),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                      hintText: 'Enter your message...',
                      suffixIcon: IconButton(
                        onPressed: _isLoading ? null : _sendMessage,
                        icon: const Icon(Icons.send),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Stream<String> _simulateMessageTyping(String fullMessage) async* {
    for (int i = 1; i <= fullMessage.length; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      yield fullMessage.substring(0, i);
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final userMessage = Message(
      sender: _currentUser,
      content: text,
      timestamp: DateTime.now(),
    );

    _chat.addMessageToStream(userMessage);

    _controller.clear();

    setState(() {
      _isLoading = true;
    });

    try {
      await _chat.addMessage(_currentUser, text);
    } catch (e) {
      logger.warning('Failed to send message: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
