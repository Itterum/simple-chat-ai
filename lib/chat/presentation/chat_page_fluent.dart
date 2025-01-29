import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../utils/generate_id.dart';
import '../domain/ai_model.dart';
import '../domain/chat_model.dart';
import '../domain/chat_session_model.dart';
import '../domain/message_model.dart';
import 'chat_bloc.dart';

class ChatPageFluent extends StatelessWidget {
  const ChatPageFluent({super.key});

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
  final ScrollController _scrollController = ScrollController();

  final String _title = 'Ollama Chat';

  int _selectedIndex = 0;

  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(GetModelsEvent());
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (BuildContext context, ChatState state) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());

        final models = state.models;
        var currentModel = state.currentAIModel;

        return NavigationView(
          pane: NavigationPane(
            selected: _selectedIndex,
            onChanged: (int index) {
              setState(() => _selectedIndex = index);
            },
            items: <NavigationPaneItem>[
              PaneItem(
                icon: const Icon(FluentIcons.home),
                title: const Text('Home'),
                body: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      Text(_title),
                      const SizedBox(height: 15),
                      BlocBuilder<ChatBloc, ChatState>(
                        builder: (context, state) {
                          return ComboBox<AIModel>(
                            value: currentModel,
                            items: models?.map<ComboBoxItem<AIModel>>((e) {
                              return ComboBoxItem<AIModel>(
                                value: e,
                                child: Text(e.model),
                              );
                            }).toList(),
                            onChanged: (AIModel? model) {
                              if (model != null) {
                                context
                                    .read<ChatBloc>()
                                    .add(SetCurrentModelEvent(model: model));
                              }
                            },
                            placeholder: const Text('Select a model'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              PaneItemSeparator(),
              PaneItemHeader(header: const Text('Sessions')),
              ...state.chat.sessions.map(
                (ChatSession session) {
                  return PaneItem(
                    icon: const Icon(FluentIcons.chat),
                    title: Text(
                      session.messages.firstOrNull?.content ?? 'No messages',
                      overflow: TextOverflow.ellipsis,
                    ),
                    body: Column(
                      children: [
                        Center(
                          child: Text('Session: ${session.id}'),
                        ),
                        Expanded(
                          child: BlocBuilder<ChatBloc, ChatState>(
                            buildWhen:
                                (ChatState previous, ChatState current) =>
                                    previous.chat != current.chat,
                            builder: (BuildContext context, ChatState state) {
                              return _buildMessagesView(state);
                            },
                          ),
                        ),
                        _buildMessageInput(state),
                      ],
                    ),
                  );
                },
              ),
            ],
            footerItems: [
              PaneItem(
                icon: const Icon(FluentIcons.settings),
                title: const Text('Settings'),
                body: Container(),
              ),
              PaneItemAction(
                icon: const Icon(FluentIcons.add),
                title: const Text('Add'),
                onTap: () {
                  final id = generateShortId();

                  context
                      .read<ChatBloc>()
                      .add(InitialSessionEvent(sessionId: id));

                  setState(() => context
                      .read<ChatBloc>()
                      .state
                      .chat
                      .currentSessionId = id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageInput(ChatState state) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextBox(
              controller: _textController,
              placeholder: 'Enter your message...',
              suffix: IconButton(
                onPressed: () {
                  context.read<ChatBloc>().add(
                        AddMessageEvent(
                          sessionId: state.chat.currentSessionId,
                          model: state.currentAIModel?.model,
                          message: Message(
                            role: state.chat.aiModel?.model,
                            content: _textController.text,
                          ),
                        ),
                      );

                  _textController.clear();
                },
                icon: const Icon(
                  FluentIcons.send,
                  size: 20,
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
      (ChatSession session) => session.id == state.chat.currentSessionId,
      orElse: () =>
          ChatSession(id: state.chat.currentSessionId, messages: <Message>[]),
    );

    if (session.messages.isEmpty) {
      return Center(child: Text('No messages yet: ${session.id}'));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: session.messages.length,
      itemBuilder: (BuildContext context, int index) {
        final Message message = session.messages[index];
        final bool isCurrentUser = message.role == state.chat.aiModel?.model;

        return Align(
          alignment:
              isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCurrentUser ? Colors.blue : Colors.grey,
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
                  message.role ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCurrentUser ? Colors.blue : Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                Text(message.content, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 5),
                // Text(
                //   DateFormat('HH:mm').format(
                //       DateTime.parse(state.chat.aiModel?.modifiedAt ?? '')),
                //   style: const TextStyle(
                //     fontSize: 10,
                //     color: Colors.grey,
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}
