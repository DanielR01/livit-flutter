import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/services/background/background_events.dart';
import 'package:livit/services/background/background_states.dart';

class BackgroundBloc extends Bloc<BackgroundEvent, BackgroundState> {
  bool? _isLowEndDevice;
  AnimationSpeed _lastActiveSpeed = AnimationSpeed.normal;
  bool isBackgroundGenerated = false;
  bool _isLockedSpeed = false;

  BackgroundBloc()
      : super(BackgroundState(
          speed: AnimationSpeed.normal,
          interpolationSpeed: 0.05,
          mode: BackgroundMode.dynamic,
        )) {
    on<BackgroundGeneratedBackground>(_onGeneratedBackground);
    on<BackgroundOnOrigin>(_onOnOrigin);
    on<BackgroundStartLoadingAnimation>(_onStartLoadingAnimation);
    on<BackgroundSpeedMax>(_onSpeedMax);
    on<BackgroundSpeedNormal>(_onSpeedNormal);
    on<BackgroundSpeedSlow>(_onSpeedSlow);
    on<BackgroundSpeedMin>(_onSlowDown);
    on<BackgroundStopLoadingAnimation>(_onStopLoadingAnimation);
    on<BackgroundResume>(_onResume);
    on<BackgroundStartTransitionAnimation>(_onStartTransitionAnimation);
    on<BackgroundStopTransitionAnimation>(_onStopTransitionAnimation);
    on<BackgroundLockSpeed>(_onLockSpeed);
    on<BackgroundUnlockSpeed>(_onUnlockSpeed);
  }

  void _onGeneratedBackground(BackgroundGeneratedBackground event, Emitter<BackgroundState> emit) {
    debugPrint('🔄 [BackgroundBloc] On generated background from bloc');
    isBackgroundGenerated = true;
    emit(state.copyWith(isBackgroundGenerated: true));
  }

  void _onOnOrigin(BackgroundOnOrigin event, Emitter<BackgroundState> emit) {
    debugPrint('🔄 [BackgroundBloc] On on origin from bloc');
    final newState = state.copyWith(isGoingToOrigin: false);
    emit(newState);
  }

