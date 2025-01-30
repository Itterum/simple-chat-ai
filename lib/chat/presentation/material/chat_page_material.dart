// import 'package:flutter/material.dart';
//
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
//
// import 'package:simple_chat_ai/chat/presentation/ai_bloc.dart';
// import 'package:simple_chat_ai/utils/generate_id.dart';
//
// class ChatPageMaterial extends StatelessWidget {
//   const ChatPageMaterial({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider<ChatBloc>(
//       create: (_) => ChatBloc(Chat.init()),
//       child: const ChatView(),
//     );
//   }
// }
//
// class ChatView extends StatefulWidget {
//   const ChatView({super.key});
//
//   @override
//   State<ChatView> createState() => _ChatViewState();
// }
//
// class _ChatViewState extends State<ChatView> {
//   final TextEditingController _textController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//
//   final String _title = 'Ollama Chat';
//
//   late bool _isSelected;
//
//   void _scrollToEnd() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _textController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_title),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: BlocBuilder<ChatBloc, ChatState>(
//                   builder: (BuildContext context, ChatState state) {
//                     WidgetsBinding.instance
//                         .addPostFrameCallback((_) => _scrollToEnd());
//
//                     return SizedBox(
//                       height: 50,
//                       child: ListView.builder(
//                         controller: _scrollController,
//                         scrollDirection: Axis.horizontal,
//                         itemCount: state.chat.sessions.length,
//                         itemBuilder: (BuildContext context, int index) {
//                           final ChatSession session =
//                               state.chat.sessions[index];
//                           _isSelected =
//                               session.id == state.chat.currentSessionId;
//
//                           return SizedBox(
//                             width: 150,
//                             child: Card(
//                               elevation: _isSelected ? 2 : 0,
//                               color: Colors.grey[200],
//                               shape: RoundedRectangleBorder(
//                                 side: BorderSide(
//                                   color: _isSelected
//                                       ? Theme.of(context).colorScheme.primary
//                                       : Colors.transparent,
//                                   width: 1,
//                                 ),
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                               child: InkWell(
//                                 onTap: () {
//                                   setState(() =>
//                                       state.chat.currentSessionId = session.id);
//                                 },
//                                 child: Center(
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Text(
//                                       session.messages.firstOrNull?.content ??
//                                           'No messages',
//                                       overflow: TextOverflow.ellipsis,
//                                       textAlign: TextAlign.center,
//                                       style: const TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               IconButton(
//                 onPressed: () {
//                   final id = generateShortId();
//
//                   context
//                       .read<ChatBloc>()
//                       .add(CreateSessionEvent(sessionId: id));
//
//                   setState(() => context
//                       .read<ChatBloc>()
//                       .state
//                       .chat
//                       .currentSessionId = id);
//                 },
//                 icon: const Icon(Icons.add),
//               ),
//             ],
//           ),
//           BlocBuilder<ChatBloc, ChatState>(
//             buildWhen: (ChatState previous, ChatState current) =>
//                 previous.isLoading != current.isLoading,
//             builder: (BuildContext context, ChatState state) {
//               if (state.isLoading) {
//                 return const LinearProgressIndicator();
//               }
//
//               return const SizedBox.shrink();
//             },
//           ),
//           Expanded(
//             child: BlocBuilder<ChatBloc, ChatState>(
//               buildWhen: (ChatState previous, ChatState current) =>
//                   previous.chat != current.chat,
//               builder: (BuildContext context, ChatState state) {
//                 return _buildMessagesView(state);
//               },
//             ),
//           ),
//           _buildMessageInput(context.watch<ChatBloc>().state),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMessageInput(ChatState state) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _textController,
//               decoration: InputDecoration(
//                 border: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(8.0)),
//                 ),
//                 hintText: 'Enter your message...',
//                 suffixIcon: IconButton(
//                   onPressed: () {
//                     context.read<ChatBloc>().add(
//                           AddMessageEvent(
//                             sessionId: state.chat.currentSessionId,
//                             message: Message(
//                               sender: state.chat.userName,
//                               content: _textController.text,
//                               timestamp: DateTime.now(),
//                             ),
//                           ),
//                         );
//
//                     _textController.clear();
//                   },
//                   icon: const Icon(Icons.send),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMessagesView(ChatState state) {
//     final ChatSession session = state.chat.sessions.firstWhere(
//       (ChatSession session) => session.id == state.chat.currentSessionId,
//       orElse: () =>
//           ChatSession(id: state.chat.currentSessionId, messages: <Message>[]),
//     );
//
//     if (session.messages.isEmpty) {
//       return Center(child: Text('No messages yet: ${session.id}'));
//     }
//
//     return ListView.builder(
//       itemCount: session.messages.length,
//       itemBuilder: (BuildContext context, int index) {
//         final Message message = session.messages[index];
//         final bool isCurrentUser = message.sender == state.chat.userName;
//
//         return Align(
//           alignment:
//               isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
//           child: Container(
//             margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: isCurrentUser ? Colors.blue[100] : Colors.grey[300],
//               borderRadius: BorderRadius.only(
//                 topLeft: const Radius.circular(10),
//                 topRight: const Radius.circular(10),
//                 bottomLeft: Radius.circular(isCurrentUser ? 10 : 0),
//                 bottomRight: Radius.circular(isCurrentUser ? 0 : 10),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: isCurrentUser
//                   ? CrossAxisAlignment.end
//                   : CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   message.sender,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: isCurrentUser ? Colors.blue[800] : Colors.grey[800],
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 if (!isCurrentUser && message.isTyping)
//                   StreamBuilder<String>(
//                     stream: state.chat
//                         .simulateMessageTyping(message.content)
//                         .map((String value) {
//                       if (value == message.content) {
//                         message.isTyping = false;
//                       }
//                       return value;
//                     }),
//                     builder:
//                         (BuildContext context, AsyncSnapshot<String> snapshot) {
//                       return Text(snapshot.data ?? '',
//                           style: const TextStyle(fontSize: 16));
//                     },
//                   )
//                 else
//                   Text(message.content, style: const TextStyle(fontSize: 16)),
//                 const SizedBox(height: 5),
//                 Text(
//                   DateFormat('HH:mm').format(message.timestamp),
//                   style: const TextStyle(
//                     fontSize: 10,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
