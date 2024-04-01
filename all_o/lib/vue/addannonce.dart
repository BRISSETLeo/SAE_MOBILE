import 'dart:typed_data';
import 'package:all_o/repository/settingsmodel.dart';
import 'package:flutter/material.dart';
import 'package:all_o/modele/basededonnees.dart';
import 'package:all_o/modele/object/bien.dart';
import 'package:provider/provider.dart';

class AjouterMateriel extends StatefulWidget {
  const AjouterMateriel({super.key});

  @override
  _AjouterMaterielState createState() => _AjouterMaterielState();
}

class _AjouterMaterielState extends State<AjouterMateriel> {
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
      for (var annonce in _allMateriel) {
        print(annonce.id);
      }
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
          "Choisir un matériel",
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
                          child: const Text('Voir plus'),
                        );
                      }
                      final materielItem = _displayedMateriel[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: ListTile(
                          leading: materielItem.image != null
                              ? Container(
                                  margin: EdgeInsets.all(5),
                                  width: 60,
                                  height: 60,
                                  child: Image.memory(
                                    Uint8List.fromList(materielItem.image!),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Icon(Icons.image),
                                ),
                          title: Text(
                            materielItem.titre,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AjouterAnnonce(materiel: materielItem),
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
    );
  }
}

class AjouterAnnonce extends StatefulWidget {
  final Bien materiel;

  const AjouterAnnonce({Key? key, required this.materiel}) : super(key: key);

  @override
  _AjouterAnnonceState createState() => _AjouterAnnonceState();
}

class _AjouterAnnonceState extends State<AjouterAnnonce> {
  late Bien _materiel;
  bool _publish = false;
  DateTime? _startDate;
  DateTime? _endDate;
  late String _description = '';

  @override
  void initState() {
    super.initState();
    _materiel = widget.materiel;
    print(_materiel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ajouter une annonce",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).secondaryHeaderColor,
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: ListTile(
              leading: _materiel.image != null
                  ? SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.memory(
                        Uint8List.fromList(_materiel.image!),
                        fit: BoxFit.cover,
                      ),
                    )
                  : const SizedBox(
                      width: 60,
                      height: 60,
                      child: Icon(Icons.image),
                    ),
              title: Text(
                _materiel.titre.length > 20
                    ? '${_materiel.titre.substring(0, 20)}...'
                    : _materiel.titre,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _description = value; // Capture de la description
                });
              },
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2025),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _startDate = selectedDate;
                          if (_endDate != null &&
                              _startDate!.isAfter(_endDate!)) {
                            _endDate = _startDate;
                          }
                        });
                      }
                    },
                    child: Text(
                      _startDate != null
                          ? 'Date de début: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                          : 'Sélectionne la date de début',
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2025),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _endDate = selectedDate;
                          if (_startDate != null &&
                              _endDate!.isBefore(_startDate!)) {
                            _startDate = _endDate;
                          }
                          if (_startDate != null &&
                              _endDate!.difference(_startDate!).inDays == 0) {
                            _endDate = _startDate;
                          }
                        });
                      }
                    },
                    child: Text(
                      _endDate != null
                          ? 'Date de fin: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                          : 'Sélectionne la date de fin',
                    ),
                  ),
                ],
              ),
            ],
          ),
          SwitchListTile(
            title: const Text('Publier l\'annonce'),
            value: _publish,
            onChanged: (bool? value) {
              setState(() {
                _publish = value ?? false;
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Confirmation'),
                    content: const Text(
                        'Voulez-vous vraiment ajouter cette annonce ?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          BaseDeDonnes.insererAnnonceSurSupabase(
                            _materiel,
                            context.read<SettingViewModel>().identifiant,
                            _description,
                            _startDate!,
                            _endDate!,
                            _publish,
                          );
                          Navigator.pop(context);
                        },
                        child: const Text('Confirmer'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text('Ajouter l\'annonce'),
          ),
        ],
      ),
    );
  }
}
