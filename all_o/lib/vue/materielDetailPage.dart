import 'dart:typed_data';

import 'package:all_o/modele/object/bien.dart';
import 'package:flutter/material.dart';

class MaterielDetailPage extends StatelessWidget {
  final Bien materiel;

  const MaterielDetailPage({Key? key, required this.materiel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du matériel'),
        backgroundColor: Theme.of(context).secondaryHeaderColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (materiel.image != null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: MemoryImage(Uint8List.fromList(materiel.image!)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            SizedBox(height: 16.0),
            Text(
              'Titre: ${materiel.titre}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Description:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.0),
            Text(materiel.description),
            SizedBox(height: 12.0),
            Row(
              children: [
                Text(
                  'Catégorie: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  materiel.categorie,
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            SizedBox(height: 12.0),
            // Ajoutez d'autres détails du matériel ici selon vos besoins
          ],
        ),
      ),
    );
  }
}
