import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/movie_provider.dart';
import 'screens/home_screen.dart';
import 'screens/about_me_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MovieProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0; // Menyimpan index halaman aktif

  final List<Widget> _screens = [
    HomeScreen(),
    AboutMeScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.indigo[900], // ✅ Ubah background jadi navy
      ),
      home: Scaffold(
        backgroundColor: Colors.indigo[900], // ✅ Pastikan di sini juga navy
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.indigo[800], // ✅ Warna navy lebih gelap untuk navbar
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.movie),
              label: "Movies",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "About Me",
            ),
          ],
        ),
      ),
    );
  }
}
