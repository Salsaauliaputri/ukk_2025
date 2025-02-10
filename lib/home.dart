import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/pelanggan.dart';
import 'package:ukk_2025/user.dart';
import 'login.dart';
import 'produk.dart';

class HomePage extends StatefulWidget {
 final String title; 

  const HomePage({Key? key, required this.title}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List halaman yang akan ditampilkan berdasarkan index BottomNavigationBar
  final List<Widget> _pages = [
    const UserPage(title: 'User'),
    const ProdukPage("Produk", title: 'Produk'),
    const PelangganPage("Pelanggan", title: 'Pelanggan'),

    
    Center(child: Text("User")),       // Halaman User
    Center(child: Text("Produk")),     //Halaman Produk
    Center(child: Text("Pelanggan")), // Halaman Pelanggan (Placeholder)
    Center(child: Text("Transaksi")), // Halaman Transaksi (Placeholder)
    Center(child: Text("Riwayat")),   // Halaman Riwayat (Placeholder)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 224, 149, 149),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Apakah Anda yakin ingin logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                       Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProdukPage("Produk", title: 'Produk')),
                       );
                      },
                      child: const Text('Ya'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex], // Menampilkan halaman yang dipilih
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color.fromARGB(255, 173, 134, 134),
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.red.shade200,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'User'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Produk'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Pelanggan'),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Transaksi'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Riwayat'),
        ],
      ),
    );
  }
}
