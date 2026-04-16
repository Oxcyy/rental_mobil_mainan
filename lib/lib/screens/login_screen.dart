import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePass = true;

  Future<void> _handleLogin() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      showSnackBarWithOK('Email dan password harus diisi', backgroundColor: const Color(0xFFFFD180));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await SupabaseService.signIn(_emailCtrl.text.trim(), _passCtrl.text);
    } on AuthException catch (_) {
      showSnackBarWithOK('Login gagal: Email atau password salah', backgroundColor: const Color(0xFFFF8A80));
    } catch (_) {
      showSnackBarWithOK('Terjadi kesalahan jaringan', backgroundColor: const Color(0xFFFF8A80));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _neoInputDecoration(String hint, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black38),
      prefixIcon: Icon(icon, color: Colors.black),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFFFF59D),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 2)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 2)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF80DEEA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black, width: 4),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(8, 8), blurRadius: 0)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEA80FC),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 3),
                    ),
                    child: const Icon(Icons.directions_car, size: 60, color: Colors.black),
                  ),
                  const SizedBox(height: 24),
                  
                  // JUDUL
                  const Text(
                    'FARZATOYS RENTAL',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'SILAKAN MASUK',
                    style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 32),
                  
                  // FORM EMAIL
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                    decoration: _neoInputDecoration('EMAIL', Icons.email),
                  ),
                  const SizedBox(height: 16),
                  
                  // FORM PASSWORD
                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscurePass,
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                    decoration: _neoInputDecoration(
                      'PASSWORD', 
                      Icons.lock, 
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, color: Colors.black),
                        onPressed: () => setState(() => _obscurePass = !_obscurePass),
                      )
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // TOMBOL MASUK
                  InkWell(
                    onTap: _isLoading ? null : _handleLogin,
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _isLoading ? Colors.grey : const Color(0xFFB9F6CA), 
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 3),
                        boxShadow: _isLoading ? null : const [
                          BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                height: 24, width: 24, 
                                child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black)
                              )
                            : const Text(
                                'MASUK',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.5)
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}