import 'dart:typed_data';

import 'package:all_o/modele/basededonnees.dart';
import 'package:all_o/modele/object/bien.dart';
import 'package:all_o/vue/materielDetailPage.dart';
import 'package:flutter/material.dart';
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
  List<Bien> _allMateriel = [];
  List<Bien> _displayedMateriel = [];
  String? _selectedCategory;
  int _displayedItemCount = 15;

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
    _displayedMateriel = _selectedCategory == null
        ? _allMateriel.take(_displayedItemCount).toList()
        : _allMateriel.where((bien) => bien.categorie == _selectedCategory).take(_displayedItemCount).toList();
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
      body: _allMateriel.isEmpty
          ? const Center(child: Text("Aucun bien à afficher"))
          : Column(
              children: [
                DropdownButton<String>(
                  hint: const Text('Sélectionnez une catégorie'),
                  value: _selectedCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue == "Tout" ? null : newValue;
                      _updateDisplayedMateriel();
                    });
                  },
                  items: [
                    const DropdownMenuItem<String>(
                      value: "Tout",
                      child: Text('Tout'),
                    ),
                    ..._allMateriel.map((bien) => bien.categorie).toSet().toList().map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _displayedMateriel.length + (_allMateriel.length > _displayedItemCount ? 1 : 0),
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
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                    builder: (context) => MaterielDetailPage(materiel: materielItem),
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
          color: context.read<SettingViewModel>().isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
