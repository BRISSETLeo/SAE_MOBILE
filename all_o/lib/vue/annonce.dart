import 'dart:typed_data';
import 'package:all_o/vue/AnnonceDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:all_o/modele/object/uneAnnonce.dart';
import 'package:all_o/modele/basededonnees.dart';

class Annonce extends StatefulWidget {
  const Annonce({Key? key}) : super(key: key);

  @override
  _AnnonceState createState() => _AnnonceState();
}

class _AnnonceState extends State<Annonce> {
  late List<UneAnnonce> _annonces = [];

  @override
  void initState() {
    super.initState();
    _loadAnnonces();
  }

  void _loadAnnonces() async {
    final annonces = await BaseDeDonnes.fetchAnnonces();
    setState(() {
      _annonces = annonces;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Annonces'),
      ),
      body: Center(
        child: _annonces.isEmpty
            ? CircularProgressIndicator()
            : ListView.builder(
                itemCount: _annonces.length,
                itemBuilder: (context, index) {
                  final annonce = _annonces[index];
                  return ListTile(
                    title: Text(annonce.description),
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
              ),
      ),
    );
  }
}