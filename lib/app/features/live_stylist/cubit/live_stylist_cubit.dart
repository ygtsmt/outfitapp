import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:audio_session/audio_session.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sound_stream/sound_stream.dart';
import 'package:comby/core/services/live_agent_service.dart';
import 'package:comby/app/features/closet/data/closet_usecase.dart';
import 'package:comby/core/services/weather_service.dart';
import 'package:comby/core/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
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
    // Check permissions first
    final hasPermissions = await checkPermissions();
    if (!hasPermissions) {
      return;
    }

    emit(state.copyWith(status: LiveStylistStatus.connecting));
    try {
      String? userName;
      final user = _auth.currentUser;
      if (user != null && !user.isAnonymous) {
        // Try fetching full profile or use displayName directly
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

  /// Check if required permissions are granted
  Future<bool> checkPermissions() async {
    emit(state.copyWith(status: LiveStylistStatus.checkingPermissions));

    final cameraStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;

    final isCameraGranted = cameraStatus.isGranted;
    final isMicGranted = micStatus.isGranted;

    emit(state.copyWith(
      isCameraPermissionGranted: isCameraGranted,
      isMicPermissionGranted: isMicGranted,
    ));

    if (isCameraGranted && isMicGranted) {
      return true;
    } else {
      emit(state.copyWith(status: LiveStylistStatus.permissionsDenied));
      return false;
    }
  }

  /// Request missing permissions
  Future<void> requestPermissions() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    final isCameraGranted = statuses[Permission.camera]?.isGranted ?? false;
    final isMicGranted = statuses[Permission.microphone]?.isGranted ?? false;

    emit(state.copyWith(
      isCameraPermissionGranted: isCameraGranted,
      isMicPermissionGranted: isMicGranted,
    ));

    if (isCameraGranted && isMicGranted) {
      // If granted, start the session automatically
      startSession();
    } else {
      // Still missing permissions
      emit(state.copyWith(status: LiveStylistStatus.permissionsDenied));
    }
  }

  Future<void> _initializeAudio() async {
    try {
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
        if (!state.isMicMuted) {
          _agentService.sendAudioChunk(data);

          // Detect if user is speaking based on audio amplitude
          _detectUserSpeaking(data);
        }
      });

      await _recorder.start();
    } catch (e) {
      log('⚠️ Audio Init Error: $e');
      emit(state.copyWith(
          logs: List.from(state.logs)..add("[Audio Error]: $e")));
    }
  }

  void toggleMute() {
    final newMuteStatus = !state.isMicMuted;
    emit(state.copyWith(isMicMuted: newMuteStatus));

    // Optional: Log status change
    final statusMsg = newMuteStatus ? "Microphone Muted" : "Microphone Active";
    emit(state.copyWith(
        logs: List.from(state.logs)..add("[System]: $statusMsg")));
  }

  Timer? _userSpeechStopTimer;

  void _detectUserSpeaking(Uint8List audioData) {
    // Calculate audio amplitude to detect speech
    int sum = 0;
    for (var byte in audioData) {
      sum += (byte - 128).abs(); // Convert to signed and get absolute value
    }
    final avgAmplitude = sum / audioData.length;

    // Threshold for detecting speech (adjust as needed)
    const speechThreshold = 10.0;
    final isSpeaking = avgAmplitude > speechThreshold;

    if (isSpeaking && !state.isUserSpeaking) {
      // User started speaking
      emit(state.copyWith(isUserSpeaking: true));
      _userSpeechStopTimer?.cancel();
    } else if (!isSpeaking && state.isUserSpeaking) {
      // User might have stopped - wait 1 second to confirm
      _userSpeechStopTimer?.cancel();
      _userSpeechStopTimer = Timer(const Duration(seconds: 1), () {
        if (!isClosed) {
          emit(state.copyWith(isUserSpeaking: false));
        }
      });
    }
  }

  Timer? _audioStopTimer;

  void _handleAgentEvent(Map<String, dynamic> event) {
    // Handle Thought Signatures
    if (event.containsKey('thought')) {
      final thought = event['thought'] as String;
      final toolName = event['toolName'] as String?;

      emit(state.copyWith(
        currentThought: thought,
        currentToolName: toolName,
        hasActiveThought: true,
      ));

      // Auto-hide after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (!isClosed && state.currentThought == thought) {
          emit(state.copyWith(hasActiveThought: false));
        }
      });
    }

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

        // Set AI as speaking
        if (!state.isAiSpeaking) {
          emit(state.copyWith(isAiSpeaking: true));
        }

        // Reset timer - stop animation 500ms after last audio chunk
        _audioStopTimer?.cancel();
        _audioStopTimer = Timer(const Duration(milliseconds: 500), () {
          if (!isClosed) {
            emit(state.copyWith(isAiSpeaking: false));
          }
        });
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
            // 1. Get Location Service
            final locationService = LocationService();

            // STEP 1: Check and request PERMISSION first
            final currentPermission = await locationService.checkPermission();
            log('📍 Current location permission: $currentPermission');

            if (currentPermission == LocationPermission.denied) {
              log('📍 Requesting permission...');

              emit(state.copyWith(
                logs: List.from(state.logs)
                  ..add('[System]: Requesting location permission...'),
              ));

              final requestedPermission =
                  await locationService.requestPermission();
              log('📍 Permission request result: $requestedPermission');

              if (requestedPermission == LocationPermission.denied) {
                // Permission denied by user - let AI explain in user's language
                log('📍 Permission denied by user');
                result = {
                  "error": "PERMISSION_DENIED",
                  "error_type": "location_permission",
                  "context":
                      "User denied location permission request. Weather-based recommendations require location access."
                };
                emit(state.copyWith(
                  logs: List.from(state.logs)
                    ..add('[Tool Error]: Location permission denied'),
                ));
                return; // Exit early
              }
            } else if (currentPermission == LocationPermission.deniedForever) {
              log('📍 Permission denied forever');
              result = {
                "error": "PERMISSION_DENIED_FOREVER",
                "error_type": "location_permission",
                "context":
                    "Location permission is permanently denied. User needs to enable it in app settings."
              };
              emit(state.copyWith(
                logs: List.from(state.logs)
                  ..add('[Tool Error]: Location permission denied forever'),
              ));
              return; // Exit early
            }

            // STEP 2: Now check GPS (permission is granted at this point)
            log('📍 Permission granted, checking GPS...');
            final isGpsEnabled =
                await locationService.isLocationServiceEnabled();

            if (!isGpsEnabled) {
              log('📍 GPS is disabled, opening location settings...');

              emit(state.copyWith(
                logs: List.from(state.logs)
                  ..add('[System]: GPS is disabled. Opening settings...'),
              ));

              // Open location settings
              final opened = await locationService.openLocationSettings();
              log('📍 Location settings opened: $opened');

              // Poll for GPS status - Check every 2 seconds for up to 20 seconds
              log('📍 Waiting for user to enable GPS (polling)...');

              bool isNowEnabled = false;
              for (int i = 0; i < 10; i++) {
                await Future.delayed(const Duration(seconds: 2));
                isNowEnabled = await locationService.isLocationServiceEnabled();
                if (isNowEnabled) {
                  log('📍 GPS enabled detected after ${i * 2} seconds');
                  break;
                }
              }

              if (!isNowEnabled) {
                result = {
                  "error": "GPS_DISABLED",
                  "error_type": "location_service",
                  "context":
                      "GPS/location services are disabled. User needs to enable them to get weather data."
                };
                emit(state.copyWith(
                  logs: List.from(state.logs)
                    ..add('[Tool Error]: GPS still disabled after waiting'),
                ));
                return; // Exit early
              } else {
                log('📍 GPS enabled successfully!');
                emit(state.copyWith(
                  logs: List.from(state.logs)
                    ..add('[System]: GPS enabled! Getting location...'),
                ));
              }
            }

            // STEP 3: Get position (both permission and GPS are OK)
            log('📍 Getting current position...');
            final position = await locationService.getCurrentPosition();

            if (position != null) {
              log('📍 Got position: ${position.latitude}, ${position.longitude}');

              // STEP 4: Get Weather
              final weatherService = GetIt.I<WeatherService>();
              final weather = await weatherService.getWeatherByLocation(
                  position.latitude, position.longitude);

              if (weather != null) {
                result = {
                  "temperature": weather.temperatureString,
                  "description": weather.description,
                  "city": weather.cityName,
                };

                emit(state.copyWith(
                  logs: List.from(state.logs)
                    ..add(
                        "[Tool Response]: Weather is ${weather.temperatureString} in ${weather.cityName}"),
                ));
              } else {
                result = {
                  "error": "WEATHER_SERVICE_NULL",
                  "error_type": "weather_service",
                  "context":
                      "Weather service returned no data. This could be a temporary API issue."
                };
              }
            } else {
              result = {
                "error": "LOCATION_DATA_UNAVAILABLE",
                "error_type": "location_service",
                "context":
                    "Could not retrieve location data despite permissions being granted."
              };
              emit(state.copyWith(
                logs: List.from(state.logs)
                  ..add('[Tool Error]: Failed to get position'),
              ));
            }
          } catch (e) {
            log('📍 Weather fetch error: $e');
            result = {
              "error": "WEATHER_FETCH_FAILED",
              "error_type": "system_error",
              "context":
                  "An unexpected error occurred while fetching weather data.",
              "technical_details": e.toString()
            };
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


/* 

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

 */