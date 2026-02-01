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
import 'package:comby/core/services/weather_service.dart';
import 'package:comby/core/services/location_service.dart';
import 'package:get_it/get_it.dart';
import 'package:comby/app/features/auth/features/profile/data/profile_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'live_stylist_state.dart';

@injectable
class LiveStylistCubit extends Cubit<LiveStylistState> {
  final LiveAgentService _agentService;
  final ClosetUseCase _closetUseCase;
  final ProfileUseCase _profileUseCase;
  final FirebaseAuth _auth;

  StreamSubscription? _agentSubscription;
  final RecorderStream _recorder = RecorderStream();
  final PlayerStream _player = PlayerStream();

  StreamSubscription? _audioInputSubscription;

  LiveStylistCubit(
    this._agentService,
    this._closetUseCase,
    this._profileUseCase,
    this._auth,
  ) : super(const LiveStylistState());

  Future<void> startSession() async {
    emit(state.copyWith(status: LiveStylistStatus.connecting));
    try {
      String? userName;
      final user = _auth.currentUser;
      if (user != null && !user.isAnonymous) {
        // Try fetching full profile or use displayName directly
        // Using displayName is faster for now
        userName = user.displayName;

        // Fallback to fetching profile if displayName is null but not anon
        if (userName == null) {
          final profile = await _profileUseCase.fetchUserProfile(user.uid);
          userName = profile?.displayName;
        }
      }

      await _agentService.connect(userName: userName);
      await _initializeAudio();

      _agentSubscription = _agentService.eventStream.listen((event) {
        _handleAgentEvent(event);
      });

      emit(state.copyWith(
        status: LiveStylistStatus.connected,
        message: "Connected. Say hello!",
        logs: List.from(state.logs)..add("[System]: Connected to Gemini Live"),
      ));
    } catch (e) {
      log('❌ Session Start Failed: $e');
      emit(state.copyWith(
        status: LiveStylistStatus.error,
        message: "Connection failed: $e",
        logs: List.from(state.logs)..add("[System Error]: $e"),
      ));
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
    // Log Agent Text
    if (event.containsKey('text')) {
      final text = event['text'];
      final newLogs = List<String>.from(state.logs)..add("[Agent]: $text");

      emit(state.copyWith(logs: newLogs));
    }

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

    if (event.containsKey('toolCall')) {
      _handleToolCall(event['toolCall']);
    }

    if (event.containsKey('error')) {
      emit(state.copyWith(
        status: LiveStylistStatus.error,
        message: event['error'],
        logs: List.from(state.logs)..add("[Error]: ${event['error']}"),
      ));
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

        // Add log for tool call
        emit(state.copyWith(
          logs: List.from(state.logs)..add("[Tool Call]: $name ($args)"),
        ));

        Map<String, dynamic> result = {};
        if (name == 'search_wardrobe') {
          // Agent provides list of terms/synonyms directly
          final queryTerms = (args['queries'] as List)
              .map((e) => e.toString().toLowerCase())
              .where((t) => t.isNotEmpty)
              .toList();

          final allItems = await _closetUseCase.getUserClosetItems();

          // Calculate match score for each item
          final scoredItems = allItems.map((item) {
            int score = 0;
            final itemText = [
              item.category,
              item.subcategory,
              item.color,
              item.season,
              item.material,
              item.pattern,
              item.brand,
            ].where((s) => s != null).join(' ').toLowerCase();

            for (final term in queryTerms) {
              if (itemText.contains(term)) {
                score += 1;
              }
            }
            return MapEntry(item, score);
          }).toList();

          // Filter by score > 0 and Sort by Score Descending
          scoredItems.removeWhere((entry) => entry.value == 0);
          scoredItems.sort((a, b) => b.value.compareTo(a.value));

          final matched = scoredItems.take(5).map((e) => e.key).toList();

          result = {
            "content": matched.map((e) {
              return "${e.subcategory ?? e.category} (Color: ${e.color ?? 'N/A'}, Brand: ${e.brand ?? 'Unknown'}, Material: ${e.material ?? 'N/A'}, Season: ${e.season ?? 'Any'})";
            }).join("\n")
          };

          emit(state.copyWith(
            logs: List.from(state.logs)
              ..add("[Tool Response]: Found ${matched.length} items."),
          ));
        }

        if (name == 'get_weather') {
          try {
            // 1. Get Location
            final locationService = LocationService();
            final position = await locationService.getCurrentPosition();

            if (position != null) {
              // 2. Get Weather
              // Assuming WeatherService is registered in GetIt as per WeatherWidget
              final weatherService = GetIt.I<WeatherService>();
              final weather = await weatherService.getWeatherByLocation(
                  position.latitude, position.longitude);

              if (weather != null) {
                result = {
                  "temperature": weather.temperatureString,
                  "description": weather
                      .description, // using description not capitalized for raw
                  "city": weather.cityName,
                };

                emit(state.copyWith(
                  logs: List.from(state.logs)
                    ..add(
                        "[Tool Response]: Weather is ${weather.temperatureString} in ${weather.cityName}"),
                ));
              } else {
                result = {"error": "Weather service returned null"};
              }
            } else {
              result = {"error": "Could not get location"};
            }
          } catch (e) {
            result = {"error": "Weather fetch failed: $e"};
            emit(state.copyWith(
              logs: List.from(state.logs)
                ..add("[Tool Error]: Weather failed $e"),
            ));
          }
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
      emit(state.copyWith(
        logs: List.from(state.logs)..add("[Tool Error]: $e"),
      ));
    }
  }

  void sendVideoFrame(Uint8List bytes) {
    _agentService.sendImageFrame(bytes);
  }

  void copyLogsToClipboard() {
    // UI can access state.logs directly
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
