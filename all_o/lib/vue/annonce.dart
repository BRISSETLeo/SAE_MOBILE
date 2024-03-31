import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:all_o/modele/object/uneAnnonce.dart';
import 'package:all_o/vue/AnnonceDetailPage.dart';
import 'package:all_o/modele/basededonnees.dart';

class Annonce extends StatefulWidget {
  const Annonce({super.key});

  static const title = 'Annonces';

  @override
  // ignore: library_private_types_in_public_api
  _AnnonceState createState() => _AnnonceState();
}

class _AnnonceState extends State<Annonce> {
  late List<UneAnnonce> _futureAnnonces = [];

  @override
  void initState() {
    super.initState();
    _loadAnnonces();
  }

  void _loadAnnonces() async {
    final annonces = await BaseDeDonnes.fetchAnnonces();
    setState(() {
      _futureAnnonces = annonces;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<UneAnnonce>>(
        future: Future.value(_futureAnnonces),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur de chargement des annonces'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(child: Text('Aucune annonce à afficher'));
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
    );
  }
}
