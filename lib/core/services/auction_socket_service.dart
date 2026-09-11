import 'dart:convert';
import 'package:dealer/features/live_auction/data/model/bid_activity_model.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class AuctionSocketService {
  StompClient? _client;
  StompUnsubscribe? _unsubscribe;

  void connectAndSubscribe({
    required String vehicleId,
    required void Function(BidActivityData data) onActivityReceived,
    void Function(dynamic error)? onError,
  }) {
    _client = StompClient(
      config: StompConfig(
        url: 'wss://dev.k99x.com/servlet/ws-auction',
        onConnect: (frame) {
          _unsubscribe = _client?.subscribe(
            destination: '/topic/auction/$vehicleId',
            callback: (frame) {
              if (frame.body != null) {
                try {
                  final decoded = jsonDecode(frame.body!);
                  final payload = decoded['data'] ?? decoded;
                  final activity = BidActivityData.fromJson(payload);
                  onActivityReceived(activity);
                } catch (e) {
                  onError?.call(e);
                }
              }
            },
          );
        },
        onWebSocketError: (err) => onError?.call(err),
        reconnectDelay: const Duration(seconds: 3),
      ),
    );

    _client?.activate();
  }

  void disconnect() {
    _unsubscribe?.call();
    _client?.deactivate();
    _client = null;
  }
}
