import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'transaksi.dart';
import 'login.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({Key? key}) : super(key: key);

  @override
  _RiwayatPageState createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _riwayatTransaksi = [];

 @override
void initState() {
  super.initState();
  _fetchRiwayatTransaksi();

  // Listener untuk tabel 'penjualan'
  _supabase.from('penjualan').stream(primaryKey: ['penjualan_id']).listen((_) {
    if (mounted) _fetchRiwayatTransaksi();
  });

  // Listener untuk tabel 'detail_penjualan'
  _supabase.from('detail_penjualan').stream(primaryKey: ['penjualan_id']).listen((_) {
    if (mounted) _fetchRiwayatTransaksi();
  });
}

Future<void> _fetchRiwayatTransaksi() async {
  try {
    final response = await _supabase
        .from('penjualan')
        .select('penjualan_id, tanggal_penjualan, total_harga, pelanggan(nama_pelanggan), detail_penjualan(produk_id, jumlah_produk, subtotal)')
        .order('penjualan_id', ascending: false);

    setState(() {
      _riwayatTransaksi = List<Map<String, dynamic>>.from(response);
    });
  } catch (error) {
    debugPrint('Error fetching transaction history: $error');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: ListView.builder(
        itemCount: _riwayatTransaksi.length,
        itemBuilder: (context, index) {
          final transaksi = _riwayatTransaksi[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            child: ListTile(
             title: Text('ID Transaksi: ${transaksi['penjualan_id']}'),
subtitle: Text(
  'Tanggal: ${transaksi['tanggal_penjualan']}\n'
  'Pelanggan: ${transaksi['pelanggan'] != null ? transaksi['pelanggan']['nama_pelanggan'] : 'Umum'}\n'
  'Total Harga: Rp ${transaksi['total_harga']}',
),
              trailing: const Icon(Icons.receipt),
            ),
          );
        },
      ),
    );
  }
}
