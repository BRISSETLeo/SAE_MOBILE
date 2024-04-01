import 'package:all_o/vue/annonce.dart';
import 'package:all_o/vue/demande.dart';
import 'package:all_o/vue/profil.dart';
import 'package:flutter/material.dart';

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AccueilState createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const Text("test"),
    const Annonce(),
    const Demande(),
    const Profil(),
  ];

  @override
  Widget build(BuildContext context) {
    String titre = "Accueil";
    if (_widgetOptions[_selectedIndex] is Profil) {
      titre = Profil.title;
    // } else if (_widgetOptions[_selectedIndex] is Annonce) {
    //   titre = Annonce.title;
    } else if (_widgetOptions[_selectedIndex] is Demande) {
      titre = Demande.title;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).secondaryHeaderColor,
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).textSelectionTheme.selectionColor,
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Annonces',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_quote),
            label: 'Demandes de prêt',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
