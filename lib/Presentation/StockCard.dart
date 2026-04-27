
import 'package:flutter/material.dart';
import 'package:websocketapp/Domain/repo.dart';

class StockCardData extends StatelessWidget {
  final Stock stock;

  const StockCardData({super.key, required this.stock});

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