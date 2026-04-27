import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:websocketapp/Presentation/StockCard.dart';
import 'package:websocketapp/Presentation/riverpod.dart';

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
          data: (stock) => StockCardData(stock: stock),
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