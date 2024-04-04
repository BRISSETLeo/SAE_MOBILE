import 'dart:typed_data';

import 'package:all_o/vue/AnnonceDetailPage.dart';
import 'package:all_o/vue/addDemande.dart';
import 'package:flutter/material.dart';
import 'package:all_o/modele/object/uneAnnonce.dart';
import 'package:all_o/modele/basededonnees.dart';
import 'package:all_o/repository/settingsmodel.dart';
import 'package:provider/provider.dart';


class Demande extends StatefulWidget {
  const Demande({super.key});

  static const title = 'Demandes de prêts';

  @override
  _AnnonceState createState() => _AnnonceState();
}

class _AnnonceState extends State<Demande> {
  late Future<List<UneAnnonce>> _futureAnnonces = Future.value([]);

  @override
  void initState() {
    super.initState();
    _futureAnnonces = _loadAnnonces();
  }

  Future<List<UneAnnonce>> _loadAnnonces() async {
    final annonces = await BaseDeDonnes.fetchAnnonces(
        context.read<SettingViewModel>().identifiant);
      setState(() {
        _futureAnnonces = annonces as Future<List<UneAnnonce>>;
      });
    return annonces;
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<List<UneAnnonce>>(
          future: _futureAnnonces,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Erreur de chargement des annonces');
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return const Text('Aucune annonce à afficher');
            } else {
              final annonces = snapshot.data!;
              return ListView.builder(
                itemCount: annonces.length,
                itemBuilder: (context, index) {
                  final annonce = annonces[index];
                  return ListTile(
                    title: Text(annonce.titre),
                    subtitle: Text(annonce.description),
                    leading: annonce.a_image
                        ? FutureBuilder<List<int>>(
                            future:
                                BaseDeDonnes.fetchImage(annonce.id.toString()),
                            builder: (context, imageSnapshot) {
                              if (imageSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (imageSnapshot.hasError) {
                                return Icon(Icons.error);
                              } else {
                                final imageData = imageSnapshot.data!;
                                return Image.memory(
                                  Uint8List.fromList(imageData),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                );
                              }
                            },
                          )
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AnnonceDetailPage(annonce: annonce),
                        ),
                      );
                    },
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DemandePret(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
