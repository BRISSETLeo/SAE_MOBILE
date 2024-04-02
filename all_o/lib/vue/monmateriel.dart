import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:all_o/modele/basededonnees.dart';
import 'package:all_o/modele/object/bien.dart';
import 'package:all_o/vue/materialdetail.dart';
import 'package:provider/provider.dart';
import 'package:all_o/repository/settingsmodel.dart';
import 'package:all_o/vue/addmateriel.dart';

class Materiel extends StatefulWidget {
  const Materiel({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MaterielState createState() => _MaterielState();
}

class _MaterielState extends State<Materiel> {
  late List<Bien> _allMateriel = [];
  late List<Bien> _displayedMateriel = [];
  String? _selectedCategory;
  String? _selectedState;
  int _displayedItemCount = 15;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAllMateriel();
  }

  Future<void> _loadAllMateriel() async {
    final allMateriel = await BaseDeDonnes.fetchAllMateriels();
    setState(() {
      _allMateriel = allMateriel;
      _updateDisplayedMateriel();
    });
  }

  void _updateDisplayedMateriel() {
    _displayedMateriel = _allMateriel
        .where((bien) =>
            (bien.titre.toLowerCase().contains(_searchQuery.toLowerCase())) &&
            (_selectedCategory == null ||
                bien.categorie == _selectedCategory) &&
            (_selectedState == null || bien.nomEtat == _selectedState))
        .take(_displayedItemCount)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mon matériel",
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
                  _updateDisplayedMateriel();
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
                          _updateDisplayedMateriel();
                        });
                      },
                      items: [
                        const DropdownMenuItem<String>(
                          value: "Tout",
                          child: Text('Tout'),
                        ),
                        ..._allMateriel
                            .map((bien) => bien.categorie)
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
                    hint: Text('Les états'),
                    value: _selectedState,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedState = newValue == "Tout" ? null : newValue;
                        _updateDisplayedMateriel();
                      });
                    },
                    items: [
                      DropdownMenuItem<String>(
                        value: "Tout",
                        child: Text('Tout'),
                      ),
                      ..._allMateriel
                          .map((bien) => bien.nomEtat)
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
            child: _displayedMateriel.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? _selectedCategory == null && _selectedState == null
                              ? "Aucun matériel à afficher"
                              : _selectedCategory == null &&
                                      _selectedState != null
                                  ? "Aucun matériel à afficher pour cet état"
                                  : _selectedState == null &&
                                          _selectedCategory != null
                                      ? "Aucun matériel à afficher pour cette catégorie"
                                      : "Aucun matériel à afficher pour cette recherche"
                          : "Aucun matériel ne correspond à votre recherche",
                    ),
                  )
                : ListView.builder(
                    itemCount: _displayedMateriel.length +
                        (_allMateriel.length > _displayedItemCount ? 1 : 0),
                    itemBuilder: (BuildContext context, int index) {
                      if (index == _displayedItemCount) {
                        return TextButton(
                          onPressed: () {
                            setState(() {
                              _displayedItemCount += 15;
                              _updateDisplayedMateriel();
                            });
                          },
                          child: Text('Voir plus'),
                        );
                      }
                      final materielItem = _displayedMateriel[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: materielItem.image != null
                              ? Image.memory(
                                  Uint8List.fromList(materielItem.image!),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Icon(Icons.image),
                                ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                materielItem.titre,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'État: ${materielItem.nomEtat}',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MaterielDetailPage(materiel: materielItem),
                              ),
                            );
                          },
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Confirmation'),
                                  content: Text(
                                      'Êtes-vous sûr de vouloir supprimer cet objet ?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Annuler'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await BaseDeDonnes.supprimerMateriel(
                                            materielItem.id,
                                            context
                                                .read<SettingViewModel>()
                                                .identifiant);
                                        setState(() {
                                          _allMateriel.removeWhere((element) =>
                                              element.id == materielItem.id);
                                          _updateDisplayedMateriel();
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Text('Supprimer'),
                                    ),
                                  ],
                                ),
                              );
                            },
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
            return MaterielFormPage(key: UniqueKey());
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
