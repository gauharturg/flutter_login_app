import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EXP Login',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.white70),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isSignUp = false;
  String _errorMessage = '';
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _blurAnimation;

  // Password visibility variables
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Password criteria flags
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _blurAnimation = Tween<double>(begin: 5.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Sign up with Email & Password
  Future<void> _signUpWithEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Email and Password cannot be empty.';
      });
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      print('User signed up: ${userCredential.user?.email}');
      _showThankYouScreen();
    } catch (error) {
    if (error is FirebaseAuthException) {
      if (error.code == 'email-already-in-use') {
        setState(() {
          _errorMessage = 'An account already exists with this email. Redirecting to Sign In.';
        });
        setState(() {
          _isSignUp = false; 
        });
      } else {
        setState(() {
          _errorMessage = error.message ?? 'An unknown error occurred.';
        });
      }
    }
  }
  }

  // Sign in with Email & Password
  Future<void> _signInWithEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Email and Password cannot be empty.';
      });
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      print('User signed in: ${userCredential.user?.email}');
      _showThankYouScreen();
    } catch (error) {
      String message = '';
      if (error is FirebaseAuthException) {
        if (error.code == 'invalid-credential') {
          message = 'Incorrect email address or password. Please try again.';
        } else {
          message = 'An unknown error occurred. Please reload the page.';
        }
      }
      setState(() {
        _errorMessage = message;
      });
    }
  }

  // Sign in with Google
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return; // User canceled the sign-in
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      print('User signed in with Google: ${_auth.currentUser?.email}');
      _showThankYouScreen();
    } catch (error) {
      setState(() {
        _errorMessage = error.toString(); 
      });
    }
  }

  Future<void> _sendPasswordResetEmail() async {
  if (_emailController.text.isEmpty) {
    setState(() {
      _errorMessage = 'Please enter your email to reset password.';
    });
    return;
  }

  try {
    await _auth.sendPasswordResetEmail(email: _emailController.text);
    setState(() {
      _errorMessage = 'A password reset link has been sent to your email.';
    });
  } catch (error) {
    if (error is FirebaseAuthException) {
      if (error.code == 'invalid-credential') {
        setState(() {
          _errorMessage = 'No user found with this email.';
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to send reset email. Try again later.';
        });
      }
    }
  }
}


  void _showThankYouScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ThankYouScreen(auth: _auth)),
    );
  }

  void _toggleSignUp() {
    setState(() {
      _isSignUp = !_isSignUp;
      _errorMessage = ''; 
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _isPasswordValid = false;
      _isConfirmPasswordValid = false;
    });
  }

  void _checkPasswordValidity(String password) {
    setState(() {
      _isPasswordValid = password.length >= 8 &&
          RegExp(r'[A-Z]').hasMatch(password) &&
          RegExp(r'[a-z]').hasMatch(password) &&
          RegExp(r'[0-9]').hasMatch(password) &&
          RegExp(r'[@$!%*?&]').hasMatch(password);
    });
  }

  void _checkConfirmPasswordValidity(String confirmPassword) {
    setState(() {
      _isConfirmPasswordValid = confirmPassword == _passwordController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          if (MediaQuery.of(context).size.width > 600)
            Expanded(
              flex: 1,
              child: Container(
                color: const Color(0xFF121212),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _opacityAnimation,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Center(
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: _blurAnimation.value,
                              sigmaY: _blurAnimation.value,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Gaukhar Turgambekova's",
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Flutter Task",
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          Expanded(
            flex: 1,
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Image.network(
                            'web/icons/EXP-logo.gif',
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                            Center(
                            child: Text(
                              _isSignUp ? 'Create an Account' : 'Welcome Back!',
                              style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              ),
                            ),
                            ),
                          const SizedBox(height: 12),
                          if (_errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                _errorMessage,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          // Email field
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),
                          // Password field
                          TextField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              suffixIcon: Padding(
                                padding: const EdgeInsetsDirectional.only(end: 12.0), 
                                child: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.black, 
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                            obscureText: !_isPasswordVisible,
                            onChanged: (value) {
                              _checkPasswordValidity(value);
                              _checkConfirmPasswordValidity(_confirmPasswordController.text);
                            },
                          ),
                          const SizedBox(height: 3),
                          if (!_isSignUp)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: _sendPasswordResetEmail, // Add your reset email logic here
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 6),
                          // Show password criteria
                          _isSignUp ? _buildPasswordCriteria() : Container(),
                          // Confirm Password field for Sign Up only
                          if (_isSignUp)
                            TextField(
                              controller: _confirmPasswordController,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                suffixIcon: Padding(
                                  padding: const EdgeInsetsDirectional.only(end: 12.0), 
                                  child: IconButton(
                                    icon: Icon(
                                      _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                      color: Colors.black, 
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              obscureText: !_isConfirmPasswordVisible,
                              onChanged: _checkConfirmPasswordValidity,
                            ),


                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: (!_isSignUp || (_isPasswordValid && _isConfirmPasswordValid))
                            ? (_isSignUp ? _signUpWithEmail : _signInWithEmail)
                            : null,
                            child: Text(_isSignUp ? 'Sign Up' : 'Sign In'),
                          ),
                          const SizedBox(height: 12),
                          // Google Sign-In button
                          ElevatedButton.icon(
                            onPressed: _signInWithGoogle,
                            icon: Image.asset(
                              'icons/Google__logo.png',
                              width: 24, 
                              height: 24, 
                            ),
                            label: Text( _isSignUp ? 'Sign up with Google' : 'Sign in with Google'),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _toggleSignUp,
                            child: Text(
                              _isSignUp ? 'Already have an account? Sign In' : 'Don\'t have an account? Sign Up',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

    Widget _buildPasswordCriteria() {
    bool hasMinLength = _passwordController.text.length >= 8;
    bool hasUppercase = RegExp(r'[A-Z]').hasMatch(_passwordController.text);
    bool hasLowercase = RegExp(r'[a-z]').hasMatch(_passwordController.text);
    bool hasNumber = RegExp(r'[0-9]').hasMatch(_passwordController.text);
    bool hasSpecialChar = RegExp(r'[@$!%*?&]').hasMatch(_passwordController.text);
    
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(hasMinLength ? Icons.check : Icons.close,
                color: hasMinLength ? Colors.green : Colors.red),
            const SizedBox(width: 8),
            const Text('At least 8 characters'),
          ],
        ),
        Row(
          children: [
            Icon(hasUppercase ? Icons.check : Icons.close,
                color: hasUppercase ? Colors.green : Colors.red),
            const SizedBox(width: 8),
            const Text('At least 1 uppercase letter'),
          ],
        ),
        Row(
          children: [
            Icon(hasLowercase ? Icons.check : Icons.close,
                color: hasLowercase ? Colors.green : Colors.red),
            const SizedBox(width: 8),
            const Text('At least 1 lowercase letter'),
          ],
        ),
        Row(
          children: [
            Icon(hasNumber ? Icons.check : Icons.close,
                color: hasNumber ? Colors.green : Colors.red),
            const SizedBox(width: 8),
            const Text('At least 1 number'),
          ],
        ),
        Row(
          children: [
            Icon(hasSpecialChar ? Icons.check : Icons.close,
                color: hasSpecialChar ? Colors.green : Colors.red),
            const SizedBox(width: 8),
            const Text('At least 1 special character'),
          ],
        ),
        const SizedBox(height: 6),
      ],
    );
  }
  }

class ThankYouScreen extends StatelessWidget {
  final FirebaseAuth auth;
  const ThankYouScreen({Key? key, required this.auth}) : super(key: key);
  Future<void> _signOut(BuildContext context) async {
    await auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'That is the end of the task,',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Thank you for your attention!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _signOut(context),
              child: const Text('Log Out'),
            ),
            const SizedBox(height: 40),
            Text(
                'Gaukhar Turgambekova',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 6),
              SelectableText(
                'gauharturg@gmail.com',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 6),
              InkWell(
                onTap: () => _launchURL('https://linkedin.com/in/gaukh'),
                child: Text(
                  'linkedin.com/in/gaukh',
                  style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 89, 144, 190), decoration: TextDecoration.underline),
                ),
              ),
              SizedBox(height: 6),
              SelectableText(
                '+85252631235',
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }
}
