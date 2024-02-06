import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:greenland_organicfarm/global/common/toast.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User? _user;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Widget _buildUserDetails(User? user) {
    if (user != null) {
      return Card(
        margin: EdgeInsets.symmetric(horizontal: 40, vertical: 150),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFF006032),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : AssetImage('assets/default_profile_image.png')
                              as ImageProvider,
                ),
              ),
            ),
            SizedBox(height: 20),
            Divider(
              color: Colors.grey,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Name: ${user.displayName}',
                style: TextStyle(color: Color(0xFF006032)),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Email: ${user.email}'),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Encrypted Password: ${user.uid}'),
            ),
          ],
        ),
      );
    } else {
      return CircularProgressIndicator();
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
                    backgroundImage: AssetImage('images/logo.png'),
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
      body: Center(child: _buildUserDetails(_user)),
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
        currentIndex: 3,
        selectedItemColor: Color(0xFF006032),
        unselectedItemColor: Color.fromARGB(255, 138, 175, 145),
        onTap: (index) {
          if (index != 3) {
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
            }
          }
        },
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          FirebaseAuth.instance.signOut();
          showToast(message: "User is successfully signed out");
          Navigator.pushNamed(context, "/login");
        },
        child: Container(
          height: 45,
          width: 100,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 173, 50, 50),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              "Sign out",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
