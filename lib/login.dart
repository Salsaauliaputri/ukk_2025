import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home.dart';
import 'produk.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String _usernameError = '';
  String _passwordError = '';

  Future<void> _login() async {
    setState(() {
      _usernameError = _usernameController.text.isEmpty ? 'Username kosong' : '';
      _passwordError = _passwordController.text.isEmpty ? 'Password kosong' : '';
    });

    if (_usernameError.isNotEmpty || _passwordError.isNotEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

  try {
  final response = await _supabaseClient
      .from('user')
      .select()
      .eq('username', _usernameController.text.trim())
      .eq('password', _passwordController.text.trim())
      .single();
  
  print("Response: $response");

  if (response != null && response.isNotEmpty) {
    // Menavigasi ke HomePage
   Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const HomePage (title: "Produk")),
);

  } else {
    setState(() { //jika login gagal maka akan muncul perintah di bawah ini
      _usernameError = 'Username atau Password Salah';
      _passwordError = 'Username atau Password Salah';
    });
  }
} catch (e) { //memunculkan kesalahan yang terjadi pada saat login
  setState(() {
    _usernameError = 'Terjadi kesalahan saat login';
    _passwordError = 'Terjadi kesalahan saat login';
  });
  ScaffoldMessenger.of(context).showSnackBar( //untuk menampilkan eror agar dapat terlihat oleh pengguna
    SnackBar(content: Text('Error: ${e.toString()}')),
  );
    }
      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 81, 16, 16),
                    Color.fromARGB(255, 81, 16, 16),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Login Form
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20). copyWith(top: 100),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 78, 11, 11),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Silahkan Login Terlebih Dahulu!',
                      style: TextStyle(
                          fontSize: 16, color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                    const SizedBox(height: 30),
                    // Username TextField
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person),
                        hintText: 'Username',
                        filled: true,
                        fillColor: const Color(0xFFF0F0F0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        errorText: _usernameError.isEmpty ? null : _usernameError,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Password TextField
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        hintText: 'Password',
                        filled: true,
                        fillColor: const Color(0xFFF0F0F0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: const Color.fromARGB(255, 202, 164, 164),
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        errorText: _passwordError.isEmpty ? null : _passwordError,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 173, 141, 141),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Login',
                                style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 78, 11, 11),
    );
  }
}
