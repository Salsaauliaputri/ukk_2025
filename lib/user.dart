import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserPage extends StatefulWidget {
  final String title;

  const UserPage ({Key? key, required this.title}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> userList = [];

 @override
void initState() {
  super.initState();
  _fetchUser();

  // Supabase real-time listener
  supabase.from('user').stream(primaryKey: ['id']).listen((data) {
    print("Real-time update: $data");
    if (mounted) {
     _fetchUser();
    }
  });
}

// Fungsi untuk mengambil data user dari Supabase
Future<void> _fetchUser() async {
  try {
    print("Fetching user...");
    final response = await supabase.from('user').select();
    print("Data user dari Supabase: $response");

    setState(() {
      userList = response;
    });
  } catch (e) {
    print("Error mengambil data user: $e");
  }
}

// Fungsi untuk menambah user ke database
Future<void> _tambahUser(String username, String password) async {
  try {
    final response = await supabase.from('user').insert({
      'username': username,
      'password': password,
    }).select();

    print("User ditambahkan: $response");

    setState(() {
      userList = response;
    });
    print("User list after update: $userList");

  } catch (e) {
    print("Error menambahkan user: $e");
  }
}

// Fungsi untuk mengedit user
Future<void> _editUser(int id, String username, String password) async {
  try {
    await supabase.from('user').update({
      'username': username,
      'password': password,
    }).match({'id': id});

    _fetchUser();  // Refresh the user list after editing
  } catch (e) {
    print("Error mengedit user: $e");
  }
}

// Fungsi untuk menghapus user
Future<void> _hapusUser(int id) async {
  try {
    await supabase.from('user').delete().match({'id': id});
    _fetchUser();  // Refresh the user list after deletion
  } catch (e) {
    print("Error menghapus user: $e");
  }
}

  // Dialog untuk menambah user
  void _showDialogTambah() {
    String username = "";
    String password = "";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Username'),
              onChanged: (value) => username = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              onChanged: (value) => password = value,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              if (username.isNotEmpty && password.isNotEmpty) {
               _tambahUser(username, password);
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // Dialog untuk mengedit user
  void _showDialogEdit(int id, String username, String password) {
    TextEditingController usernameController = TextEditingController(text: username);
    TextEditingController passwordController = TextEditingController(text: password);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Username'),
              controller: usernameController,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              controller: passwordController,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              _editUser(
                id,
                usernameController.text,
                passwordController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // Dialog untuk menghapus user
  void _showDialogHapus(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus User'),
        content: const Text('Apakah Anda yakin ingin menghapus user ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              _hapusUser(id);
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
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Username')),
            DataColumn(label: Text('Password')),
            DataColumn(label: Text('Aksi')),
          ],
          rows: userList.map<DataRow>((user) {
            return DataRow(cells: [
              DataCell(Text(user['username'])),
              DataCell(Text(user['password'])),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showDialogEdit(
                        user['id'],
                        user['username'],
                        user['password'],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDialogHapus(user['id']),
                    ),
                  ],
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: _showDialogTambah,
        child: const Icon(Icons.add),
      ),
    );
  }
}
