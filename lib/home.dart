import 'package:flutter/material.dart';
import 'package:ukk_2025/pelanggan.dart';
import 'package:ukk_2025/transaksi.dart';
import 'login.dart';
import 'produk.dart';

class HomePage extends StatefulWidget {
  const HomePage(String s, {Key? key, required String title}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List halaman yang akan ditampilkan berdasarkan index BottomNavigationBar
  final List<Widget> _pages = [
    const ProdukPage("Produk", title: 'Produk'),
    const PelangganPage("Pelanggan", title: 'Pelanggan'),
    const TransaksiPage("Transaksi", title: 'Transaksi'),
    Center(child: Text("Riwayat")), // Halaman Riwayat (Placeholder)
  ];

  // List judul untuk setiap halaman
  final List<String> _pageTitles = [
    "Produk",
    "Pelanggan",
    "Transaksi",
    "Riwayat"
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
          _pageTitles[_selectedIndex], // Menggunakan title sesuai halaman
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
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  LoginPage("login", title: "Login")),
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
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Produk'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Pelanggan'),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Transaksi'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Riwayat'),
        ],
      ),
    );
  }
}
