import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'riwayat.dart';


class TransaksiPage extends StatefulWidget {
  const TransaksiPage(String s, {Key? key, required String title}) : super(key: key);

  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _cart = [];
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _customers = [];
  String? _selectedCustomer;
  double _totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _fetchProduk();
    _fetchCustomers();
  }

  Future<void> _fetchProduk() async {
    try {
      final response = await _supabase.from('produk').select();
      setState(() {
        _products = List<Map<String, dynamic>>.from(response as List<dynamic>);
      });
    } catch (error) {
      debugPrint('Error fetching products: $error');
    }
  }

  Future<void> _fetchCustomers() async {
    try {
      final response = await _supabase.from('pelanggan').select();
      setState(() {
        _customers = List<Map<String, dynamic>>.from(response as List<dynamic>);
      });
    } catch (error) {
      debugPrint('Error fetching customers: $error');
    }
  }

 void _addToCart(Map<String, dynamic> product) {
  setState(() {
    // Cek apakah produk sudah ada di keranjang
    final index =
        _cart.indexWhere((item) => item['produk_id'] == product['produk_id']);
    
    if (index != -1) {
      // Jika produk sudah ada, tambahkan jumlahnya
      _cart[index]['quantity'] += 1;
    } else {
      // Jika belum ada, tambahkan produk ke keranjang
      _cart.add({...product, 'quantity': 1});
    }
    
    _calculateTotal();
  });
}


  void _updateCart(Map<String, dynamic> product, int quantity) {
    setState(() {
      final index =
          _cart.indexWhere((item) => item['produk_id'] == product['produk_id']);
      if (index != -1) {
        if (quantity > 0) {
          _cart[index]['quantity'] = quantity;
        } else {
          _cart.removeAt(index);
        }
      }
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    double total = _cart.fold(
      0,
      (sum, item) => sum + (item['harga'] * item['quantity']),
    );
    if (_selectedCustomer != null && _selectedCustomer != 'pelanggan') {
      total -= 1000; // Diskon Rp 1000
    }
    setState(() {
      _totalPrice = total;
    });
  }

 Future<void> _checkout() async {
  if (_cart.isEmpty) return;

  try {
    final response = await _supabase.from('penjualan').insert({
      'tanggal_penjualan': DateTime.now().toIso8601String(),
      'total_harga': _totalPrice,
      'pelanggan_id': _selectedCustomer == 'pelanggan biasa'
          ? null
          : int.parse(_selectedCustomer!),
    }).select();
    final penjualanId = response[0]['penjualan_id'];

    for (final item in _cart) {
      await _supabase.from('detail_penjualan').insert({
        'penjualan_id': penjualanId,
        'produk_id': item['produk_id'],
        'jumlah_produk': item['quantity'],
        'subtotal': item['harga'] * item['quantity'],
      });
    }

    setState(() {
      _cart.clear();
      _selectedCustomer = null;
      _totalPrice = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil!')));

    // 🚀 Pindah ke halaman Riwayat Transaksi setelah transaksi berhasil
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RiwayatPage()),
    );

  } catch (error) {
    debugPrint('Error during checkout: $error');
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat transaksi.')));
  }
}


  Widget _buildProductList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            title: Text(product['nama_produk'],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Harga: Rp ${product['harga']}'),
            trailing: ElevatedButton(
  onPressed: () => _addToCart(product),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color.fromARGB(255, 157, 93, 93), // Button color
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: const Text(
    'Tambah',
    style: TextStyle(color: Colors.white), // Warna teks menjadi putih
              ),
              )
            ),
          );
      }
    );
  }

 Widget _buildCart() {
  return Column(
    children: [
      ..._cart.map((item) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            title: Text(item['nama_produk']),
            subtitle: Text('Harga: Rp ${item['harga']} x ${item['quantity']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => _updateCart(item, item['quantity'] - 1),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _updateCart(item, item['quantity'] + 1),
                ),
              ],
            ),
          ),
        );
      }),
      // Meningkatkan ukuran teks total harga
      ListTile(
        title: const Text(
          'Total Harga',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), // Ukuran font lebih besar
        ),
        trailing: Text(
          'Rp ${_totalPrice.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Ukuran font lebih besar
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: ElevatedButton(
          onPressed: _checkout,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 183, 112, 112), // Bayar button color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          child: const Text('Bayar',
              style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
      Padding(
  padding: const EdgeInsets.only(bottom: 16.0),
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RiwayatPage()),
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueGrey, // Warna tombol
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    ),
    child: const Text(
      'Lihat Riwayat Transaksi',
      style: TextStyle(fontSize: 18, color: Colors.white),
    ),
  ),
),

    ],
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<String>(
                value: _selectedCustomer,
                hint: const Text('Pilih Pelanggan'),
                isExpanded: true,
                items: [
                  const DropdownMenuItem(
                    value: 'pelanggan',
                    child: Text('Pelanggan'),
                  ),
                  ..._customers.map((customer) {
                    return DropdownMenuItem(
                      value: customer['pelanggan_id'].toString(),
                      child: Text(customer['nama_pelanggan']),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCustomer = value;
                    _calculateTotal();
                  });
                },
              ),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Daftar Produk',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            _buildProductList(),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Keranjang Belanja',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            _buildCart(),
          ],
        ),
      ),
    );
  }
}