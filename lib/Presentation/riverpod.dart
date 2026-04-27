



import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Data/websocket.dart';
import '../Domain/repo.dart';

final webSocketProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  ref.onDispose(service.dispose);
  return service;
});

final repoProvider = Provider<MarketRepository>((ref) {
  return MarketRepositoryImpl(ref.read(webSocketProvider));
});

final priceProvider = StreamProvider<Stock>((ref) {
  final usecase = GetLivePrice(ref.read(repoProvider));
  return usecase();
});