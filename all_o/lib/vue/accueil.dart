import 'package:flutter/material.dart';

class Accueil extends StatefulWidget {
  const Accueil({Key? key}) : super(key: key);

  @override
  _AccueilState createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Accueil',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Action à effectuer lors du clic sur l'icône du profil utilisateur
            },
            icon: const Icon(
              Icons.person_outline,
              color: Colors.black,
              size: 40,
            ),
          ),
        ],
      ),
      body: _getBody(_selectedIndex),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildBottomNavItem(
              index: 0,
              icon: Icons.home,
              label: 'Accueil',
            ),
            _buildBottomNavItem(
              index: 1,
              icon: Icons.article,
              label: 'Annonces',
            ),
            _buildBottomNavItem(
              index: 2,
              icon: Icons.request_quote,
              label: 'Demandes de prêt',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(30),
        child: SizedBox(
          height: 60,
          width: 60,
          child: Ink(
            decoration: const ShapeDecoration(
              color: Colors.transparent,
              shape: CircleBorder(),
            ),
            child: Icon(icon, size: 30),
          ),
        ),
      ),
    );
  }

  Widget _getBody(int index) {
    switch (index) {
      case 0:
        return const Center(
          child: Text(
            'Accueil',
            style: TextStyle(fontSize: 24),
          ),
        );
      case 1:
        return const Center(
          child: Text(
            'Annonces',
            style: TextStyle(fontSize: 24),
          ),
        );
      case 2:
        return const Center(
          child: Text(
            'Demandes de prêt',
            style: TextStyle(fontSize: 24),
          ),
        );
      default:
        return Container();
    }
  }
}
