// ignore_for_file: file_names

import 'dart:typed_data';
import 'package:all_o/modele/basededonnees.dart';
import 'package:all_o/modele/object/uneAnnonce.dart';
import 'package:flutter/material.dart';

// Définition du callback
typedef OnStateChanged = void Function(bool newState);

class MonAnnonceDetailPage extends StatefulWidget {
  final UneAnnonce annonce;
  final OnStateChanged onStateChanged;

  const MonAnnonceDetailPage(
      {super.key, required this.annonce, required this.onStateChanged});

  @override
  // ignore: library_private_types_in_public_api
  _MonAnnonceDetailPageState createState() => _MonAnnonceDetailPageState();
}

class _MonAnnonceDetailPageState extends State<MonAnnonceDetailPage> {
  late bool isModified;
  late bool isSwitched;

  @override
  void initState() {
    super.initState();
    isSwitched = widget.annonce.etat == 'Ouvert';
    isModified = false;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Détails de l\'annonce'),
          backgroundColor: Theme.of(context).secondaryHeaderColor,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.annonce.materiel != null)
                if (widget.annonce.materiel != null)
                  Image.memory(
                    Uint8List.fromList(widget.annonce.materiel?.image ?? []),
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
              Text(
                'Titre: ${widget.annonce.titre}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4.0),
              Text(widget.annonce.description),
              const SizedBox(height: 12.0),
              Text(
                'Début d\'accès: ${widget.annonce.debut_acces}',
              ),
              const SizedBox(height: 8.0),
              Text(
                'Fin d\'accès: ${widget.annonce.fin_acces}',
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Text('État:'),
                  const SizedBox(width: 8.0),
                  Switch(
                    value: isSwitched,
                    onChanged: (value) {
                      setState(() {
                        isSwitched = value;
                        isModified = true;
                        // Appel du callback pour mettre à jour l'état dans la classe parente
                        widget.onStateChanged(isSwitched);
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                    activeTrackColor: Colors.lightGreenAccent,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    isSwitched ? 'Ouvert' : 'Fermé',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSwitched
                          ? Colors.green // Couleur pour l'état ouvert
                          : Colors.red, // Couleur pour l'état fermé
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text('Catégorie: ${widget.annonce.categorie}'),
              const SizedBox(height: 8.0),
              Text('Nom de l\'utilisateur: ${widget.annonce.nom_utilisateur}'),
              const SizedBox(height: 8.0),
              Text(
                'Est une annonce: ${widget.annonce.est_annonce ? 'Oui' : 'Non'}',
              ),
              const SizedBox(height: 8.0),
              if (widget.annonce.a_image)
                FutureBuilder<List<int>>(
                  future: BaseDeDonnes.fetchImage(widget.annonce.id.toString()),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text('Erreur de chargement de l\'image'),
                      );
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
        floatingActionButton: isModified
            ? FloatingActionButton(
                onPressed: () {
                  BaseDeDonnes.publierAnnonce(
                      widget.annonce.id, isSwitched ? 'Ouvert' : 'Fermé');
                  setState(() {
                    isModified = false;
                    widget.annonce.etat = isSwitched ? 'Ouvert' : 'Fermé';
                  });
                },
                backgroundColor: Theme.of(context).secondaryHeaderColor,
                child: const Icon(Icons.save),
              )
            : FloatingActionButton(
                onPressed: () {},
                backgroundColor: isSwitched ? Colors.green : Colors.red,
                child: Icon(isSwitched ? Icons.check : Icons.close),
              ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (isModified) {
      // Affiche une boîte de dialogue pour confirmer si l'utilisateur veut quitter sans sauvegarder
      bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Attention'),
          content: const Text(
              'Voulez-vous quitter sans sauvegarder les modifications ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Oui'),
            ),
          ],
        ),
      );

      return confirm;
    }

    return true;
  }
}
