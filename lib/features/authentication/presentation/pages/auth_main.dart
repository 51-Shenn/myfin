import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/core/components/auth_switcher.dart';
import 'package:myfin/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:myfin/core/navigation/app_routes.dart';
import 'package:myfin/features/authentication/presentation/pages/sign_in_page.dart';
import 'package:myfin/features/authentication/presentation/pages/sign_up_page.dart';

class AuthMainPage extends StatefulWidget {
  const AuthMainPage({super.key});

  @override
  State<AuthMainPage> createState() => _AuthMainPageState();
}

class _AuthMainPageState extends State<AuthMainPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            // 1. Check for Admin State FIRST
            if (state is AuthAuthenticatedAsAdmin) {
              Navigator.pushReplacementNamed(context, AppRoutes.adminHome);
            }
            // 2. Check for Member State SECOND
            else if (state is AuthAuthenticatedAsMember) {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            }

            if (state is AuthFailure) {
              if (state.message.contains('User not found')) {
                context.read<AuthBloc>().add(const AuthPageChanged(1));
              }

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
            }

            if (state is AuthRegisterFailure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
            }

            if (state is AuthResetPasswordFailure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
            }

            if (state is AuthResetPasswordSuccess) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
            }

            if (_pageController.hasClients &&
                _pageController.page?.round() != state.currentPage) {
              _pageController.animateToPage(
                state.currentPage,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B46F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      height: 48,
                      width: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Get Started now',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Create an account or log in to explore\nabout our app',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Switcher
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return AuthSwitcher(
                      isLogin: state.currentPage == 0,
                      onLoginTap: () => context.read<AuthBloc>().add(
                        const AuthPageChanged(0),
                      ),
                      onSignUpTap: () => context.read<AuthBloc>().add(
                        const AuthPageChanged(1),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final double height = state.currentPage == 0 ? 550 : 800;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: height,
                      child: PageView(
                        controller: _pageController,
                        physics:
                            const NeverScrollableScrollPhysics(), // Disable swipe for better UX with height change
                        onPageChanged: (page) =>
                            context.read<AuthBloc>().add(AuthPageChanged(page)),
                        children: const [SignInPage(), SignUpPage()],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
