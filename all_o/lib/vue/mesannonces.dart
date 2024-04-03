import 'package:all_o/modele/object/uneAnnonce.dart';
import 'package:all_o/vue/addannonce.dart';
import 'package:all_o/vue/monAnnonceDetail.dart';
import 'package:flutter/material.dart';
import 'package:all_o/modele/basededonnees.dart';
import 'package:provider/provider.dart';
import 'package:all_o/repository/settingsmodel.dart';

class MesAnnonces extends StatefulWidget {
  const MesAnnonces({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MesDemandesPretsState createState() => _MesDemandesPretsState();
}

class _MesDemandesPretsState extends State<MesAnnonces> {
  late List<UneAnnonce> _allDemandesPrets = [];
  late List<UneAnnonce> _displayedDemandesPrets = [];
  String? _selectedCategory;
  String? _selectedState;
  int _displayedItemCount = 15;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAllDemandesPrets();
  }

  Future<void> _loadAllDemandesPrets() async {
    final allDemandesPrets = await BaseDeDonnes.fetchMesAnnonces(
        context.read<SettingViewModel>().identifiant);
    setState(() {
      _allDemandesPrets = allDemandesPrets;
      _updateDisplayedDemandesPrets();
    });
  }

  void _updateDisplayedDemandesPrets() {
    _displayedDemandesPrets = _allDemandesPrets
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
          "Mes annonces",
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
                        ..._allDemandesPrets
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
                    hint: Text('Les états'),
                    value: _selectedState,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedState = newValue == "Tout" ? null : newValue;
                        _updateDisplayedDemandesPrets();
                      });
                    },
                    items: [
                      DropdownMenuItem<String>(
                        value: "Tout",
                        child: Text('Tout'),
                      ),
                      ..._allDemandesPrets
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
                        (_allDemandesPrets.length > _displayedItemCount
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
                          child: Text('Voir plus'),
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
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                demandePret.description,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                  height:
                                      4), // Ajoute un espace entre la description et l'état
                              Text(
                                'État: ${demandePret.etat}',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirmation'),
                                  content: const Text(
                                      'Êtes-vous sûr de vouloir supprimer cette demande de prêt ?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Annuler'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await BaseDeDonnes.supprimerDemande(
                                            demandePret.id);
                                        setState(() {
                                          _allDemandesPrets.removeWhere(
                                              (element) =>
                                                  element.id == demandePret.id);
                                          _updateDisplayedDemandesPrets();
                                        });
                                        // ignore: use_build_context_synchronously
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Supprimer'),
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
