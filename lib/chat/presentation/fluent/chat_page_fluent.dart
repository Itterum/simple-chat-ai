import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_chat_ai/chat/domain/entities/ai_entity.dart';
import 'package:simple_chat_ai/chat/domain/usecases/get_ai_usecase.dart';

import '../../data/datasources/remote_data_source.dart';
import '../../data/repositories/ai_repository_impl.dart';
import '../bloc/ai_bloc.dart';

class ChatPageFluent extends StatelessWidget {
  const ChatPageFluent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AIBloc>(
      create: (context) => AIBloc(
        GetAIUseCase(
          AIRepositoryImpl(
            RemoteDataSource(),
          ),
        ),
      ),
      child: const ChatView(),
    );
  }
}

class AIWidget extends StatelessWidget {
  const AIWidget({super.key});

  @override
  Widget build(BuildContext context) {
    late AIEntity? selectedModel;
    late List<AIEntity>? allModels = [];

    return BlocBuilder<AIBloc, AIState>(
      builder: (context, state) {
        selectedModel = null;
        if (state is AIInitial) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ComboBox<AIEntity>(
                value: selectedModel,
                items: [],
                placeholder: const Text('Select a model'),
              ),
              IconButton(
                icon: const Icon(FluentIcons.refresh),
                onPressed: () => {context.read<AIBloc>().add(GetAIEvent())},
              ),
            ],
          );
        }

        if (state is AILoading) {
          return const Center(child: ProgressRing());
        }

        if (state is AIError) {
          return Center(child: Text(state.message));
        }

        if (state is AILoaded) {
          allModels = state.allAI;
          selectedModel = state.ai;
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ComboBox<AIEntity>(
                  value: selectedModel,
                  items: allModels?.map<ComboBoxItem<AIEntity>>((e) {
                    return ComboBoxItem<AIEntity>(
                      value: e,
                      child: Text(e.model),
                    );
                  }).toList(),
                  onChanged: (AIEntity? model) {
                    context.read<AIBloc>().add(SetCurrentAIEvent(model));
                  },
                  placeholder: const Text('Select a model'),
                ),
                IconButton(
                  icon: const Icon(FluentIcons.refresh),
                  onPressed: () => {context.read<AIBloc>().add(GetAIEvent())},
                ),
              ],
            ),
            selectedModel != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '''
Name: ${selectedModel?.name ?? 'N/A'}
Model: ${selectedModel?.model ?? 'N/A'}
Modified At: ${selectedModel?.modifiedAt ?? 'N/A'}
Size: ${selectedModel?.size ?? 'N/A'}
Digest: ${selectedModel?.digest ?? 'N/A'}
''',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Details:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '''
- Parent model: ${selectedModel?.details.parentModel ?? 'N/A'}
- Format: ${selectedModel?.details.format ?? 'N/A'}
- Family: ${selectedModel?.details.family ?? 'N/A'}
- Families: ${selectedModel?.details.families ?? 'N/A'}
- Parameter size: ${selectedModel?.details.parameterSize ?? 'N/A'}
- Quantization level: ${selectedModel?.details.quantizationLevel ?? 'N/A'}
''',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  )
                : Container(),
          ],
        );
      },
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      pane: NavigationPane(
        // selected: _selectedIndex,
        // onChanged: (int index) {
        //   setState(() => _selectedIndex = index);
        // },
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
                  const AIWidget(),
                ],
              ),
            ),
          ),
          PaneItemSeparator(),
          // PaneItemHeader(header: const Text('Sessions')),
          // ...state.chat.sessions.map(
          //   (ChatSession session) {
          //     return PaneItem(
          //       icon: const Icon(FluentIcons.chat),
          //       title: Text(
          //         session.messages.firstOrNull?.content ?? 'No messages',
          //         overflow: TextOverflow.ellipsis,
          //       ),
          //       body: Column(
          //         children: [
          //           Center(
          //             child: Text('Session: ${session.id}'),
          //           ),
          //           Expanded(
          //             child: BlocBuilder<ChatBloc, ChatState>(
          //               buildWhen:
          //                   (ChatState previous, ChatState current) =>
          //                       previous.chat != current.chat,
          //               builder: (BuildContext context, ChatState state) {
          //                 return _buildMessagesView(state);
          //               },
          //             ),
          //           ),
          //           _buildMessageInput(state),
          //         ],
          //       ),
          //     );
          //   },
          // ),
        ],
        footerItems: [
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('Settings'),
            body: Container(),
          ),
          // PaneItemAction(
          //   icon: const Icon(FluentIcons.add),
          //   title: const Text('Add'),
          //   onTap: () {
          //     final id = generateShortId();
          //
          //     context
          //         .read<ChatBloc>()
          //         .add(InitialSessionEvent(sessionId: id));
          //
          //     setState(() => context
          //         .read<ChatBloc>()
          //         .state
          //         .chat
          //         .currentSessionId = id);
          //   },
          // ),
        ],
      ),
    );
  }

// Widget _buildMessageInput(ChatState state) {
//   return Padding(
//     padding: const EdgeInsets.all(8.0),
//     child: Row(
//       children: [
//         Expanded(
//           child: TextBox(
//             controller: _textController,
//             placeholder: 'Enter your message...',
//             suffix: IconButton(
//               onPressed: () {
//                 context.read<ChatBloc>().add(
//                       AddMessageEvent(
//                         sessionId: state.chat.currentSessionId,
//                         model: state.currentAIModel?.model,
//                         message: Message(
//                           role: state.chat.aiModel?.model,
//                           content: _textController.text,
//                         ),
//                       ),
//                     );
//
//                 _textController.clear();
//               },
//               icon: const Icon(
//                 FluentIcons.send,
//                 size: 20,
//               ),
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildMessagesView(ChatState state) {
//   final ChatSession session = state.chat.sessions.firstWhere(
//     (ChatSession session) => session.id == state.chat.currentSessionId,
//     orElse: () =>
//         ChatSession(id: state.chat.currentSessionId, messages: <Message>[]),
//   );
//
//   if (session.messages.isEmpty) {
//     return Center(child: Text('No messages yet: ${session.id}'));
//   }
//
//   return ListView.builder(
//     controller: _scrollController,
//     itemCount: session.messages.length,
//     itemBuilder: (BuildContext context, int index) {
//       final Message message = session.messages[index];
//       final bool isCurrentUser = message.role == state.chat.aiModel?.model;
//
//       return Align(
//         alignment:
//             isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
//         child: Container(
//           margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: isCurrentUser ? Colors.blue : Colors.grey,
//             borderRadius: BorderRadius.only(
//               topLeft: const Radius.circular(10),
//               topRight: const Radius.circular(10),
//               bottomLeft: Radius.circular(isCurrentUser ? 10 : 0),
//               bottomRight: Radius.circular(isCurrentUser ? 0 : 10),
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: isCurrentUser
//                 ? CrossAxisAlignment.end
//                 : CrossAxisAlignment.start,
//             children: [
//               Text(
//                 message.role ?? '',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: isCurrentUser ? Colors.blue : Colors.grey,
//                 ),
//               ),
//               const SizedBox(height: 5),
//               Text(message.content, style: const TextStyle(fontSize: 16)),
//               const SizedBox(height: 5),
//               // Text(
//               //   DateFormat('HH:mm').format(
//               //       DateTime.parse(state.chat.aiModel?.modifiedAt ?? '')),
//               //   style: const TextStyle(
//               //     fontSize: 10,
//               //     color: Colors.grey,
//               //   ),
//               // ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
}
