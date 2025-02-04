import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/data_sources/remote_data_source.dart';
import '../../data/repositories/ai_repository.dart';
import '../../data/repositories/chat_repository.dart';
import '../../domain/entities/ai_entity.dart';
import '../../domain/use_cases/ai_use_case.dart';
import '../../domain/use_cases/chat_use_case.dart';
import '../bloc/ai_bloc.dart';
import '../bloc/chat_bloc.dart';

class Chat extends StatelessWidget {
  const Chat({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChatBloc>(
          create: (context) => ChatBloc(
            InitialChatUseCase(
              ChatRepositoryImpl(),
            ),
            GetChatsUseCase(
              ChatRepositoryImpl(),
            ),
            SendMessageToAIUseCase(
              AIRepositoryImpl(
                RemoteDataSource(),
              ),
            ),
          ),
        ),
        BlocProvider<AIBloc>(
          create: (context) => AIBloc(
            GetAIUseCase(
              AIRepositoryImpl(
                RemoteDataSource(),
              ),
            ),
          )..add(GetAIEvent()),
        ),
      ],
      child: const StartChat(),
    );
  }
}

class StartChat extends StatefulWidget {
  const StartChat({super.key});

  @override
  State<StartChat> createState() => _StartChatState();
}

class _StartChatState extends State<StartChat> {
  final TextEditingController _textController = TextEditingController();

  AIEntity? selectedModel;
  List<AIEntity?> allModels = [];

  @override
  void initState() {
    super.initState();
    selectedModel = null;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.add),
        onPressed: () {
          context.read<ChatBloc>().add(InitialChatEvent(selectedModel));
        },
      ),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
              ),
              child: Text(
                'Chats',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
            BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is ChatInitial) {
                  return const SizedBox.shrink();
                }

                if (state is ChatLoading) {
                  return LinearProgressIndicator(
                    color: theme.colorScheme.secondary,
                  );
                }

                if (state is ChatLoaded) {
                  return Column(
                    children: state.chats
                        .map(
                          (chat) => ListTile(
                            title: Text(
                              chat.id,
                              style: theme.textTheme.bodyLarge,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Opening ${chat.id} Model: ${chat.aiEntity?.model}',
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                        .toList(),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              context.read<AIBloc>().add(GetAIEvent());
            },
            icon: const Icon(Icons.refresh),
          ),
          BlocConsumer<AIBloc, AIState>(
            listener: (context, state) {
              if (state is AIError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              if (state is AIInitial) {
                return DropdownMenu<AIEntity>(
                  initialSelection: selectedModel,
                  label: Text(
                    'Select a model',
                    style: theme.textTheme.labelLarge,
                  ),
                  dropdownMenuEntries: [],
                );
              }

              if (state is AILoading) {
                return CircularProgressIndicator(
                    color: theme.colorScheme.secondary);
              }

              if (state is AILoaded) {
                allModels = state.allAI;
                selectedModel ??= state.ai;

                return DropdownMenu<AIEntity?>(
                  initialSelection: selectedModel,
                  hintText: 'Select a model',
                  dropdownMenuEntries: allModels
                      .map((e) =>
                          DropdownMenuEntry(value: e, label: e?.model ?? ''))
                      .toList(),
                  onSelected: (AIEntity? model) {
                    if (model != null) {
                      setState(() {
                        selectedModel = model;
                      });
                      context.read<ChatBloc>().add(InitialChatEvent(model));
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
              width: 600,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _textController,
                    minLines: 1,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      color: theme.colorScheme.primary,
                      onPressed:
                          selectedModel == null || _textController.text.isEmpty
                              ? null
                              : () {
                                  context.read<ChatBloc>().add(
                                        SendMessageEvent(
                                          selectedModel!,
                                          _textController.text.trim(),
                                        ),
                                      );
                                  _textController.clear();
                                },
                      icon: const Icon(Icons.arrow_circle_up),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
