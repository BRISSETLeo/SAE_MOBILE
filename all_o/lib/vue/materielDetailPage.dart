// ignore_for_file: file_names

import 'dart:typed_data';
import 'package:all_o/modele/object/bien.dart';
import 'package:flutter/material.dart';

class MaterielDetailPage extends StatelessWidget {
  final Bien materiel;

  const MaterielDetailPage({super.key, required this.materiel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du matériel'),
        backgroundColor: Theme.of(context).secondaryHeaderColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
            const SizedBox(height: 16.0),
            Text(
              'Titre: ${materiel.titre}',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Description:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4.0),
            Text(materiel.description),
            const SizedBox(height: 12.0),
            Row(
              children: [
                const Text(
                  'Catégorie: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  materiel.categorie,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                const Text(
                  'État: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  materiel.nomEtat,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            if (materiel.debutAcces != null)
              Row(
                children: [
                  const Text(
                    'Date de début d\'accès: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${materiel.debutAcces!.day}/${materiel.debutAcces!.month}/${materiel.debutAcces!.year}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            const SizedBox(height: 12.0),
            if (materiel.finAcces != null)
              Row(
                children: [
                  const Text(
                    'Date de fin d\'accès: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${materiel.finAcces!.day}/${materiel.finAcces!.month}/${materiel.finAcces!.year}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            const SizedBox(height: 12.0),
            if (materiel.etat != null)
              Row(
                children: [
                  const Text(
                    'État: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    materiel.etat!,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
