import 'package:flutter/material.dart';
import 'package:movie_app/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController hobbyController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  bool isLoading = false;

  void _register() async {
    setState(() => isLoading = true);

    final user = await AuthService().registerWithEmailPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      fullname: fullnameController.text.trim(),
      nickname: nicknameController.text.trim(),
      hobby: hobbyController.text.trim(),
      instagram: instagramController.text.trim(),
    );

    if (!mounted) return; // Pastikan widget masih ada sebelum update UI

    setState(() => isLoading = false);

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration successful! Please login.")),
      );
      Navigator.pop(context); // Kembali ke halaman login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed! Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[900],
      appBar: AppBar(
        backgroundColor: Colors.indigo[800],
        elevation: 0,
        title: Text("Register", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🔹 Langsung teks tanpa container
              Text(
                "Create an Account",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 20),

              // 🔹 Input Fields dengan Icons
              _buildTextField(fullnameController, "Full Name", Icons.person),
              _buildTextField(nicknameController, "Nickname", Icons.tag),
              _buildTextField(hobbyController, "Hobby", Icons.sports_soccer),
              _buildTextField(
                  instagramController, "Instagram", Icons.camera_alt),
              _buildTextField(emailController, "Email", Icons.email),
              _buildTextField(passwordController, "Password", Icons.lock,
                  isPassword: true),

              SizedBox(height: 20),

              // 🔹 Button Register
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text("Register",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),

              SizedBox(height: 10),

              // 🔹 Link ke Login
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Already have an account? Login",
                    style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Widget untuk Input Field dengan Icon
  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          prefixIcon: Icon(icon, color: Colors.white),
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
        ),
      ),
    );
  }
}
