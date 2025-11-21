class BundleItem {
  final String name;
  final String description;
  final int price;
  final String provider;

  BundleItem({
    required this.name,
    required this.description,
    required this.price,
    required this.provider,
  });

  // Convert BundleItem to a Map for Firestore
  Map<String, dynamic> toTransactionMap(String paymentMethod) {
    return {
      'name': name,
      'description': description,
      'price': price,
      'provider': provider,
      'paymentMethod': paymentMethod,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Create a BundleItem from Firestore Map
  factory BundleItem.fromMap(Map<String, dynamic> map) {
    return BundleItem(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? 0,
      provider: map['provider'] ?? 'Unknown',
    );
  }
}
