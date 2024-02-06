import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greenland_organicfarm/global/common/product_model.dart';
import 'package:greenland_organicfarm/global/common/toast.dart';

abstract class ProductRepository {
  Future<void> addProduct(Product product);
}

class FirebaseProductRepository implements ProductRepository {
  final FirebaseFirestore firebaseFirestore;

  FirebaseProductRepository(this.firebaseFirestore);

  @override
  Future<void> addProduct(Product product) async {
    try {
      await firebaseFirestore
          .collection('product')
          .doc(product.productId)
          .set(product.toJson());
      showToast(message: 'Product added successfully');
    } catch (e) {
      showToast(message: 'Error adding product to Firestore');
    }
  }
}

class SellingPriceCalculator {
  double calculateSellingPrice(double buyingPrice) {
    return buyingPrice * 1.4;
  }
}

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _productNameController = TextEditingController();
  TextEditingController _productDescriptionController = TextEditingController();
  TextEditingController _buyingPriceController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();

  double _sellingPrice = 0;
  int _lastProductId = 0;

  String _selectedProductType = 'Fruits';

  @override
  void initState() {
    super.initState();
    getLastProductId();
  }

  Future<void> getLastProductId() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('product').get();

    if (snapshot.docs.isNotEmpty) {
      var lastDocument = snapshot.docs.last;
      _lastProductId = int.parse(lastDocument['productId'].substring(2));
    }
  }

  Future<void> _showConfirmationDialog(String productId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Confirm Add Product",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Do you want to add this product to your shop?",
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                "Confirm",
                style: TextStyle(color: Color(0xFF006032)),
              ),
              onPressed: () async {
                await _addProductToFirebase(productId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addProductToFirebase(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('product')
          .doc(productId)
          .set({
        'productId': productId,
        'productName': _productNameController.text,
        'productDescription': _productDescriptionController.text,
        'buyingPrice':
            double.parse(_buyingPriceController.text.replaceAll(',', '.')),
        'sellingPrice': _sellingPrice,
        'productType': _selectedProductType,
        'quantity': int.parse(
            _quantityController.text), // Include quantity in Firestore
      });

      showToast(message: 'Product added successfully');

      Future.delayed(Duration(seconds: 2), () {
        _productNameController.clear();
        _productDescriptionController.clear();
        _buyingPriceController.clear();
        _quantityController.clear(); // Clear quantity controller
        setState(() {
          _sellingPrice = 0;
        });
      });
    } catch (e) {
      showToast(message: 'Error adding product to Firestore');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/home');
          },
          child: Row(
            children: [
              Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color(0xFF006032),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage: AssetImage(
                      'images/logo.png',
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/home');
                },
                child: Text(
                  'Green Land',
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006032),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          // Wrap the Column with SingleChildScrollView
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                TextFormField(
                  controller: _productNameController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    labelStyle: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF006032),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF006032), width: 2.0),
                    ),
                  ),
                  style: TextStyle(color: Color(0xFF006032)),
                  cursorColor: Color(0xFF006032),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter product name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40),
                DropdownButtonFormField<String>(
                  value: _selectedProductType,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedProductType = newValue!;
                    });
                  },
                  items: <String>[
                    'Fruits',
                    'Vegetables',
                    'Grains',
                    'Dairy Products',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          value,
                          style: TextStyle(color: Color(0xFF006032)),
                        ),
                      ),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Product Type',
                    labelStyle: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF006032),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF006032), width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF006032), width: 1.0),
                    ),
                  ),
                  style: TextStyle(color: Color(0xFF006032)),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _productDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Product Description',
                    labelStyle:
                        TextStyle(fontSize: 15, color: Color(0xFF006032)),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF006032), width: 2.0),
                    ),
                  ),
                  style: TextStyle(color: Color(0xFF006032)),
                  cursorColor: Color(0xFF006032),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter product description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _buyingPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Buying Price',
                    labelStyle:
                        TextStyle(fontSize: 15, color: Color(0xFF006032)),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF006032), width: 2.0),
                    ),
                  ),
                  style: TextStyle(color: Color(0xFF006032)),
                  cursorColor: Color(0xFF006032),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter buying price';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    labelStyle:
                        TextStyle(fontSize: 15, color: Color(0xFF006032)),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF006032), width: 2.0),
                    ),
                  ),
                  style: TextStyle(color: Color(0xFF006032)),
                  cursorColor: Color(0xFF006032),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter product quantity';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Text(
                  'Selling Price ( ${_productNameController.text} ): $_sellingPrice MMK',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      double buyingPrice = double.parse(
                          _buyingPriceController.text.replaceAll(',', '.'));
                      SellingPriceCalculator calculator =
                          SellingPriceCalculator();
                      setState(() {
                        _sellingPrice =
                            calculator.calculateSellingPrice(buyingPrice);
                      });
                      _showConfirmationDialog('GL' +
                          (_lastProductId + 1).toString().padLeft(4, '0'));
                    }
                  },
                  child: Text('Calculate Selling Price',
                      style: TextStyle(color: Colors.white)),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xFF006032)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Product',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart),
            label: 'Add Product',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 2,
        selectedItemColor: Color(0xFF006032),
        unselectedItemColor: Color.fromARGB(255, 138, 175, 145),
        onTap: (index) {
          if (index != 2) {
            switch (index) {
              case 0:
                Navigator.pushNamed(context, '/home');
                break;
              case 1:
                Navigator.pushNamed(context, '/product');
                break;
              case 2:
                break;
              case 3:
                Navigator.pushNamed(context, '/profile');
                break;
            }
          }
        },
      ),
    );
  }

  void main() {
    runApp(MaterialApp(
      home: AddProductPage(),
    ));
  }
}

class CalculateSellingPrice {
  double _sellingPrice = 0;

  void calculateSellingPrice(double buyingPrice) {
    _sellingPrice = buyingPrice * 1.4;
  }

  double getSellingPrice() {
    return _sellingPrice;
  }
}
