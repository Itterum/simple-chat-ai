import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:simple_chat_ai/chat/bloc/chat_bloc.dart';
import 'package:simple_chat_ai/chat/bloc/chat_state.dart';
import 'package:simple_chat_ai/chat/models/chat_message_model.dart';
import 'package:simple_chat_ai/chat/models/chat_model.dart';
import 'package:simple_chat_ai/chat/models/chat_session_model.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatBloc>(
      create: (_) => ChatBloc(Chat.init()),
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

  late Chat _chat;

  @override
  void initState() {
    super.initState();
    _chat = context.read<ChatBloc>().state.chat;
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
        children: <Widget>[
          SizedBox(
            width: Platform.isAndroid ? 50 : 200,
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (BuildContext context, ChatState state) {
                return ListView.builder(
                  itemCount: state.chat.sessions.length,
                  itemBuilder: (BuildContext context, int index) {
                    final ChatSession session = state.chat.sessions[index];
                    return Card(
                      child: ListTile(
                        selected: session.id == _chat.currentSessionId,
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
                            _chat.currentSessionId = session.id;
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
              children: <Widget>[
                AppBar(
                  title: Text(_title),
                  centerTitle: true,
                ),
                BlocBuilder<ChatBloc, ChatState>(
                  buildWhen: (ChatState previous, ChatState current) =>
                      previous.isLoading != current.isLoading,
                  builder: (BuildContext context, ChatState state) {
                    if (state.isLoading) {
                      return const LinearProgressIndicator();
                    }
                    return const SizedBox.shrink();
                  },
                ),
                Expanded(
                  child: BlocBuilder<ChatBloc, ChatState>(
                    buildWhen: (ChatState previous, ChatState current) =>
                        previous.chat != current.chat,
                    builder: (BuildContext context, ChatState state) {
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
        onPressed: () => _chat.addNewSession(context.read<ChatBloc>()),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
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
                    _chat.onMessageSent(
                        _textController.text, context.read<ChatBloc>());
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
    final ChatSession session = state.chat.sessions.firstWhere(
      (ChatSession session) => session.id == _chat.currentSessionId,
      orElse: () => ChatSession(id: _chat.currentSessionId, messages: <Message>[]),
    );

    if (session.messages.isEmpty) {
      return const Center(child: Text('No messages yet'));
    }

    return ListView.builder(
      itemCount: session.messages.length,
      itemBuilder: (BuildContext context, int index) {
        final Message message = session.messages[index];
        final bool isCurrentUser = message.sender == _chat.userName;

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
              children: <Widget>[
                Text(
                  message.sender,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCurrentUser ? Colors.blue[800] : Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 5),
                if (!isCurrentUser && message.isTyping)
                  StreamBuilder<String>(
                    stream: _chat
                        .simulateMessageTyping(message.content)
                        .map((String value) {
                      if (value == message.content) {
                        message.isTyping = false;
                      }
                      return value;
                    }),
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      return Text(snapshot.data ?? '',
                          style: const TextStyle(fontSize: 16));
                    },
                  )
                else
                  Text(message.content, style: const TextStyle(fontSize: 16)),
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
}
