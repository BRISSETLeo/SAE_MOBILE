import 'package:flutter/material.dart';

class AjouterAnnonce extends StatefulWidget {
  const AjouterAnnonce({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddAnnoncePageState createState() => _AddAnnoncePageState();
}

class _AddAnnoncePageState extends State<AjouterAnnonce> {
  String _title = '';
  String _description = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une annonce'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Titre',
              ),
              onChanged: (value) {
                setState(() {
                  _title = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description',
              ),
              onChanged: (value) {
                setState(() {
                  _description = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            TextButton(
              child: Text('Ajouter'),
              onPressed: () {
                // Ajouter le code pour enregistrer l'annonce ici
                // Utilisez les valeurs de _title et _description pour enregistrer les données
              },
            ),
          ],
        ),
      ),
    );
  }
}
