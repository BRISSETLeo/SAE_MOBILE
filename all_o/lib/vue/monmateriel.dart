import 'dart:typed_data';

import 'package:all_o/modele/basededonnees.dart';
import 'package:all_o/modele/object/bien.dart';
import 'package:all_o/vue/materielDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:all_o/repository/settingsmodel.dart';
import 'package:all_o/vue/addmateriel.dart';

class Materiel extends StatefulWidget {
  const Materiel({Key? key}) : super(key: key);

  @override
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
            (bien.titre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                bien.description
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase())) &&
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
                    hint: const Text('Les états'),
                    value: _selectedState,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedState = newValue == "Tout" ? null : newValue;
                        _updateDisplayedMateriel();
                      });
                    },
                    items: [
                      const DropdownMenuItem<String>(
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
                              ? "Aucun bien à afficher"
                              : _selectedCategory == null &&
                                      _selectedState != null
                                  ? "Aucun bien à afficher pour cet état"
                                  : _selectedState == null &&
                                          _selectedCategory != null
                                      ? "Aucun bien à afficher pour cette catégorie"
                                      : "Aucun bien à afficher pour cette recherche"
                          : "Aucun bien ne correspond à votre recherche",
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
                          child: const Text('Voir plus'),
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
                              : const SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Icon(Icons.image),
                                ),
                          title: Text(
                            materielItem.titre,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(materielItem.description),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MaterielDetailPage(materiel: materielItem),
                              ),
                            );
                          },
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
