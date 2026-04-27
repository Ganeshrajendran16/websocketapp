
import 'dart:convert' show json;


import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:websocketapp/Domain/repo.dart';



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