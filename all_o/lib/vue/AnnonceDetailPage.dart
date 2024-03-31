import 'dart:typed_data';
import 'package:all_o/modele/basededonnees.dart';
import 'package:all_o/modele/object/uneAnnonce.dart';
import 'package:flutter/material.dart';

class AnnonceDetailPage extends StatelessWidget {
  final UneAnnonce annonce;

  const AnnonceDetailPage({Key? key, required this.annonce}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de l\'annonce'),
        backgroundColor: Theme.of(context).secondaryHeaderColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Titre: ${annonce.titre}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Description:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.0),
            Text(annonce.description),
            SizedBox(height: 12.0),
            Text(
              'Début d\'accès: ${annonce.debut_acces}',
            ),
            SizedBox(height: 8.0),
            Text(
              'Fin d\'accès: ${annonce.fin_acces}',
            ),
            SizedBox(height: 8.0),
            Text('État: ${annonce.etat}'),
            SizedBox(height: 8.0),
            Text('Catégorie: ${annonce.categorie}'),
            SizedBox(height: 8.0),
            Text('Nom de l\'utilisateur: ${annonce.nom_utilisateur}'),
            SizedBox(height: 8.0),
            Text('Est une annonce: ${annonce.est_annonce ? 'Oui' : 'Non'}'),
            SizedBox(height: 8.0),
            if (annonce.a_image)
              FutureBuilder<List<int>>(
                future: BaseDeDonnes.fetchImage(annonce.id.toString()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur de chargement de l\'image'));
                  } else {
                    final imageBytes = snapshot.data!;
                    return Image.memory(
                      Uint8List.fromList(imageBytes),
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
