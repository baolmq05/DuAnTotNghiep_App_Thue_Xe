import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/login');
              }
            },
            icon: Icon(
              CupertinoIcons.chevron_left,
              color: colorScheme.onSurface,
              size: 24.0,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 20.0,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title "Đăng ký tài khoản"
              Text(
                'Đăng ký tài khoản',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primaryContainer,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8.0),
              
              // Subtitle "Tạo tài khoản để trải nghiệm dịch vụ"
              Text(
                'Tạo tài khoản để trải nghiệm dịch vụ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40.0),
              
              // Full name Input Field
              TextField(
                keyboardType: TextInputType.name,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 15.0,
                ),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                    child: Icon(
                      Icons.person,
                      color: colorScheme.primaryContainer,
                      size: 22.0,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  hintText: 'Họ và tên',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 15.0,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18.0),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: colorScheme.primaryContainer, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              
              // Phone Input Field
              TextField(
                keyboardType: TextInputType.phone,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 15.0,
                ),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                    child: Icon(
                      Icons.phone,
                      color: colorScheme.primaryContainer,
                      size: 22.0,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  hintText: 'Số điện thoại',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 15.0,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18.0),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: colorScheme.primaryContainer, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              
              // Password Input Field
              TextField(
                obscureText: _isPasswordObscured,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 15.0,
                ),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                    child: Icon(
                      Icons.lock,
                      color: colorScheme.primaryContainer,
                      size: 22.0,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      icon: Icon(
                        _isPasswordObscured
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: colorScheme.onSurface,
                        size: 20.0,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordObscured = !_isPasswordObscured;
                        });
                      },
                    ),
                  ),
                  hintText: 'Mật khẩu',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 15.0,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18.0),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: colorScheme.primaryContainer, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              
              // Confirm Password Input Field
              TextField(
                obscureText: _isConfirmPasswordObscured,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 15.0,
                ),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                    child: Icon(
                      Icons.lock,
                      color: colorScheme.primaryContainer,
                      size: 22.0,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      icon: Icon(
                        _isConfirmPasswordObscured
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: colorScheme.onSurface,
                        size: 20.0,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                        });
                      },
                    ),
                  ),
                  hintText: 'Nhập lại mật khẩu',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 15.0,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18.0),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: colorScheme.primaryContainer, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 28.0),
              
              // Register Button
              SizedBox(
                height: 54.0,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    'Đăng ký',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              
              // Divider "Hoặc đăng ký với"
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: colorScheme.outline,
                      thickness: 1.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Hoặc đăng ký với',
                      style: TextStyle(
                        fontSize: 13.0,
                        color: const Color(0xCC6B7280),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: colorScheme.outline,
                      thickness: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              
              // Social Register - Google Button
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54.0),
                  side: BorderSide(color: colorScheme.outline, width: 1.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  backgroundColor: Colors.white,
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/google_logo.svg',
                      height: 24.0,
                      width: 24.0,
                    ),
                    const SizedBox(width: 12.0),
                    Text(
                      'Đăng ký với Google',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12.0),
              
              // Social Register - Facebook Button
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54.0),
                  side: BorderSide(color: colorScheme.outline, width: 1.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  backgroundColor: Colors.white,
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/facebook_logo.svg',
                      height: 24.0,
                      width: 24.0,
                    ),
                    const SizedBox(width: 12.0),
                    Text(
                      'Đăng ký với Facebook',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),
              
              // Navigation back to Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Đã có tài khoản? ',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14.0,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/login');
                      }
                    },
                    child: Text(
                      'Đăng nhập ngay',
                      style: TextStyle(
                        color: colorScheme.primaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48.0),
            ],
          ),
        ),
      ),
    );
  }
}
