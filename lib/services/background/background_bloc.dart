import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/services/background/background_events.dart';
import 'package:livit/services/background/background_states.dart';
import 'package:livit/utilities/debug/livit_debugger.dart';

class BackgroundBloc extends Bloc<BackgroundEvent, BackgroundState> {
  final LivitDebugger _debugger = const LivitDebugger('background_bloc', isDebugEnabled: true);
  bool? _isLowEndDevice;
  AnimationSpeed _lastActiveSpeed = AnimationSpeed.normal;
  bool isBackgroundGenerated = false;
  bool _isLockedSpeed = false;
  bool _isStopped = false;
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
    _debugger.debPrint('On generated background from bloc', DebugMessageType.info);
    isBackgroundGenerated = true;
    emit(state.copyWith(isBackgroundGenerated: true));
  }

  void _onOnOrigin(BackgroundOnOrigin event, Emitter<BackgroundState> emit) {
    _debugger.debPrint('On on origin from bloc', DebugMessageType.info);
    final newState = state.copyWith(isGoingToOrigin: false);
    emit(newState);
  }

  Future<bool> checkIsLowEndDevice() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      try {
        _debugger.debPrint('Checking Android device capabilities...', DebugMessageType.info);
        final androidInfo = await deviceInfo.androidInfo;

        final bool isLowApiLevel = androidInfo.version.sdkInt < 24;
        final int totalRam = int.tryParse(androidInfo.supportedAbis[0]) ?? 0;
        final bool isLowRam = totalRam < 3 * 1024 * 1024 * 1024;
        final bool isEmulator = !androidInfo.isPhysicalDevice;

        _isLowEndDevice = isLowApiLevel || isLowRam || isEmulator;
        _debugger.debPrint(
            'Android device check - API: ${androidInfo.version.sdkInt}, RAM: $totalRam, Emulator: $isEmulator', DebugMessageType.info);
      } catch (e) {
        _debugger.debPrint('Error checking Android device: $e', DebugMessageType.error);
        _isLowEndDevice = true;
      }
    }

    if (Platform.isIOS) {
      try {
        _debugger.debPrint('Checking iOS device capabilities...', DebugMessageType.info);
        final iosInfo = await deviceInfo.iosInfo;

        final String model = iosInfo.modelName.toLowerCase().split(' ')[0];
        final String generation = iosInfo.modelName.toLowerCase().split(' ')[1];
        final bool isOldDevice = _isOldIOSDevice(model, generation);
        final bool isSimulator = !iosInfo.isPhysicalDevice;

        _isLowEndDevice = isOldDevice || isSimulator;
        _debugger.debPrint('iOS device check - Model: $model, Generation: $generation, Simulator: $isSimulator', DebugMessageType.info);
      } catch (e) {
        _debugger.debPrint('Error checking iOS device: $e', DebugMessageType.error);
        _isLowEndDevice = true;
      }
    }
    _debugger.debPrint(
        'Device capability result: ${_isLowEndDevice == null ? 'Unknown' : _isLowEndDevice! ? 'Low End' : 'High End'}',
        DebugMessageType.info);
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
      _debugger.debPrint('Animation is locked, not setting speed to maximum', DebugMessageType.warning);
      return;
    }
    if (_isLowEndDevice ?? true) return;
    _debugger.debPrint('Setting speed to maximum', DebugMessageType.info);
    _lastActiveSpeed = AnimationSpeed.veryFast;
    _isStopped = false;
    emit(state.copyWith(
      speed: AnimationSpeed.veryFast,
      interpolationSpeed: 1.0,
      isGoingToOrigin: false,
    ));
  }

  void _onStartLoadingAnimation(BackgroundStartLoadingAnimation event, Emitter<BackgroundState> emit) {
    if (_isLockedSpeed && !event.overrideLock) {
      _debugger.debPrint('Animation is locked, not speeding up', DebugMessageType.warning);
      return;
    }
    if (_isLowEndDevice ?? true) return;
    _debugger.debPrint('Speeding up animation', DebugMessageType.info);
    _lastActiveSpeed = AnimationSpeed.fast;
    _isStopped = false;
    emit(state.copyWith(
      speed: AnimationSpeed.fast,
      isGoingToOrigin: false,
      interpolationSpeed: 1,
    ));
    Future.delayed(const Duration(seconds: 2), () {
      if (!_isStopped) {
        _debugger.debPrint('Setting speed to normal', DebugMessageType.info);
        add(BackgroundSpeedNormal());
      }
    });
  }

  void _onSpeedNormal(BackgroundSpeedNormal event, Emitter<BackgroundState> emit) {
    if (_isLockedSpeed && !event.overrideLock) {
      _debugger.debPrint('Animation is locked, not setting speed to normal', DebugMessageType.warning);
      return;
    }
    if (_isLowEndDevice ?? true) return;
    _debugger.debPrint('Setting normal speed', DebugMessageType.info);
    _lastActiveSpeed = AnimationSpeed.normal;
    _isStopped = false;
    emit(state.copyWith(
      speed: AnimationSpeed.normal,
      interpolationSpeed: 0.2,
      isGoingToOrigin: false,
    ));
  }

  void _onSpeedSlow(BackgroundSpeedSlow event, Emitter<BackgroundState> emit) {
    if (_isLockedSpeed && !event.overrideLock) {
      _debugger.debPrint('Animation is locked, not setting speed to slow', DebugMessageType.warning);
      return;
    }
    if (_isLowEndDevice ?? true) return;
    _debugger.debPrint('Slowing down animation', DebugMessageType.info);
    _lastActiveSpeed = AnimationSpeed.slow;
    _isStopped = false;
    emit(state.copyWith(
      speed: AnimationSpeed.slow,
      interpolationSpeed: 0.05,
      isGoingToOrigin: false,
    ));
  }

  void _onSlowDown(BackgroundSpeedMin event, Emitter<BackgroundState> emit) {
    if (_isLockedSpeed && !event.overrideLock) {
      _debugger.debPrint('Animation is locked, not setting speed to minimum', DebugMessageType.warning);
      return;
    }
    if (_isLowEndDevice ?? true) return;
    _debugger.debPrint('Setting minimum speed', DebugMessageType.info);
    _lastActiveSpeed = AnimationSpeed.verySlow;
    _isStopped = false;
    emit(state.copyWith(
      speed: AnimationSpeed.verySlow,
      interpolationSpeed: 0.05,
      isGoingToOrigin: false,
    ));
  }

  void _onStopLoadingAnimation(BackgroundStopLoadingAnimation event, Emitter<BackgroundState> emit) {
    if (_isLockedSpeed && !event.overrideLock) {
      _debugger.debPrint('Animation is locked, not stopping', DebugMessageType.warning);
      return;
    }
    if (state.speed == AnimationSpeed.stopped) {
      _debugger.debPrint('Animation already stopped', DebugMessageType.info);
      return;
    }
    _lastActiveSpeed = state.speed;
    _debugger.debPrint('Stopping animation', DebugMessageType.stopping);
    _isStopped = true;
    emit(state.copyWith(
      speed: AnimationSpeed.stopped,
      interpolationSpeed: 0.05,
      isGoingToOrigin: true,
    ));
  }

  void _onStartTransitionAnimation(BackgroundStartTransitionAnimation event, Emitter<BackgroundState> emit) {
    if (_isLockedSpeed && !event.overrideLock) {
      _debugger.debPrint('Animation is locked, not starting transition animation', DebugMessageType.warning);
      return;
    }
    _debugger.debPrint('Starting transition animation', DebugMessageType.info);
    emit(state.copyWith(
      speed: AnimationSpeed.fast,
      isGoingToOrigin: false,
      interpolationSpeed: 1,
    ));
  }

  void _onStopTransitionAnimation(BackgroundStopTransitionAnimation event, Emitter<BackgroundState> emit) {
    if (_isLockedSpeed && !event.overrideLock) {
      _debugger.debPrint('Animation is locked, not stopping', DebugMessageType.warning);
      return;
    }
    _isStopped = true;
    _debugger.debPrint('Stopping transition animation', DebugMessageType.stopping);
    emit(state.copyWith(
      isGoingToOrigin: true,
      speed: AnimationSpeed.stopped,
      interpolationSpeed: 0.5,
    ));
  }

  void _onResume(BackgroundResume event, Emitter<BackgroundState> emit) {
    if (_isLowEndDevice ?? true) return;
    _debugger.debPrint('Resuming animation at ${_lastActiveSpeed.name} speed', DebugMessageType.info);
    emit(state.copyWith(
      speed: _lastActiveSpeed,
      interpolationSpeed: _lastActiveSpeed == AnimationSpeed.fast ? 1.0 : 0.05,
      mode: BackgroundMode.dynamic,
    ));
  }

  void _onLockSpeed(BackgroundLockSpeed event, Emitter<BackgroundState> emit) {
    _debugger.debPrint('Locking speed to ${event.speed.name}', DebugMessageType.info);
    _isLockedSpeed = true;
    emit(state.copyWith(
      speed: event.speed,
      interpolationSpeed: event.interpolationSpeed,
      isGoingToOrigin: false,
    ));
  }

  void _onUnlockSpeed(BackgroundUnlockSpeed event, Emitter<BackgroundState> emit) {
    _debugger.debPrint('Unlocking speed', DebugMessageType.info);
    _isLockedSpeed = false;
  }

  void cleanup() {
    _debugger.debPrint('Cleaning up animations', DebugMessageType.info);
    add(BackgroundStopLoadingAnimation());
  }

  @override
  Future<void> close() async {
    _debugger.debPrint('Closing background bloc', DebugMessageType.stopping);
    cleanup();
    return super.close();
  }
}
