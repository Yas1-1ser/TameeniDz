import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:supabase_flutter/supabase_flutter.dart';

enum RealtimeStatus {
  connecting,
  live,
  retrying,
  failed,
}

class RealtimeState {
  final RealtimeStatus status;
  final int retryCount;
  final String? errorMessage;

  RealtimeState({
    required this.status,
    this.retryCount = 0,
    this.errorMessage,
  });
}

class RealtimeManager {
  final SupabaseClient _supabase;
  final String channelName;
  final void Function(RealtimeChannel channel) onSetupChannel;

  RealtimeChannel? _channel;
  Timer? _retryTimer;
  int _retryCount = 0;
  final int _maxRetries = 5;
  bool _isDisposed = false;

  RealtimeState _currentState = RealtimeState(status: RealtimeStatus.connecting);
  RealtimeState get currentState => _currentState;

  final _stateController = StreamController<RealtimeState>.broadcast();

  Stream<RealtimeState> get stateStream => _stateController.stream;

  RealtimeManager({
    required SupabaseClient supabase,
    required this.channelName,
    required this.onSetupChannel,
  }) : _supabase = supabase;

  void connect() {
    if (_isDisposed) return;
    _emit(RealtimeState(status: RealtimeStatus.connecting));
    _subscribe();
  }

  void _emit(RealtimeState state) {
    _currentState = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  void _subscribe() {
    if (_isDisposed) return;
    
    // Clean up existing channel if any
    _channel?.unsubscribe();
    
    try {
      _channel = _supabase.channel(channelName);
      
      // Allow caller to attach events (e.g. onPostgresChanges)
      onSetupChannel(_channel!);

      _channel!.subscribe((status, [error]) {
        if (_isDisposed) return;
        
        log('Realtime channel status: $status for $channelName');
        
        switch (status) {
          case RealtimeSubscribeStatus.subscribed:
            _retryCount = 0;
            _retryTimer?.cancel();
            _emit(RealtimeState(status: RealtimeStatus.live));
            break;
          case RealtimeSubscribeStatus.timedOut:
          case RealtimeSubscribeStatus.channelError:
          case RealtimeSubscribeStatus.closed:
            _handleDisconnect('Status: $status. Error: $error');
            break;
        }
      });
    } catch (e) {
      log('Error creating channel $channelName: $e');
      _handleDisconnect(e.toString());
    }
  }

  void _handleDisconnect(String error) {
    if (_isDisposed) return;
    
    if (_retryCount >= _maxRetries) {
      _emit(RealtimeState(
        status: RealtimeStatus.failed, 
        retryCount: _retryCount,
        errorMessage: 'Connection failed after $_maxRetries attempts',
      ));
      return;
    }

    _retryCount++;
    // Exponential backoff: 1s, 2s, 4s, 8s, 16s
    final delaySeconds = math.pow(2, _retryCount - 1).toInt();
    
    _emit(RealtimeState(
      status: RealtimeStatus.retrying,
      retryCount: _retryCount,
      errorMessage: 'Retrying in $delaySeconds seconds...',
    ));

    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: delaySeconds), () {
      if (!_isDisposed) {
        _subscribe();
      }
    });
  }

  void retryNow() {
    _retryCount = 0;
    _retryTimer?.cancel();
    connect();
  }

  void dispose() {
    _isDisposed = true;
    _retryTimer?.cancel();
    _channel?.unsubscribe();
    _stateController.close();
  }
}
