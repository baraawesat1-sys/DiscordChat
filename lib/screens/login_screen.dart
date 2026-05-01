import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isRegister = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    final authProvider = context.read<AuthProvider>();

    if (_usernameController.text.isEmpty) {
      _showError('الرجاء إدخال اسم المستخدم');
      return;
    }

    bool success;
    if (_isRegister) {
      if (_emailController.text.isEmpty) {
        _showError('الرجاء إدخال البريد الإلكتروني');
        return;
      }
      success = await authProvider.register(
        _usernameController.text,
        _emailController.text,
      );
      if (!success) {
        _showError('اسم المستخدم أو البريد موجود بالفعل');
        return;
      }
    } else {
      success = await authProvider.login(_usernameController.text);
      if (!success) {
        _showError('اسم المستخدم غير موجود');
        return;
      }
    }

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Stack(
        children: [
          // Background with stars
          Positioned.fill(
            child: CustomPaint(
              painter: LoginBackgroundPainter(),
            ),
          ),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.accentCyan,
                          AppTheme.accentPurple,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentCyan.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chat_bubble,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Title
                  Text(
                    _isRegister ? 'إنشاء حساب' : 'تسجيل الدخول',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'مرحباً بك في عالم التواصل الفضائي',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // Username field
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'اسم المستخدم',
                      prefixIcon: const Icon(Icons.person),
                      prefixIconColor: AppTheme.accentCyan,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 16),
                  // Email field (only for register)
                  if (_isRegister)
                    Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'البريد الإلكتروني',
                            prefixIcon: const Icon(Icons.email),
                            prefixIconColor: AppTheme.accentCyan,
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  // Auth button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading ? null : _handleAuth,
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                  ),
                                )
                              : Text(_isRegister ? 'إنشاء حساب' : 'دخول'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Toggle register/login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isRegister ? 'لديك حساب بالفعل؟ ' : 'ليس لديك حساب؟ ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isRegister = !_isRegister;
                            _emailController.clear();
                          });
                        },
                        child: Text(
                          _isRegister ? 'دخول' : 'إنشاء حساب',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.accentCyan,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw stars
    final starPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1;

    for (int i = 0; i < 150; i++) {
      final x = (i * 41 + 123) % size.width.toInt();
      final y = (i * 67 + 456) % size.height.toInt();
      canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), 1, starPaint);
    }

    // Draw nebula effect
    final nebulaPaint = Paint()
      ..color = AppTheme.nebulaColor.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      150,
      nebulaPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.7),
      200,
      nebulaPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
