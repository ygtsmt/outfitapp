import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:audio_session/audio_session.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sound_stream/sound_stream.dart';
import 'package:comby/core/services/live_agent_service.dart';
import 'package:comby/app/features/closet/data/closet_usecase.dart';

part 'live_stylist_state.dart';

@injectable
class LiveStylistCubit extends Cubit<LiveStylistState> {
  final LiveAgentService _agentService;
  final ClosetUseCase _closetUseCase;

  StreamSubscription? _agentSubscription;
  final RecorderStream _recorder = RecorderStream();
  final PlayerStream _player = PlayerStream();

  StreamSubscription? _audioInputSubscription;

  LiveStylistCubit(this._agentService, this._closetUseCase)
      : super(LiveStylistInitial());

  Future<void> startSession() async {
    emit(LiveStylistConnecting());
    try {
      await _agentService.connect();
      await _initializeAudio();

      _agentSubscription = _agentService.eventStream.listen((event) {
        _handleAgentEvent(event);
      });

      emit(const LiveStylistConnected(statusMessage: "Connected. Say hello!"));
    } catch (e) {
      log('❌ Session Start Failed: $e');
      emit(LiveStylistError("Connection failed: $e"));
    }
  }

  Future<void> _initializeAudio() async {
    // Initialize Recorder
    // Note: sound_stream defaults to 16000Hz PCM 16-bit Mono on most platforms or auto-detects.
    // Explicit sampleRate setting is recommended if supported by the package version.
    // Based on pub.dev, initialize() takes optional 'sampleRate' (int).
    // Configure Audio Session
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    // Initialize Recorder (Gemini prefers 16kHz for input)
    await _recorder.initialize(sampleRate: 16000);

    // Initialize Player (Gemini Live output is 24kHz)
    await _player.initialize(sampleRate: 24000);
    await _player.start();

    // Start Recording and streaming to Agent
    _audioInputSubscription = _recorder.audioStream.listen((data) {
      // data is Uint8List (PCM)
      _agentService.sendAudioChunk(data);
    });

    await _recorder.start();
  }

  void _handleAgentEvent(Map<String, dynamic> event) {
    if (event.containsKey('audio')) {
      // Play audio chunk
      try {
        String base64Audio = event['audio'];
        Uint8List audioBytes = base64Decode(base64Audio);
        _player.writeChunk(audioBytes);
      } catch (e) {
        log('⚠️ Audio playback error: $e');
      }
    }

    if (event.containsKey('text')) {
      // Transcript could be handled here
    }

    if (event.containsKey('toolCall')) {
      _handleToolCall(event['toolCall']);
    }

    if (event.containsKey('error')) {
      emit(LiveStylistError(event['error']));
    }
  }

  Future<void> _handleToolCall(Map<String, dynamic> toolCall) async {
    try {
      final functionCalls = toolCall['functionCalls'] as List;

      for (var call in functionCalls) {
        final name = call['name'];
        final args = call['args'] as Map<String, dynamic>;
        final id = call['id'];

        log('🛠️ Handling Tool: $name');

        Map<String, dynamic> result = {};
        if (name == 'search_wardrobe') {
          final query = (args['query'] as String).toLowerCase();
          final allItems = await _closetUseCase.getUserClosetItems();
          final matched = allItems
              .where((i) {
                return (i.category?.toLowerCase().contains(query) ?? false) ||
                    (i.subcategory?.toLowerCase().contains(query) ?? false) ||
                    (i.color?.toLowerCase().contains(query) ?? false) ||
                    (i.season?.toLowerCase().contains(query) ?? false) ||
                    (i.material?.toLowerCase().contains(query) ?? false) ||
                    (i.pattern?.toLowerCase().contains(query) ?? false);
              })
              .take(3)
              .toList();

          result = {
            "content": matched.map((e) {
              return "${e.subcategory ?? e.category} (Color: ${e.color ?? 'N/A'}, Brand: ${e.brand ?? 'Unknown'}, Material: ${e.material ?? 'N/A'}, Season: ${e.season ?? 'Any'})";
            }).join("\n")
          };
        }

        final toolResponse = {
          "function_responses": [
            {
              "name": name,
              "response": {"result": result},
              "id": id
            }
          ]
        };
        _agentService.sendToolResponse(toolResponse);
      }
    } catch (e) {
      log('❌ Tool Handle Error: $e');
    }
  }

  void sendVideoFrame(Uint8List bytes) {
    _agentService.sendImageFrame(bytes);
  }

  @override
  Future<void> close() async {
    _agentSubscription?.cancel();
    _audioInputSubscription?.cancel();
    await _recorder.stop();
    await _player.stop();
    await _agentService.disconnect();
    return super.close();
  }
}
