import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'transaksi.dart';

class PelangganPage extends StatefulWidget {
  final String title;

const PelangganPage(String s, {Key? key, required this.title}) : super(key: key);



  @override
  _PelangganPageState createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> pelangganList = [];

  @override
  void initState() {
    super.initState();
    _fetchPelanggan();

    // Supabase real-time listener
    supabase.from('pelanggan').stream(primaryKey: ['pelanggan_id']).listen((data) {
      if (mounted && data.isNotEmpty) {
        setState(() {
          pelangganList = data;
        });
      }
    });
  }

  // Fungsi untuk mengambil data pelanggan dari Supabase
  Future<void> _fetchPelanggan() async {
    try {
      final List<dynamic> response = await supabase.from('pelanggan').select();
      if (mounted) {
        setState(() {
          pelangganList = response;
        });
      }
    } catch (e) {
      print("Error mengambil data pelanggan: $e");
    }
  }

 Future<void> _tambahPelanggan(String nama, String alamat, String nomor_telepon) async {
  try {
    // Cek apakah pelanggan sudah ada di database
    final existingPelanggan = await supabase
        .from('pelanggan')
        .select()
        .eq('nama_pelanggan', nama)
        .maybeSingle();  // maybeSingle() untuk mendapatkan data jika ada

    if (existingPelanggan != null) {
      // Tampilkan pesan bahwa pelanggan sudah terdaftar
      _showAlert("Pelanggan sudah terdaftar", "Pelanggan dengan nama '$nama,$nomor_telepon' sudah ada dalam daftar.");
      print("Pelanggan sudah ada, stok tidak diperbarui di UI!");

      // Jangan lanjutkan proses penambahan pelanggan
      return;
    }

    // Jika pelanggan belum ada, tambahkan baru
    final response = await supabase.from('pelanggan').insert({
      'nama_pelanggan': nama,
      'alamat': alamat,
      'nomor_telepon': nomor_telepon,
    }).select();

    print("Pelanggan ditambahkan: $response");

    if (response.isNotEmpty) {
      setState(() {
        pelangganList.add(response.first);
      });
    }
  } catch (e) {
    print("Error menambahkan pelanggan: $e");
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


  // Fungsi untuk mengedit pelanggan
  Future<void> _editPelanggan(int id, String nama, String alamat, String nomor_telepon) async {
    try {
      await supabase.from('pelanggan').update({
        'nama_pelanggan': nama,
        'alamat': alamat,
        'nomor_telepon': nomor_telepon,
      }).match({'pelanggan_id': id});

      _fetchPelanggan();
    } catch (e) {
      print("Error mengedit pelanggan: $e");
    }
  }

  // Fungsi untuk menghapus pelanggan
  Future<void> _hapusPelanggan(int id) async {
    try {
      await supabase.from('pelanggan').delete().match({'pelanggan_id': id});
      _fetchPelanggan();
    } catch (e) {
      print("Error menghapus pelanggan: $e");
    }
  }

  // Dialog untuk menambah pelanggan
  void _showDialogTambah() {
  String namaPelanggan = "";
  String alamat = "";
  String nomor_telepon = "";

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Tambah Pelanggan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Nama Pelanggan'),
            onChanged: (value) => namaPelanggan = value,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Alamat'),
            onChanged: (value) => alamat = value,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Nomor Telepon'),
            keyboardType: TextInputType.phone,
            onChanged: (value) => nomor_telepon = value,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        TextButton(
          onPressed: () {
            if (namaPelanggan.isNotEmpty && alamat.isNotEmpty && nomor_telepon.isNotEmpty) {
              // Jika data valid, panggil fungsi untuk menambah pelanggan
              _tambahPelanggan(namaPelanggan, alamat, nomor_telepon);
              Navigator.pop(context); // Menutup dialog setelah proses selesai
            } else {
              // Jika data tidak valid, tampilkan peringatan atau tetap di dalam dialog
              _showAlert("Data Tidak Lengkap", "Harap isi semua data dengan benar.");
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    ),
  );
}


  // Dialog untuk mengedit pelanggan
  void _showDialogEdit(int id, String nama, String alamat, String nomor_telepon) {
    TextEditingController namaController = TextEditingController(text: nama);
    TextEditingController alamatController = TextEditingController(text: alamat);
    TextEditingController nomor_teleponController = TextEditingController(text: nomor_telepon);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Pelanggan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Nama Pelanggan'),
              controller: namaController,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Alamat'),
              controller: alamatController,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Nomor Telepon'),
              keyboardType: TextInputType.phone,
              controller: nomor_teleponController,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              _editPelanggan(
                id,
                namaController.text.trim(),
                alamatController.text.trim(),
                nomor_teleponController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // Dialog untuk menghapus pelanggan
  void _showDialogHapus(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pelanggan'),
        content: const Text('Apakah Anda yakin ingin menghapus pelanggan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              _hapusPelanggan(id);
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
      appBar: AppBar(),
      body: ListView.builder(
        itemCount: pelangganList.length,
        itemBuilder: (context, index) {
          final pelanggan = pelangganList[index];
          return Card(
            child: ListTile(
              title: Text(pelanggan['nama_pelanggan']),
              subtitle: Text("Alamat: ${pelanggan['alamat']} - Nomor telepon: ${pelanggan['nomor_telepon']}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showDialogEdit(
                      pelanggan['pelanggan_id'],
                      pelanggan['nama_pelanggan'],
                      pelanggan['alamat'],
                      pelanggan['nomor_telepon'],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDialogHapus(pelanggan['pelanggan_id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: _showDialogTambah,
        child: const Icon(Icons.add),
      ),
    );
  }
}
