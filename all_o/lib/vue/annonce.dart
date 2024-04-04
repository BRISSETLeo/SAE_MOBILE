import 'dart:typed_data';

import 'package:all_o/modele/object/uneAnnonce.dart';
import 'package:all_o/vue/addannonce.dart';
import 'package:all_o/vue/monAnnonceDetail.dart';
import 'package:flutter/material.dart';
import 'package:all_o/modele/basededonnees.dart';
import 'package:provider/provider.dart';
import 'package:all_o/repository/settingsmodel.dart';

class Annonce extends StatefulWidget {
  const Annonce({super.key});

  static const title = 'Annonces';

  @override
  _AnnonceState createState() => _AnnonceState();
}

class _AnnonceState extends State<Annonce> {
  late List<UneAnnonce> _futureAnnonces = [];
  late List<UneAnnonce> _displayedDemandesPrets = [];
  String? _selectedCategory;
  String? _selectedState;
  int _displayedItemCount = 15;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAnnonces();
  }

  Future<List<UneAnnonce>> _loadAnnonces() async {
    final annonces = await BaseDeDonnes.fetchAnnonces(
        context.read<SettingViewModel>().identifiant);
      setState(() {
        _futureAnnonces = annonces;
        _updateDisplayedDemandesPrets();
      });
    return annonces;
  }

  void _updateDisplayedDemandesPrets() {
    _displayedDemandesPrets = _futureAnnonces
        .where((demande) =>
            (demande.description
                .toLowerCase()
                .contains(_searchQuery.toLowerCase())) &&
            (_selectedCategory == null ||
                demande.categorie == _selectedCategory) &&
            (_selectedState == null || demande.etat == _selectedState))
        .take(_displayedItemCount)
        .toList();
  }


@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).secondaryHeaderColor,
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Recherche',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _updateDisplayedDemandesPrets();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Les catégories'),
                      value: _selectedCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory =
                              newValue == "Tout" ? null : newValue;
                          _updateDisplayedDemandesPrets();
                        });
                      },
                      items: [
                        const DropdownMenuItem<String>(
                          value: "Tout",
                          child: Text('Tout'),
                        ),
                        ..._futureAnnonces
                            .map((demande) => demande.categorie)
                            .toSet()
                            .toList()
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Les états'),
                    value: _selectedState,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedState = newValue == "Tout" ? null : newValue;
                        _updateDisplayedDemandesPrets();
                      });
                    },
                    items: [
                      const DropdownMenuItem<String>(
                        value: "Tout",
                        child: Text('Tout'),
                      ),
                      ..._futureAnnonces
                          .map((demande) => demande.etat)
                          .toSet()
                          .toList()
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _displayedDemandesPrets.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? _selectedCategory == null && _selectedState == null
                              ? "Aucune annonce à afficher"
                              : _selectedCategory == null &&
                                      _selectedState != null
                                  ? "Aucune anonce à afficher pour cet état"
                                  : _selectedState == null &&
                                          _selectedCategory != null
                                      ? "Aucune annonce à afficher pour cette catégorie"
                                      : "Aucune annonce à afficher pour cette recherche"
                          : "Aucune annonce ne correspond à votre recherche",
                    ),
                  )
                : ListView.builder(
                    itemCount: _displayedDemandesPrets.length +
                        (_futureAnnonces.length > _displayedItemCount
                            ? 1
                            : 0),
                    itemBuilder: (BuildContext context, int index) {
                      if (index == _displayedItemCount) {
                        return TextButton(
                          onPressed: () {
                            setState(() {
                              _displayedItemCount += 15;
                              _updateDisplayedDemandesPrets();
                            });
                          },
                          child: const Text('Voir plus'),
                        );
                      }
                      final demandePret = _displayedDemandesPrets[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return MonAnnonceDetailPage(
                                annonce: demandePret,
                                onStateChanged: (bool newState) {
                                  setState(() {
                                    demandePret.etat =
                                        newState ? 'Ouvert' : 'Fermé';
                                  });
                                },
                              );
                            }));
                          },
                          title: Row(
                            children: [
                              if (demandePret.materiel != null)
                                Image.memory(
                                  Uint8List.fromList(
                                      demandePret.materiel?.image ?? []),
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.cover,
                                ),
                              const SizedBox(
                                  width:
                                      10), // Ajoute un espace entre l'image et le texte
                              Column(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start, // Alignement à gauche
                                children: [
                                  Text(
                                    demandePret.description,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'État: ${demandePret.etat}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          subtitle: Text(
                            demandePret.categorie,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
                          
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const AjouterMateriel();
          }));
        },
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        child: Icon(
          Icons.add,
          color: context.read<SettingViewModel>().isDark
              ? Colors.white
              : Colors.black,
        ),
      ),
    );
  }
}
