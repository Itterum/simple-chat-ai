import 'package:flutter/material.dart';
import 'package:simple_chat_ai/logger.dart';
import 'package:simple_chat_ai/model.dart';

class MyChatApp extends StatefulWidget {
  const MyChatApp({super.key});

  @override
  MyChatAppState createState() => MyChatAppState();
}

class MyChatAppState extends State<MyChatApp> {
  final TextEditingController _controller = TextEditingController();
  final ChatProvide chat = ChatProvide();
  final List<Chat> _chatMessages = [];
  final String currentUser = "Ryan Gosling";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    chat.chatStream.listen((newChat) {
      setState(() {
        _chatMessages.add(newChat);
      });
    }, onError: (error) {
      logger.warning('Error in chat stream: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ollama Chat'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (isLoading) const LinearProgressIndicator(),
          Expanded(
            child: _chatMessages.isEmpty
                ? const Center(child: Text('No messages yet'))
                : ListView.builder(
                    itemCount: _chatMessages.length,
                    itemBuilder: (context, index) {
                      final chatMessage = _chatMessages[index];
                      final isCurrentUser = chatMessage.name == currentUser;
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
                                chatMessage.name ?? 'Unknown User',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isCurrentUser
                                      ? Colors.blue[800]
                                      : Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(chatMessage.message ?? ''),
                              const SizedBox(height: 5),
                              Text(
                                chatMessage.time,
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
                        onPressed: isLoading ? null : _sendMessage,
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

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      chat.sendMessage(currentUser, text);
      _controller.clear();
    } catch (e) {
      logger.warning('Failed to send message: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message')),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
