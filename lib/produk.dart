import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'transaksi.dart';

class ProdukPage extends StatefulWidget {
  final String title;
  const ProdukPage(String s, {super.key, required this.title});

  @override
  _ProdukPageState createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> produkList = [];
  // Variabel untuk menampung hasil filter produk
  List<dynamic> filteredProdukList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProduk();

    // Supabase real-time listener
    supabase.from('produk').stream(primaryKey: ['produk_id']).listen((data) {
      print("Real-time update: $data");
      if (mounted && data.isNotEmpty) {
        setState(() {
          produkList = data;
          // Update filteredProdukList agar selalu sinkron dengan produkList
          filteredProdukList = data;
        });
      }
    });
  }
  
  // Fungsi untuk mengambil data produk dari Supabase
  Future<void> _fetchProduk() async {
    try {
      print("Fetching produk...");
      final response = await supabase.from('produk').select();

      if (response != null) {
        // Hapus duplikat dengan `toSet().toList()`
        final uniqueProduk = response.toSet().toList();
        print("Data produk dari Supabase: $uniqueProduk");
        setState(() {
          produkList = uniqueProduk;
          filteredProdukList = uniqueProduk;
        });
      }
    } catch (e) {
      print("Error mengambil data produk: $e");
    }
  }

  // Fungsi untuk menambah produk ke database
  Future<void> _tambahProduk(String nama, double harga, int stok) async {
    try {
      // Cek apakah produk sudah ada di database
      final existingProduk = await supabase
          .from('produk')
          .select()
          .eq('nama_produk', nama)
          .maybeSingle();

      if (existingProduk != null) {
        // Tampilkan pesan bahwa produk sudah terdaftar
        _showAlert("Produk sudah terdaftar", "Produk dengan nama, harga, dan stok '$nama,$harga,$stok' sudah ada dalam daftar.");
        print("Produk sudah ada, stok tidak diperbarui di UI!");
        // Hanya perbarui tampilan UI tanpa menambahkan produk duplikat
        _fetchProduk();
        return;
      }

      // Jika produk belum ada, tambahkan baru
      final response = await supabase.from('produk').insert({
        'nama_produk': nama,
        'harga': harga,
        'stok': stok,
      }).select();

      print("Produk ditambahkan: $response");

      if (response.isNotEmpty) {
        setState(() {
          produkList.add(response.first);
          filteredProdukList = produkList;
        });
      }
    } catch (e) {
      print("Error menambahkan produk: $e");
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Menutup dialog
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk mengedit produk
  Future<void> _editProduk(int id, String nama, double harga, int stok) async {
    try {
      await supabase.from('produk').update({
        'nama_produk': nama,
        'harga': harga,
        'stok': stok
      }).match({'produk_id': id});  // Perbaikan di primary key

      _fetchProduk();
    } catch (e) {
      print("Error mengedit produk: $e");
    }
  }

  // Fungsi untuk menghapus produk
  Future<void> _hapusProduk(int id) async {
    try {
      await supabase.from('produk').delete().match({'produk_id': id});
      _fetchProduk();
    } catch (e) {
      print("Error menghapus produk: $e");
    }
  }

  // Dialog untuk menambah produk
  void _showDialogTambah() {
    String namaProduk = "";
    String hargaProduk = "";
    String stokProduk = "";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Produk'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Nama Produk'),
              onChanged: (value) => namaProduk = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Harga Produk'),
              keyboardType: TextInputType.number,
              onChanged: (value) => hargaProduk = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Stok Produk'),
              keyboardType: TextInputType.number,
              onChanged: (value) => stokProduk = value,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              if (namaProduk.isNotEmpty && hargaProduk.isNotEmpty && stokProduk.isNotEmpty) {
                _tambahProduk(namaProduk, double.parse(hargaProduk), int.parse(stokProduk));
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // Dialog untuk mengedit produk
  void _showDialogEdit(int id, String nama, double harga, int stok) {
    TextEditingController namaController = TextEditingController(text: nama);
    TextEditingController hargaController = TextEditingController(text: harga.toString());
    TextEditingController stokController = TextEditingController(text: stok.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Produk'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Nama Produk'),
              controller: namaController,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Harga Produk'),
              keyboardType: TextInputType.number,
              controller: hargaController,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Stok Produk'),
              keyboardType: TextInputType.number,
              controller: stokController,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              _editProduk(
                id,
                namaController.text,
                double.parse(hargaController.text),
                int.parse(stokController.text),
              );
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // Dialog untuk menghapus produk
  void _showDialogHapus(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              _hapusProduk(id);
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Bagian pencarian
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Cari Produk',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (query) {
                setState(() {
                  filteredProdukList = produkList.where((produk) {
                    return produk['nama_produk']
                        .toString()
                        .toLowerCase()
                        .contains(query.toLowerCase());
                  }).toList();
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProdukList.length,
              itemBuilder: (context, index) {
                final produk = filteredProdukList[index];
                return Card(
                  child: ListTile(
                    title: Text(produk['nama_produk']),
                    subtitle: Text("Rp ${produk['harga']} - Stok: ${produk['stok']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showDialogEdit(
                            produk['produk_id'],
                            produk['nama_produk'],
                            produk['harga'].toDouble(),
                            produk['stok'],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDialogHapus(produk['produk_id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: _showDialogTambah,
        child: const Icon(Icons.add),
      ),
    );
  }
}
