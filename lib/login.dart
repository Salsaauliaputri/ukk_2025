import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage(String s, {Key? key, required String title}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
 
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _errorShown = false; // Cek apakah error sudah muncul sebelumnya

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _errorShown = false; // Reset error setiap kali login ditekan
    });

    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Username dan Password tidak boleh kosong');
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

      if (response != null && response.isNotEmpty) {
        _errorShown = false; // Reset jika login berhasil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const HomePage("home", title: "Home")),
        );
      } else {
        if (!_errorShown) {
          _showSnackBar('Username atau Password Salah');
          setState(() {
            _errorShown = true;
          });
        }
      }
    } catch (e) {
      if (!_errorShown) {
        _showSnackBar('Username atau Password Salah');
        setState(() {
          _errorShown = true;
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF511010), Color(0xFF511010)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Login Form
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 100),
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
                          fontSize: 16, color: Colors.black54),
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
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
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
                                style: TextStyle(fontSize: 18, color: Colors.black),
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
