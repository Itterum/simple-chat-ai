import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:simple_chat_ai/chat/chat_bloc.dart';
import 'package:simple_chat_ai/chat/chat_models.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final initialChat = Chat(
      id: Uuid().v4().replaceAll('-', '').substring(0, 8),
      userName: 'Ryan Gosling',
      aiModel: 'codeLlama:7b',
      sessions: [
        ChatSession(
          id: Uuid().v4().replaceAll('-', '').substring(0, 8),
          messages: [],
        ),
      ],
    );

    return BlocProvider(
      create: (_) => ChatBloc(initialChat),
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

  final String _title = 'Ollama Chat';

  late final String _currentUser;
  late final String _currentSessionId;

  @override
  void initState() {
    super.initState();

    final chat = context.read<ChatBloc>().state.chat;
    _currentUser = chat.userName;
    _currentSessionId = chat.sessions.first.id;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 200,
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                return ListView.builder(
                  itemCount: state.chat.sessions.length,
                  itemBuilder: (context, index) {
                    final session = state.chat.sessions[index];
                    return Card(
                      child: ListTile(
                        selected: session.id == _currentSessionId,
                        title: Text(
                          session.messages.firstOrNull?.content ??
                              'No messages',
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          'id: ${session.id}',
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          setState(() {
                            _currentSessionId = session.id;
                          });
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  title: Text(_title),
                  centerTitle: true,
                ),
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
                    buildWhen: (previous, current) =>
                        previous.chat != current.chat,
                    builder: (context, state) {
                      return _buildMessagesView(state);
                    },
                  ),
                ),
                _buildMessageInput(context),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => context.read<ChatBloc>().add(
              CreateSessionEvent(
                sessionId: Uuid().v4().replaceAll('-', '').substring(0, 8),
              ),
            ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Padding(
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
                    context.read<ChatBloc>().add(
                          AddMessageEvent(
                            sessionId: _currentSessionId,
                            message: Message(
                              sender: _currentUser,
                              content: _textController.text.trim(),
                              timestamp: DateTime.now(),
                            ),
                          ),
                        );

                    _textController.clear();
                  },
                  icon: const Icon(Icons.send),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesView(ChatState state) {
    final session = state.chat.sessions.firstWhere(
      (session) => session.id == _currentSessionId,
      orElse: () => ChatSession(id: _currentSessionId, messages: []),
    );

    if (session.messages.isEmpty) {
      return const Center(child: Text('No messages yet'));
    }

    return ListView.builder(
      itemCount: session.messages.length,
      itemBuilder: (context, index) {
        final message = session.messages[index];
        final isCurrentUser = message.sender == _currentUser;

        return Align(
          alignment:
              isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCurrentUser ? Colors.blue[100] : Colors.grey[300],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10),
                topRight: const Radius.circular(10),
                bottomLeft: Radius.circular(isCurrentUser ? 10 : 0),
                bottomRight: Radius.circular(isCurrentUser ? 0 : 10),
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
                    color: isCurrentUser ? Colors.blue[800] : Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 5),
                !isCurrentUser && message == session.messages.last
                    ? StreamBuilder<String>(
                        stream: _simulateMessageTyping(message.content),
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
  }

  Stream<String> _simulateMessageTyping(String fullMessage) async* {
    for (int i = 1; i <= fullMessage.length; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      yield fullMessage.substring(0, i);
    }
  }

  // int _getSelectedSessionIndex(BuildContext context) {
  //   final sessions = context.read<ChatBloc>().state.chat.sessions;
  //   return sessions.indexWhere((session) => session.id == _currentSessionId);
  // }

  // List<NavigationRailDestination> _buildSessionDestinations(
  //     BuildContext context) {
  //   final sessions = context.read<ChatBloc>().state.chat.sessions;
  //   return sessions
  //       .map((session) => NavigationRailDestination(
  //             icon: const Icon(Icons.chat),
  //             selectedIcon: const Icon(Icons.chat_bubble),
  //             label: Text(session.id),
  //           ))
  //       .toList();
  // }

  // void _addNewSession() {
  //   final newSessionId = DateTime.now().millisecondsSinceEpoch.toString();
  //   context.read<ChatBloc>().add(CreateSessionEvent(sessionId: newSessionId));
  //   setState(() {
  //     _currentSessionId = newSessionId;
  //   });
  // }
}
