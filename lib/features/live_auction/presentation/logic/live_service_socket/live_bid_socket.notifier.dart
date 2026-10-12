import 'dart:convert';
import 'dart:developer';
import 'package:dealer/features/live_auction/data/model/bid_activity_model.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class LiveBidSocketState {
  final bool isConnected;
  final BidActivityData? activity;
  final String? error;

  const LiveBidSocketState({
    this.isConnected = false,
    this.activity,
    this.error,
  });

  LiveBidSocketState copyWith({
    bool? isConnected,
    BidActivityData? activity,
    String? error,
  }) {
    return LiveBidSocketState(
      isConnected: isConnected ?? this.isConnected,
      activity: activity ?? this.activity,
      error: error ?? this.error,
    );
  }
}

// lib/features/live_auction/presentation/logic/live_service_socket/live_bid_socket.notifier.dart

class LiveBidSocketNotifier {
  StompClient? _client;
  final Map<String, StompUnsubscribe> _subscriptions = {};
  void Function(Map<String, dynamic> data)? _onMessage;

  bool get isConnected => _client?.connected ?? false;

  void connect({required void Function(Map<String, dynamic> data) onMessage}) {
    _onMessage = onMessage;
    if (_client != null && _client!.connected) return;

    _client = StompClient(
      config: StompConfig(
        url: 'wss://dev.k99x.com/servlet/ws-auction/websocket',
        onConnect: (frame) => log('[Auction WS] Connected'),
        onWebSocketError: (err) => log('[Auction WS] Error: $err'),
        onDisconnect: (frame) => log('[Auction WS] Disconnected'),
        reconnectDelay: const Duration(seconds: 3),
        heartbeatOutgoing: const Duration(seconds: 10),
        heartbeatIncoming: const Duration(seconds: 10),
      ),
    );

    _client?.activate();
  }

  void subscribe(String vehicleId) {
    if (_subscriptions.containsKey(vehicleId)) return;

    final topic = '/topic/auction/$vehicleId';
    log('[Auction WS] Subscribing: $topic');

    final unsubscribe = _client?.subscribe(
      destination: topic,
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final data = jsonDecode(frame.body!) as Map<String, dynamic>;
            _onMessage?.call(data);
          } catch (e) {
            log('[Auction WS] Parse error: $e');
          }
        }
      },
    );

    if (unsubscribe != null) {
      _subscriptions[vehicleId] = unsubscribe;
    }
  }

  void unsubscribe(String vehicleId) {
    if (_subscriptions.containsKey(vehicleId)) {
      _subscriptions[vehicleId]?.call();
      _subscriptions.remove(vehicleId);
      log('[Auction WS] Unsubscribed: $vehicleId');
    }
  }

  void dispose() {
    _subscriptions.forEach((_, unsub) => unsub());
    _subscriptions.clear();
    _client?.deactivate();
    _client = null;
  }
}
