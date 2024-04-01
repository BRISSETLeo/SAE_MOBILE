import 'package:flutter/material.dart';
import 'package:all_o/modele/object/uneAnnonce.dart';

class AnnonceDetailPage extends StatelessWidget {
  final UneAnnonce annonce;

  const AnnonceDetailPage({Key? key, required this.annonce}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de l\'annonce'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Titre: ${annonce.titre}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 12),
            Text(
              'Description: ${annonce.description}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'Début d\'accès: ${annonce.debut_acces}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'Fin d\'accès: ${annonce.fin_acces}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'État: ${annonce.etat}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'Catégorie: ${annonce.categorie}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'Nom de l\'utilisateur: ${annonce.nom_utilisateur}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'Est une annonce: ${annonce.est_annonce ? 'Oui' : 'Non'}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}