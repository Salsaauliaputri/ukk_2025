import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  }

  Future<void> _fetchRiwayatTransaksi() async {
    try {
      final response = await _supabase
          .from('penjualan')
          .select('penjualan_id, tanggal_penjualan, subtotal, pelanggan_id')
          .order('tanggal_penjualan', ascending: false);

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
                'Total: Rp ${transaksi['subtotal']}', // Menggunakan 'subtotal' sesuai dengan database
              ),
              trailing: const Icon(Icons.receipt),
            ),
          );
        },
      ),
    );
  }
}
