import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:simple_chat_ai/chat/bloc/chat_bloc.dart';
import 'package:simple_chat_ai/chat/bloc/chat_event.dart';
import 'package:simple_chat_ai/chat/bloc/chat_state.dart';
import 'package:simple_chat_ai/chat/models/chat_message_model.dart';
import 'package:simple_chat_ai/chat/models/chat_model.dart';
import 'package:simple_chat_ai/chat/models/chat_session_model.dart';
import 'package:simple_chat_ai/utils/generate_id.dart';

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
                body: Center(child: Text(_title)),
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
                    body: Center(
                      child: Text('Session: ${session.id}'),
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
                      .add(CreateSessionEvent(sessionId: id));

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
}
