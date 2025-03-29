import 'package:flutter/foundation.dart';

/// Message types for the debugger with corresponding emojis
enum DebugMessageType {
  // Status types
  initializing('🔰'),
  error('❌'),
  done('✅'),
  loading('⏳'),
  waiting('⏱️'),
  info('ℹ️'),
  warning('⚠️'),

  // Data operations
  discarding('🗑️'),
  saving('💾'),
  downloading('📥'),
  uploading('📤'),
  deleting('🗑️'),
  downloaded('📦'),
  creating('🆕'),
  updating('🔄'),
  reading('👁️'),
  verifying('🔍'),

  // Media operations
  exporting('📤'),
  importing('📥'),
  capturing('📸'),
  recording('🎬'),
  playing('▶️'),

  // File operations
  fileTracking('📁'),
  fileSaving('💾'),
  fileDeleting('🗑️'),
  fileMoving('📋'),
  fileCleaning('🧹'),

  // Network operations
  network('🌐'),
  request('📡'),
  response('📨'),
  sending('📤'),
  receiving('📥'),

  // Database operations
  database('🗄️'),
  query('🔍'),
  transaction('💱'),

  // Authentication operations
  auth('🔐'),
  loginOut('🔓'),
  loginIn('🔓'),
  logged('🔒'),
  userCreating('👤'),
  userVerifying('✓'),

  // UI operations
  building('🏗️'),
  rendering('🖌️'),
  interaction('👆'),
  navigation('🧭'),

  // System operations
  starting('🚀'),
  stopping('🛑'),
  restarting('🔄'),

  // Method operations
  methodCalling('📞'),
  methodEntering('⬇️'),
  methodExiting('⬆️'),

  // Payment operations
  payment('💰'),
  paymentTransaction('💳'),

  // Notification operations
  notification('🔔'),

  // Location operations
  location('📍'),
  searchLocation('🔍'),
  gps('🛰️'),

  // Time operations
  scheduling('📅'),
  timer('⏲️'),

  // Error reporting
  reporting('🚨'),

  // General operations
  skipping('⏩'),
  monitoring('🔍'),
  ;

  final String emoji;
  const DebugMessageType(this.emoji);
}

/// A custom debugger for consistent debug message formatting
class LivitDebugger {
  final String viewName;
  final bool isDebugEnabled;

  /// Create a debugger for a specific view
  ///
  /// [viewName] - The name of the view or component (e.g., 'event_creation')
  /// [isDebugEnabled] - Whether debug messages should be printed
  const LivitDebugger(this.viewName, {this.isDebugEnabled = false});

  /// Print a debug message with consistent formatting
  ///
  /// [message] - The message to print
  /// [type] - The type of message (determines the emoji)
  void debPrint(String message, DebugMessageType type) {
    if (!isDebugEnabled) return;

    debugPrint('${type.emoji} [$viewName] $message');
  }

  /// Create a child debugger with a sub-component name
  ///
  /// Useful for creating debuggers for child components while maintaining
  /// the parent context.
  ///
  /// Example:
  /// ```
  /// final eventDebugger = LivitDebugger('event_creation');
  /// final ticketsDebugger = eventDebugger.child('tickets');
  /// // Will print: 🎟️ [event_creation/tickets] Creating new ticket
  /// ticketsDebugger.debPrint('Creating new ticket', DebugMessageType.ticket);
  /// ```
  LivitDebugger child(String childName) {
    return LivitDebugger('$viewName/$childName', isDebugEnabled: isDebugEnabled);
  }
}
