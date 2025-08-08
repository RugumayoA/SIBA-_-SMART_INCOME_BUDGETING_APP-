import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/app_provider.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../home_screen.dart';

enum LoginMode { signIn, signUp }

class LoginScreen extends StatefulWidget {
  final LoginMode initialMode;
  
  const LoginScreen({
    super.key, 
    this.initialMode = LoginMode.signIn,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;
  List<String> _savedAccounts = [];
  bool _showAccountPicker = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialMode == LoginMode.signUp;
    _loadSavedAccounts();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedAccounts() async {
    final accounts = await AuthService.getSavedAccounts();
    setState(() {
      _savedAccounts = accounts;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential? result;
      
      if (_isSignUp) {
        result = await AuthService.signUpWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        result = await AuthService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }

      // Save account to device storage
      await AuthService.saveAccount(_emailController.text.trim());
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isSignUp ? 'Account created successfully!' : 'Signed in successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Navigate directly to home screen
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        // Remove the "Exception: " prefix for cleaner error messages
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6750A4), Color(0xFF9C27B0)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo/Title
                        const Icon(
                          Icons.account_balance_wallet,
                          size: 80,
                          color: Color(0xFF6750A4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'SIBA',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: const Color(0xFF6750A4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Smart Income Budgeting App',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                                                 const SizedBox(height: 32),

                         // Account Picker (if saved accounts exist)
                         if (_savedAccounts.isNotEmpty) ...[
                           Container(
                             width: double.infinity,
                             padding: const EdgeInsets.all(16),
                             decoration: BoxDecoration(
                               color: Colors.grey[100],
                               borderRadius: BorderRadius.circular(8),
                               border: Border.all(color: Colors.grey[300]!),
                             ),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Row(
                                   children: [
                                     const Icon(Icons.account_circle, color: Colors.grey),
                                     const SizedBox(width: 8),
                                     Text(
                                       'Saved Accounts',
                                       style: TextStyle(
                                         fontWeight: FontWeight.bold,
                                         color: Colors.grey[700],
                                       ),
                                     ),
                                     const Spacer(),
                                                                        IconButton(
                                     icon: Icon(
                                       _showAccountPicker ? Icons.expand_less : Icons.expand_more,
                                       color: Colors.grey[600],
                                     ),
                                     onPressed: () {
                                       setState(() {
                                         _showAccountPicker = !_showAccountPicker;
                                       });
                                     },
                                   ),
                                   if (_savedAccounts.isNotEmpty)
                                     IconButton(
                                       icon: const Icon(Icons.clear_all, size: 18),
                                       onPressed: () async {
                                         await AuthService.clearSavedAccounts();
                                         await _loadSavedAccounts();
                                       },
                                       tooltip: 'Clear all accounts',
                                     ),
                                   ],
                                 ),
                                 if (_showAccountPicker) ...[
                                   const SizedBox(height: 8),
                                   ...(_savedAccounts.map((email) => ListTile(
                                     leading: const Icon(Icons.email, size: 20),
                                     title: Text(email),
                                     trailing: IconButton(
                                       icon: const Icon(Icons.delete, size: 18),
                                       onPressed: () async {
                                         await AuthService.removeSavedAccount(email);
                                         await _loadSavedAccounts();
                                       },
                                     ),
                                     onTap: () {
                                       setState(() {
                                         _emailController.text = email;
                                         _showAccountPicker = false;
                                       });
                                     },
                                   )).toList()),
                                   const Divider(),
                                   ListTile(
                                     leading: const Icon(Icons.add, size: 20),
                                     title: const Text('Use New Account'),
                                     onTap: () {
                                       setState(() {
                                         _emailController.clear();
                                         _showAccountPicker = false;
                                       });
                                     },
                                   ),
                                 ],
                               ],
                             ),
                           ),
                           const SizedBox(height: 16),
                         ],

                         // Email Field
                         TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                                                 // Password Field
                         TextFormField(
                           controller: _passwordController,
                           obscureText: _obscurePassword,
                           decoration: InputDecoration(
                             labelText: 'Password',
                             prefixIcon: const Icon(Icons.lock),
                             suffixIcon: IconButton(
                               icon: Icon(
                                 _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                 color: Colors.grey[600],
                               ),
                               onPressed: () {
                                 setState(() {
                                   _obscurePassword = !_obscurePassword;
                                 });
                               },
                             ),
                             border: const OutlineInputBorder(),
                           ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6750A4),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(_isSignUp ? 'Sign Up' : 'Sign In'),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Toggle Sign In/Sign Up
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                            });
                          },
                          child: Text(
                            _isSignUp
                                ? 'Already have an account? Sign In'
                                : 'Don\'t have an account? Sign Up',
                          ),
                        ),

                        // Forgot Password
                        if (!_isSignUp) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              // TODO: Implement forgot password
                            },
                            child: const Text('Forgot Password?'),
                          ),
                        ],

                        // Diagnostic Button (for debugging)
                        if (_isSignUp) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () async {
                              try {
                                print('Running Firebase diagnostics...');
                                
                                // Test Firebase connection
                                final isConnected = await FirebaseService.testFirebaseConnection();
                                print('Firebase connection test result: $isConnected');
                                
                                // Test Auth configuration
                                final isAuthConfigured = await AuthService.testAuthConfiguration();
                                print('Auth configuration test result: $isAuthConfigured');
                                
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Diagnostics: Firebase=${isConnected}, Auth=${isAuthConfigured}'),
                                      backgroundColor: Colors.blue,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              } catch (e) {
                                print('Diagnostic error: $e');
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Diagnostic error: $e'),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text('Run Diagnostics'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 