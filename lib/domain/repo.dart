
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
