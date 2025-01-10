import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:simple_chat_ai/chat/chat_bloc.dart';
import 'package:simple_chat_ai/chat/chat_state.dart';
import 'package:simple_chat_ai/logger.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatBloc(),
      child: const ChatView(),
    );
  }
}

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _textController = TextEditingController();
  final String _currentUser = "Ryan Gosling";
  final String _title = 'Ollama Chat';

  @override
  void initState() {
    super.initState();

    context.read<ChatBloc>().stream.listen(
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
    _textController.dispose();
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
          BlocBuilder<ChatBloc, ChatState>(
            buildWhen: (previous, current) =>
                previous.isLoading != current.isLoading,
            builder: (context, state) {
              if (state.isLoading) {
                return const LinearProgressIndicator();
              }
              return const SizedBox.shrink();
            },
          ),
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state.messages.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }

                return ListView.builder(
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
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
                            bottomLeft: Radius.circular(isCurrentUser ? 10 : 0),
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
                            !isCurrentUser && message == state.messages.last
                                ? StreamBuilder<String>(
                                    stream:
                                        _simulateMessageTyping(message.content),
                                    builder: (context, snapshot) {
                                      return Text(snapshot.data ?? '',
                                          style: const TextStyle(fontSize: 16));
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
                    controller: _textController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                      hintText: 'Enter your message...',
                      suffixIcon: IconButton(
                        onPressed: () {
                          context.read<ChatBloc>().add(SendMessage(
                              sender: _currentUser,
                              content: _textController.text));

                          _textController.clear();
                        },
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
}
