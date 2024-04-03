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
      {Key? key, required this.annonce, required this.onStateChanged})
      : super(key: key);

  @override
  _MonAnnonceDetailPageState createState() => _MonAnnonceDetailPageState();
}

class _MonAnnonceDetailPageState extends State<MonAnnonceDetailPage> {
  late bool isModified;
  late bool isSwitched;

  @override
  void initState() {
    super.initState();
    // Initialise l'état modifié à l'état de l'annonce actuelle
    isSwitched = widget.annonce.etat == 'Ouvert';
    // Initialise isModified à false car il n'y a pas encore de modification
    isModified = false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Détails de l\'annonce'),
          backgroundColor: Theme.of(context).secondaryHeaderColor,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Titre: ${widget.annonce.titre}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              SizedBox(height: 8.0),
              Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.0),
              Text(widget.annonce.description),
              SizedBox(height: 12.0),
              Text(
                'Début d\'accès: ${widget.annonce.debut_acces}',
              ),
              SizedBox(height: 8.0),
              Text(
                'Fin d\'accès: ${widget.annonce.fin_acces}',
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Text('État:'),
                  SizedBox(width: 8.0),
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
                  SizedBox(width: 8.0),
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
              SizedBox(height: 8.0),
              Text('Catégorie: ${widget.annonce.categorie}'),
              SizedBox(height: 8.0),
              Text('Nom de l\'utilisateur: ${widget.annonce.nom_utilisateur}'),
              SizedBox(height: 8.0),
              Text(
                'Est une annonce: ${widget.annonce.est_annonce ? 'Oui' : 'Non'}',
              ),
              SizedBox(height: 8.0),
              if (widget.annonce.a_image)
                FutureBuilder<List<int>>(
                  future: BaseDeDonnes.fetchImage(widget.annonce.id.toString()),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
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
                  BaseDeDonnes.publierAnnonce(widget.annonce.id,
                      widget.annonce.etat == 'Ouvert' ? 'Fermé' : 'Ouvert');
                  setState(() {
                    isModified = false;
                    widget.annonce.etat =
                        widget.annonce.etat == 'Ouvert' ? 'Fermé' : 'Ouvert';
                  });
                },
                backgroundColor: Theme.of(context).secondaryHeaderColor,
                child: Icon(Icons.save),
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
          title: Text('Attention'),
          content:
              Text('Voulez-vous quitter sans sauvegarder les modifications ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Non'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Oui'),
            ),
          ],
        ),
      );

      return confirm ?? false;
    }

    return true;
  }
}
