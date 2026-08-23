import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  // ------------------------------------------------------------
  // COLORS
  // ------------------------------------------------------------

  static const maroon = Color(0xFF7B0F1A);
  static const darkMaroon = Color(0xFF520912);
  static const gold = Color(0xFFD4AF37);
  static const lightGold = Color(0xFFE8C866);

  static const ivory = Color(0xFFFFF8EA);
  static const cream = Color(0xFFF8EEDB);

  static const darkBrown = Color(0xFF3A2A21);
  static const mutedBrown = Color(0xFF765C4A);

  // ------------------------------------------------------------
  // LOGIN
  // ------------------------------------------------------------

  Future<void> login() async {setState(() {
    isLoading = true;
  });

  try {
    final credential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Unable to get logged-in user.');
    }

    // Create the user's profile in Realtime Database
    await UserService().createUser(
      uid: user.uid,
      email: user.email ?? emailController.text.trim(),
      name: user.displayName ?? 'User',
    );

    if (!mounted) return;

    _showMessage('Welcome back! 🎶');

  } on FirebaseAuthException catch (e) {
    String message = 'Login failed';

    if (e.code == 'user-not-found') {
      message = 'No account found with this email.';
    } else if (e.code == 'wrong-password') {
      message = 'Incorrect password.';
    } else if (e.code == 'invalid-credential') {
      message = 'Invalid email or password.';
    } else if (e.code == 'invalid-email') {
      message = 'Please enter a valid email address.';
    }

    if (!mounted) return;

    _showMessage(message);

  } catch (e) {
    if (!mounted) return;

    _showMessage(
      'Something went wrong. Please try again.',
    );

    debugPrint('Login error: $e');

  } finally {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }}

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: darkMaroon,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // DISPOSE
  // ------------------------------------------------------------

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ivory,

      body: SafeArea(
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -70,
              right: -60,
              child: _decorativeCircle(170),
            ),

            Positioned(
              bottom: -90,
              left: -70,
              child: _decorativeCircle(190),
            ),

            // Main content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 35,
                ),

                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // ------------------------------------------------
                    // LOGO
                    // ------------------------------------------------

                    _buildLogo(),

                    const SizedBox(height: 18),

                    // ------------------------------------------------
                    // APP NAME
                    // ------------------------------------------------

                    const Text(
                      'SANGEETHALAYA',
                      style: TextStyle(
                        color: maroon,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.5,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Carnatic Music Library',
                      style: TextStyle(
                        color: mutedBrown,
                        fontSize: 14,
                        letterSpacing: 0.8,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ------------------------------------------------
                    // DECORATIVE DIVIDER
                    // ------------------------------------------------

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 65,
                          child: Divider(
                            color: gold,
                            thickness: 0.7,
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            '✦',
                            style: TextStyle(
                              color: gold,
                              fontSize: 16,
                            ),
                          ),
                        ),

                        SizedBox(
                          width: 65,
                          child: Divider(
                            color: gold,
                            thickness: 0.7,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ------------------------------------------------
                    // LOGIN CARD
                    // ------------------------------------------------

                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(22),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(22),

                        border: Border.all(
                          color: const Color(0xFFE2CEA0),
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: maroon.withOpacity(0.07),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          // ------------------------------------------------
                          // WELCOME
                          // ------------------------------------------------

                          const Center(
                            child: Text(
                              'Welcome Back ♫',
                              style: TextStyle(
                                color: darkBrown,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Center(
                            child: Text(
                              'Continue your musical journey',
                              style: TextStyle(
                                color: mutedBrown,
                                fontSize: 13,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ------------------------------------------------
                          // EMAIL
                          // ------------------------------------------------

                          const Text(
                            'Email',
                            style: TextStyle(
                              color: darkBrown,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 7),

                          TextField(
                            controller: emailController,

                            keyboardType:
                                TextInputType.emailAddress,

                            decoration: InputDecoration(
                              hintText: 'Enter your email',

                              prefixIcon: const Icon(
                                Icons.mail_outline,
                                color: maroon,
                                size: 21,
                              ),

                              filled: true,
                              fillColor: cream,

                              contentPadding:
                                  const EdgeInsets.symmetric(
                                vertical: 15,
                              ),

                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(13),

                                borderSide: BorderSide.none,
                              ),

                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(13),

                                borderSide: const BorderSide(
                                  color: Color(0xFFE6D6B7),
                                ),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(13),

                                borderSide: const BorderSide(
                                  color: gold,
                                  width: 1.3,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ------------------------------------------------
                          // PASSWORD
                          // ------------------------------------------------

                          const Text(
                            'Password',
                            style: TextStyle(
                              color: darkBrown,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 7),

                          TextField(
                            controller: passwordController,

                            obscureText: obscurePassword,

                            decoration: InputDecoration(
                              hintText: 'Enter your password',

                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: maroon,
                                size: 21,
                              ),

                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscurePassword =
                                        !obscurePassword;
                                  });
                                },

                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,

                                  color: mutedBrown,
                                  size: 20,
                                ),
                              ),

                              filled: true,
                              fillColor: cream,

                              contentPadding:
                                  const EdgeInsets.symmetric(
                                vertical: 15,
                              ),

                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(13),

                                borderSide: BorderSide.none,
                              ),

                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(13),

                                borderSide: const BorderSide(
                                  color: Color(0xFFE6D6B7),
                                ),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(13),

                                borderSide: const BorderSide(
                                  color: gold,
                                  width: 1.3,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // ------------------------------------------------
                          // FORGOT PASSWORD
                          // ------------------------------------------------

                          Align(
                            alignment: Alignment.centerRight,

                            child: TextButton(
                              onPressed: () {
                                _showMessage(
                                  'Password reset will be added soon.',
                                );
                              },

                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),

                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: maroon,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ------------------------------------------------
                          // LOGIN BUTTON
                          // ------------------------------------------------

                          SizedBox(
                            width: double.infinity,
                            height: 52,

                            child: ElevatedButton(
                              onPressed:
                                  isLoading ? null : login,

                              style: ElevatedButton.styleFrom(
                                backgroundColor: maroon,
                                foregroundColor: ivory,

                                disabledBackgroundColor:
                                    maroon.withOpacity(0.6),

                                elevation: 2,

                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(13),
                                ),
                              ),

                              child: isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,

                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: lightGold,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,

                                      children: [
                                        Text(
                                          'LOGIN',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight:
                                                FontWeight.bold,
                                            letterSpacing: 1.8,
                                          ),
                                        ),

                                        SizedBox(width: 10),

                                        Icon(
                                          Icons.arrow_forward,
                                          size: 19,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SignUpScreen(),
                            ),
                          );
                        },

                        child: const Text(
                          "Don't have an account? Sign Up",
                          style: TextStyle(
                            color: maroon,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ------------------------------------------------
                    // BOTTOM MESSAGE
                    // ------------------------------------------------

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: const [
                        Icon(
                          Icons.music_note,
                          size: 15,
                          color: gold,
                        ),

                        SizedBox(width: 5),

                        Text(
                          'Preserve • Learn • Sing',
                          style: TextStyle(
                            color: mutedBrown,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),

                        SizedBox(width: 5),

                        Icon(
                          Icons.music_note,
                          size: 15,
                          color: gold,
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // LOGO
  // ------------------------------------------------------------

  Widget _buildLogo() {
    return Container(
      height: 100,
      width: 100,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        color: maroon,

        border: Border.all(
          color: gold,
          width: 2,
        ),

        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.18),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Stack(
        alignment: Alignment.center,

        children: [
          Container(
            height: 78,
            width: 78,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              border: Border.all(
                color: lightGold.withOpacity(0.65),
                width: 1,
              ),
            ),
          ),

          const Icon(
            Icons.music_note,
            color: lightGold,
            size: 45,
          ),

          const Positioned(
            top: 7,
            child: Text(
              '✦',
              style: TextStyle(
                color: lightGold,
                fontSize: 12,
              ),
            ),
          ),

          const Positioned(
            bottom: 7,
            child: Text(
              '❈',
              style: TextStyle(
                color: lightGold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // BACKGROUND DECORATION
  // ------------------------------------------------------------

  Widget _decorativeCircle(double size) {
    return Container(
      height: size,
      width: size,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        border: Border.all(
          color: gold.withOpacity(0.10),
          width: 2,
        ),
      ),
    );
  }
}