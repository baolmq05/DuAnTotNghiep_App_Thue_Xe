import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:duantotnghiep_app_thue_xe/providers/auth_provider.dart';
import 'package:duantotnghiep_app_thue_xe/viewmodels/policy_viewmodel.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PolicyViewModel>().resetAcceptance();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Họ và tên.')),
      );
      return;
    }
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Số điện thoại.')),
      );
      return;
    }
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Email.')),
      );
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email không đúng định dạng.')),
      );
      return;
    }
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Mật khẩu.')),
      );
      return;
    }
    if (password.length < 6 || password.length > 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu phải từ 6 đến 16 ký tự.')),
      );
      return;
    }
    if (confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng xác nhận mật khẩu.')),
      );
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu xác nhận không trùng khớp.')),
      );
      return;
    }

    final isPolicyAccepted = context.read<PolicyViewModel>().isAccepted;
    if (!isPolicyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đọc và đồng ý với Chính sách & Quy định trước khi đăng ký.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      phone: phone,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký tài khoản thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Đăng ký thất bại. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleGoogleRegister() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.loginWithGoogle();

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng nhập bằng Google thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home');
      } else {
        if (authProvider.errorMessage != 'Bạn đã hủy đăng nhập Google.') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Đăng nhập Google thất bại.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

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
                controller: _nameController,
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
                controller: _phoneController,
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

              // Email Input Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 15.0,
                ),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                    child: Icon(
                      Icons.email_outlined,
                      color: colorScheme.primaryContainer,
                      size: 22.0,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  hintText: 'Email',
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
                controller: _passwordController,
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
                controller: _confirmPasswordController,
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
              const SizedBox(height: 16.0),
              
              // Policy Agreement Checkbox
              Consumer<PolicyViewModel>(
                builder: (context, policyViewModel, child) {
                  return Row(
                    children: [
                      Checkbox(
                        value: policyViewModel.isAccepted,
                        onChanged: (value) {
                          policyViewModel.setAccepted(value ?? false);
                        },
                        activeColor: colorScheme.primary,
                      ),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'Tôi đã đọc và đồng ý với ',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13.0,
                            ),
                            children: [
                              TextSpan(
                                text: 'Chính sách & Quy định',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    context.push('/policy', extra: {
                                      'showAcceptance': true,
                                      'onAccept': () {
                                        policyViewModel.setAccepted(true);
                                      }
                                    });
                                  },
                              ),
                              const TextSpan(text: ' của DRIVIO.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24.0),
              
              // Register Button
              Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  return SizedBox(
                    height: 54.0,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primaryContainer,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: auth.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Đăng ký',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                },
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
              Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  return OutlinedButton(
                    onPressed: auth.isLoading ? null : _handleGoogleRegister,
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
                  );
                },
              ),
              const SizedBox(height: 12.0),
              
              // // Social Register - Facebook Button
              // OutlinedButton(
              //   onPressed: () {},
              //   style: OutlinedButton.styleFrom(
              //     minimumSize: const Size.fromHeight(54.0),
              //     side: BorderSide(color: colorScheme.outline, width: 1.0),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(12.0),
              //     ),
              //     backgroundColor: Colors.white,
              //     elevation: 0,
              //   ),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       SvgPicture.asset(
              //         'assets/facebook_logo.svg',
              //         height: 24.0,
              //         width: 24.0,
              //       ),
              //       const SizedBox(width: 12.0),
              //       Text(
              //         'Đăng ký với Facebook',
              //         style: TextStyle(
              //           color: colorScheme.onSurface,
              //           fontSize: 15.0,
              //           fontWeight: FontWeight.w500,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
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
