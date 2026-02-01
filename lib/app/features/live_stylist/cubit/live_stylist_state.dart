part of 'live_stylist_cubit.dart';

abstract class LiveStylistState extends Equatable {
  const LiveStylistState();
  @override
  List<Object?> get props => [];
}

class LiveStylistInitial extends LiveStylistState {}

class LiveStylistConnecting extends LiveStylistState {}

class LiveStylistConnected extends LiveStylistState {
  final String statusMessage;
  const LiveStylistConnected({this.statusMessage = 'Listening...'});

  @override
  List<Object?> get props => [statusMessage];
}

class LiveStylistAgentSpeaking extends LiveStylistState {
  final String text; // Transcript of what agent is saying
  const LiveStylistAgentSpeaking(this.text);
  @override
  List<Object?> get props => [text];
}

class LiveStylistError extends LiveStylistState {
  final String message;
  const LiveStylistError(this.message);
  @override
  List<Object?> get props => [message];
}
