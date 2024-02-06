import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String productId;
  final String productName;
  final String productDescription;
  final double buyingPrice;
  final double sellingPrice;
  final String productType;
  final int quantity;

  Product({
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.productType,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productDescription': productDescription,
      'buyingPrice': buyingPrice,
      'sellingPrice': sellingPrice,
      'productType': productType,
      'quantity': quantity,
    };
  }

  factory Product.fromSnapshot(DocumentSnapshot snapshot) {
    return Product(
      productId: snapshot['productId'],
      productName: snapshot['productName'],
      productDescription: snapshot['productDescription'],
      buyingPrice: snapshot['buyingPrice'],
      sellingPrice: snapshot['sellingPrice'],
      productType: snapshot['productType'],
      quantity: snapshot['quantity'].toInt(), 
    );
  }
}

