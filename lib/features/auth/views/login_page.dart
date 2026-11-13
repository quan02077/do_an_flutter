import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:do_an_flutter/features/auth/views/register_page.dart';
import 'package:do_an_flutter/features/auth/views/forgot_password_page.dart';
import '../state/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hienMatKhau = false;
  bool _isLoading = false;

  Future<void> dangNhap() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ email và mật khẩu'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthProvider().signIn(email, password);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng nhập thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } on AuthException catch (e) {
      if (!mounted) return;
      String message = e.message;
      if (message.contains('Invalid login credentials')) {
        message = 'Email hoặc mật khẩu không chính xác';
      } else if (message.contains('Email not confirmed')) {
        message = 'Vui lòng xác thực email trước khi đăng nhập';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),

            const Text(
              'Chào mừng trở lại',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Đăng nhập vào tài khoản của bạn',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 35),

            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: const Color(0xFF222222),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: passwordController,
              obscureText: !hienMatKhau,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Mật khẩu',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      hienMatKhau = !hienMatKhau;
                    });
                  },
                  icon: Icon(
                    hienMatKhau
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                ),
                filled: true,
                fillColor: const Color(0xFF222222),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const ForgotPasswordPage(),
                    ),
                  );
                },
                child: const Text(
                  'Quên mật khẩu?',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : dangNhap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.white54,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'Đăng nhập',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Chưa có tài khoản?",
                  style: TextStyle(color: Colors.grey),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Đăng ký ngay',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