  Future<bool> checkIsLowEndDevice() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      try {
        debugPrint('📱 [BackgroundBloc] Checking Android device capabilities...');
        final androidInfo = await deviceInfo.androidInfo;

        final bool isLowApiLevel = androidInfo.version.sdkInt < 24;
        final int totalRam = int.tryParse(androidInfo.supportedAbis[0]) ?? 0;
        final bool isLowRam = totalRam < 3 * 1024 * 1024 * 1024;
        final bool isEmulator = !androidInfo.isPhysicalDevice;

        _isLowEndDevice = isLowApiLevel || isLowRam || isEmulator;
        debugPrint('📊 [BackgroundBloc] Android device check - API: ${androidInfo.version.sdkInt}, RAM: $totalRam, Emulator: $isEmulator');
      } catch (e) {
        debugPrint('❌ [BackgroundBloc] Error checking Android device: $e');
        _isLowEndDevice = true;
      }
    }

    if (Platform.isIOS) {
      try {
        debugPrint('📱 [BackgroundBloc] Checking iOS device capabilities...');
        final iosInfo = await deviceInfo.iosInfo;

        final String model = iosInfo.modelName.toLowerCase().split(' ')[0];
        final String generation = iosInfo.modelName.toLowerCase().split(' ')[1];
        final bool isOldDevice = _isOldIOSDevice(model, generation);
        final bool isSimulator = !iosInfo.isPhysicalDevice;

        _isLowEndDevice = isOldDevice || isSimulator;
        debugPrint('📊 [BackgroundBloc] iOS device check - Model: $model, Generation: $generation, Simulator: $isSimulator');
      } catch (e) {
        debugPrint('❌ [BackgroundBloc] Error checking iOS device: $e');
        _isLowEndDevice = true;
      }
    }
    debugPrint(
        '🔍 [BackgroundBloc] Device capability result: ${_isLowEndDevice == null ? 'Unknown' : _isLowEndDevice! ? 'Low End' : 'High End'}');
    return _isLowEndDevice ?? true;
  }

  bool _isOldIOSDevice(String model, String generation) {
    final oldDevices = {
      'iphone': 8, // iPhone 8 and below
      'ipad': 6, // iPad 6th gen and below
      'ipod': 7, // iPod Touch 7th gen and below
    };

    for (final device in oldDevices.keys) {
      if (model.contains(device)) {
        final generationInt = int.tryParse(generation) ?? 0;
        return generationInt <= oldDevices[device]!;
      }
    }
    return true; // Conservative approach for unknown models
  }

  void _onSpeedMax(BackgroundSpeedMax event, Emitter<BackgroundState> emit) {
    if (_isLockedSpeed && !event.overrideLock) {
      debugPrint('🚫 [BackgroundBloc] Animation is locked, not setting speed to maximum');
      return;
    }
    if (_isLowEndDevice ?? true) return;
    debugPrint('🚀 [BackgroundBloc] Setting speed to maximum');
    _lastActiveSpeed = AnimationSpeed.veryFast;
    emit(state.copyWith(
      speed: AnimationSpeed.veryFast,
      interpolationSpeed: 1.0,
      isGoingToOrigin: false,
    ));
  }

  void _onStartLoadingAnimation(BackgroundStartLoadingAnimation event, Emitter<BackgroundState> emit) {
    if (_isLockedSpeed && !event.overrideLock) {
      debugPrint('🚫 [BackgroundBloc] Animation is locked, not speeding up');
      return;
    }
    if (_isLowEndDevice ?? true) return;
    debugPrint('⚡ [BackgroundBloc] Speeding up animation');
    _lastActiveSpeed = AnimationSpeed.fast;
    emit(state.copyWith(
      speed: AnimationSpeed.fast,
      isGoingToOrigin: false,
      interpolationSpeed: 1,
    ));
  }

  void _onSpeedNormal(BackgroundSpeedNormal event, Emitter<BackgroundState> emit) {
    if (_isLockedSpeed && !event.overrideLock) {
      debugPrint('🚫 [BackgroundBloc] Animation is locked, not setting speed to normal');
      return;
    }
    if (_isLowEndDevice ?? true) return;
    debugPrint('➡️ [BackgroundBloc] Setting normal speed');
    _lastActiveSpeed = AnimationSpeed.normal;
    emit(state.copyWith(
      speed: AnimationSpeed.normal,
      interpolationSpeed: 0.2,
      isGoingToOrigin: false,
    ));
  }

  void _onSpeedSlow(BackgroundSpeedSlow event, Emitter<BackgroundState> emit) {
    if (_isLockedSpeed && !event.overrideLock) {
      debugPrint('🚫 [BackgroundBloc] Animation is locked, not setting speed to slow');
      return;
    }
    if (_isLowEndDevice ?? true) return;
    debugPrint('🐢 [BackgroundBloc] Slowing down animation');
    _lastActiveSpeed = AnimationSpeed.slow;
    emit(state.copyWith(
      speed: AnimationSpeed.slow,
      interpolationSpeed: 0.05,
      isGoingToOrigin: false,
    ));
  }

  void _onSlowDown(BackgroundSpeedMin event, Emitter<BackgroundState> emit) {
    if (_isLockedSpeed && !event.overrideLock) {
      debugPrint('🚫 [BackgroundBloc] Animation is locked, not setting speed to minimum');
      return;
    }
    if (_isLowEndDevice ?? true) return;
    debugPrint('🦥 [BackgroundBloc] Setting minimum speed');
    _lastActiveSpeed = AnimationSpeed.verySlow;
    emit(state.copyWith(
      speed: AnimationSpeed.verySlow,
      interpolationSpeed: 0.05,
      isGoingToOrigin: false,
    ));
  }

  void _onStopLoadingAnimation(BackgroundStopLoadingAnimation event, Emitter<BackgroundState> emit) {
    if (_isLockedSpeed && !event.overrideLock) {
      debugPrint('🚫 [BackgroundBloc] Animation is locked, not stopping');
      return;
    }
    if (state.speed == AnimationSpeed.stopped) {
      debugPrint('⏹️ [BackgroundBloc] Animation already stopped');
      return;
    }
    _lastActiveSpeed = state.speed;
    debugPrint('⏹️ [BackgroundBloc] Stopping animation');
    emit(state.copyWith(
      speed: AnimationSpeed.stopped,
      interpolationSpeed: 0.05,
      isGoingToOrigin: true,
    ));
  }

  void _onStartTransitionAnimation(BackgroundStartTransitionAnimation event, Emitter<BackgroundState> emit) {
    if (_isLockedSpeed && !event.overrideLock) {
      debugPrint('🚫 [BackgroundBloc] Animation is locked, not starting transition animation');
      return;
    }
    debugPrint('🔄 [BackgroundBloc] Starting transition animation');
    emit(state.copyWith(
      speed: AnimationSpeed.fast,
      isGoingToOrigin: false,
      interpolationSpeed: 1,
    ));
  }

  void _onStopTransitionAnimation(BackgroundStopTransitionAnimation event, Emitter<BackgroundState> emit) {
    if (_isLockedSpeed && !event.overrideLock) {
      debugPrint('🚫 [BackgroundBloc] Animation is locked, not stopping');
      return;
    }
    debugPrint('⏹️ [BackgroundBloc] Stopping transition animation');
    emit(state.copyWith(
      isGoingToOrigin: true,
      speed: AnimationSpeed.stopped,
      interpolationSpeed: 0.5,
    ));
  }

  void _onResume(BackgroundResume event, Emitter<BackgroundState> emit) {
    if (_isLowEndDevice ?? true) return;
    debugPrint('▶️ [BackgroundBloc] Resuming animation at ${_lastActiveSpeed.name} speed');
    emit(state.copyWith(
      speed: _lastActiveSpeed,
      interpolationSpeed: _lastActiveSpeed == AnimationSpeed.fast ? 1.0 : 0.05,
      mode: BackgroundMode.dynamic,
    ));
  }

  void _onLockSpeed(BackgroundLockSpeed event, Emitter<BackgroundState> emit) {
    debugPrint('🔒 [BackgroundBloc] Locking speed to ${event.speed.name}');
    _isLockedSpeed = true;
    emit(state.copyWith(
      speed: event.speed,
      interpolationSpeed: event.interpolationSpeed,
      isGoingToOrigin: false,
    ));
  }

  void _onUnlockSpeed(BackgroundUnlockSpeed event, Emitter<BackgroundState> emit) {
    debugPrint('🔓 [BackgroundBloc] Unlocking speed');
    _isLockedSpeed = false;
  }

  void cleanup() {
    debugPrint('🧹 [BackgroundBloc] Cleaning up animations');
    add(BackgroundStopLoadingAnimation());
  }

  @override
  Future<void> close() async {
    debugPrint('🚫 [BackgroundBloc] Closing background bloc');
    cleanup();
    return super.close();
  }
}
