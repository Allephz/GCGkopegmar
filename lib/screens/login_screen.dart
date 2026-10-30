// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();

  bool _showPassword = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.login(
        username: _usernameController.text,
        password: _passwordController.text,
      );

      if (response.isSuccess) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        setState(() {
          _errorMessage = response.errorMessage ?? 'Login gagal';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Koneksi gagal: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2563EB);
    const Color bgGray = Color(0xFFF3F4F6);
    const Color errorRed = Color(0xFFEF4444);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'GCG',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: Colors.white,
                                  fontSize: 32,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Masuk Akun Kopegmar',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 24,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Username Field
                Text(
                  'Username',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan username',
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Password Field
                Text(
                  'Password',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    hintText: 'Masukkan password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Remember Me Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      activeColor: primaryBlue,
                    ),
                    Text(
                      'Ingat saya',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Error Message
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: errorRed),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: errorRed,
                          ),
                    ),
                  ),
                const SizedBox(height: 24),
                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Masuk',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                // Help Text
                Center(
                  child: Text(
                    'Butuh bantuan? Hubungi admin koperasi',
                    style: Theme.of(context).textTheme.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
