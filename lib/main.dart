import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// ===============================
/// DOMAIN LAYER
/// ===============================

class Stock {
  final String symbol;
  final double price;

  Stock({required this.symbol, required this.price});
}

abstract class MarketRepository {
  Stream<Stock> getLivePrice();
}

class GetLivePrice {
  final MarketRepository repo;

  GetLivePrice(this.repo);

  Stream<Stock> call() => repo.getLivePrice();
}

/// ===============================
/// DATA LAYER
/// ===============================

class WebSocketService {
  WebSocketChannel? _channel;

  Stream<Map<String, dynamic>> connect() {
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://fstream.binance.com/ws/btcusdt@trade'),
    );

    return _channel!.stream.map((event) {
      return json.decode(event);
    });
  }

  void dispose() {
    _channel?.sink.close();
  }
}

class StockModel extends Stock {
  StockModel({required super.symbol, required super.price});

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      symbol: json['s'],
      price: double.parse(json['p']),
    );
  }
}

class MarketRepositoryImpl implements MarketRepository {
  final WebSocketService service;

  MarketRepositoryImpl(this.service);

  @override
  Stream<Stock> getLivePrice() {
    return service.connect().map((data) {
      return StockModel.fromJson(data);
    });
  }
}

/// ===============================
/// PRESENTATION (RIVERPOD)
/// ===============================

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

/// ===============================
/// MAIN APP
/// ===============================

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MarketScreen(),
    );
  }
}

/// ===============================
/// UI SCREEN
/// ===============================

class MarketScreen extends ConsumerWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priceState = ref.watch(priceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E11),
        title: const Text("Market Watch"),
        centerTitle: true,
      ),
      body: Center(
        child: priceState.when(
          data: (stock) => StockCard(stock: stock),
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text(
            "Error: $e",
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}

/// ===============================
/// UI WIDGET
/// ===============================

class StockCard extends StatelessWidget {
  final Stock stock;

  const StockCard({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2329),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 10)
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.show_chart, color: Colors.green, size: 40),
          const SizedBox(height: 10),

          Text(
            stock.symbol,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "₹ ${stock.price.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Live Price",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
