import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/ai_entity.dart';
import '../../domain/usecases/get_ai_usecase.dart';

abstract class AIState {}

class AIInitial extends AIState {}

class AILoading extends AIState {}

class AILoaded extends AIState {
  final AIEntity? ai;
  final List<AIEntity>? allAI;

  AILoaded({this.ai, this.allAI});
}

class AIError extends AIState {
  final String message;

  AIError(this.message);
}

abstract class AIEvent {}

class GetAIEvent extends AIEvent {}

class SetCurrentAIEvent extends AIEvent {
  final AIEntity? ai;

  SetCurrentAIEvent(this.ai);
}

class AIBloc extends Bloc<AIEvent, AIState> {
  final GetAIUseCase getAIUseCase;

  AIBloc(
    this.getAIUseCase,
  ) : super(AIInitial()) {
    on<GetAIEvent>(_onGetAIEvent);
    on<SetCurrentAIEvent>(_onSetCurrentAI);
  }

  Future<void> _onGetAIEvent(GetAIEvent event, Emitter<AIState> emit) async {
    emit(AILoading());

    try {
      final allAI = await getAIUseCase.execute();

      emit(AILoaded(allAI: allAI));
    } catch (e) {
      emit(AIError(e.toString()));
    }
  }

  Future<void> _onSetCurrentAI(
      SetCurrentAIEvent event, Emitter<AIState> emit) async {
    if (state is AILoaded) {
      final currentState = state as AILoaded;
      emit(AILoaded(ai: event.ai, allAI: currentState.allAI));
    }
  }
}
