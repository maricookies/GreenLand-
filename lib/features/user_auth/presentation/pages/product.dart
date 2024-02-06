import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Interface for managing product data
abstract class ProductManager {
  Future<void> editProduct(String productId, String productName,
      double buyingPrice, String productDescription, String productType, int quantity);
  Future<void> deleteProduct(String productId);
}

// Implementation of ProductManager that manages product data in Firestore
class FirestoreProductManager implements ProductManager {
  @override
  Future<void> editProduct(String productId, String productName,
      double buyingPrice, String productDescription, String productType, int quantity) async {
    await FirebaseFirestore.instance
        .collection('product')
        .doc(productId)
        .update({
      'productName': productName,
      'buyingPrice': buyingPrice,
      'productDescription': productDescription,
      'productType': productType,
      'quantity': quantity,
    });
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await FirebaseFirestore.instance
        .collection('product')
        .doc(productId)
        .delete();
  }
}

// User interface for product management
class ProductUI {
  final ProductManager dataManager;

  ProductUI(this.dataManager);

  Widget buildProductList(
      BuildContext context,
      AsyncSnapshot<QuerySnapshot> snapshot,
      Function(String) editProduct,
      Function(String) deleteProduct) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Center(child: Text('No products available'));
    }
    return ListView.builder(
      itemCount: snapshot.data!.docs.length,
      itemBuilder: (context, index) {
        var product = snapshot.data!.docs[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            title: Text(
              product['productName'],
              style: TextStyle(color: Color(0xFF006032), fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Product ID: ${product.reference.id}',
                    style: TextStyle(fontSize: 11)),
                Text('Buying Price: ${product['buyingPrice']}',
                    style: TextStyle(fontSize: 11)),
                Text('Selling Price: ${product['buyingPrice'] * 1.4}',
                    style: TextStyle(fontSize: 11)),
                Text('Product Description: ${product['productDescription']}',
                    style: TextStyle(fontSize: 11)),
                Text('Product Type: ${product['productType']}',
                    style: TextStyle(fontSize: 11)),
                Text('Quantity: ${product['quantity']}',
                    style: TextStyle(fontSize: 11)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Color(0xFF006032)),
                  onPressed: () => editProduct(product.reference.id),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Color(0xFF006032)),
                  onPressed: () {
                    deleteProduct(product.reference.id);
                    Fluttertoast.showToast(
                        msg: "Delete Success",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Color.fromARGB(255, 173, 50, 50),
                        textColor: Colors.white,
                        fontSize: 16.0);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late TextEditingController _searchController;
  late ProductManager _dataManager;
  late ProductUI _productUI;
  late String _selectedProductType = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _dataManager = FirestoreProductManager();
    _productUI = ProductUI(_dataManager);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showEditProductModal(String productId) async {
    DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
        .collection('product')
        .doc(productId)
        .get();
    TextEditingController _productNameController = TextEditingController();
    TextEditingController _buyingPriceController = TextEditingController();
    TextEditingController _productDescriptionController =
        TextEditingController();
    TextEditingController _productTypeController = TextEditingController();
    TextEditingController _quantityController = TextEditingController();

    _productNameController.text = productSnapshot['productName'];
    _buyingPriceController.text = productSnapshot['buyingPrice'].toString();
    _productDescriptionController.text =
        productSnapshot['productDescription'];
    _productTypeController.text = productSnapshot['productType'];
    _quantityController.text = productSnapshot['quantity'].toString();

    // Set the default value for the dropdown selection
    _selectedProductType = productSnapshot['productType'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16.0,
              right: 16.0,
              top: 16.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Edit Product',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _productNameController,
                  decoration: InputDecoration(labelText: 'Product Name'),
                ),
                SizedBox(height: 8.0),
                TextField(
                  controller: _buyingPriceController,
                  decoration: InputDecoration(labelText: 'Buying Price'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 8.0),
                TextField(
                  controller: _productDescriptionController,
                  decoration: InputDecoration(labelText: 'Product Description'),
                ),
                SizedBox(height: 8.0),
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
                      child: Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Product Type',
                  ),
                ),
                SizedBox(height: 8.0),
                TextField(
                  controller: _quantityController,
                  decoration: InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    await _dataManager.editProduct(
                      productId,
                      _productNameController.text,
                      double.parse(_buyingPriceController.text),
                      _productDescriptionController.text,
                      _selectedProductType,
                      int.parse(_quantityController.text),
                    );
                    Navigator.pop(context);
                    Fluttertoast.showToast(
                      msg: "Changes have been applied successfully",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Color(0xFF006032),
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  },
                  child: Text('Save Changes',
                      style: TextStyle(color: Color(0xFF006032))),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xFFE2F1E5)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductStream(String query) {
    Query productListQuery = FirebaseFirestore.instance.collection('product');
    if (query.isNotEmpty) {
      productListQuery =
          productListQuery.where('productId', isEqualTo: query);
    }

    return StreamBuilder(
      stream: productListQuery.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return _productUI.buildProductList(
          context,
          snapshot,
          _showEditProductModal,
          _dataManager.deleteProduct,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search for a product...',
            suffixIcon: IconButton(
              onPressed: () {
                String query = _searchController.text;
                setState(() {});
              },
              icon: Icon(Icons.search),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color:
                    Color(0xFF006032),
                width: 2,
              ),
            ),
          ),
          cursorColor: Color(0xFF006032),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: _buildProductStream(_searchController.text),
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
        currentIndex: 1,
        selectedItemColor: Color(0xFF006032),
        unselectedItemColor: Color.fromARGB(255, 138, 175, 145),
        onTap: (index) {
          if (index != 1) {
            switch (index) {
              case 0:
                Navigator.pushNamed(context, '/home');
                break;
              case 1:
                Navigator.pushNamed(context, '/product');
                break;
              case 2:
                Navigator.pushNamed(context, '/addproduct');
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
}
