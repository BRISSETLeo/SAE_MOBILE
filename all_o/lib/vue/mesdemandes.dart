import 'package:flutter/material.dart';
import 'package:all_o/repository/settingsmodel.dart';
import 'package:all_o/modele/basededonnees.dart';
import 'package:all_o/modele/object/uneAnnonce.dart';
import 'package:provider/provider.dart';

class MesDemandes extends StatefulWidget {
  const MesDemandes({Key? key}) : super(key: key);

  @override
  _MesDemandesState createState() => _MesDemandesState();
}

class _MesDemandesState extends State<MesDemandes> {
  late List<UneAnnonce> _demandesAnnonces = [];
  int _visibleItems = 15;
  String _selectedCategory = 'Sélectionnez une catégorie';
  String _selectedState = 'Sélectionnez un état';

  late final List<String> _categories = ['Sélectionnez une catégorie'];
  late final List<String> _states = ['Sélectionnez un état'];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLocalDemandesAnnonces();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final cat = BaseDeDonnes.fetchCategories();
    final sta = BaseDeDonnes.fetchStates();
    final List<dynamic> results = await Future.wait([cat, sta]);
    setState(() {
      _categories.addAll(results[0]);
      _states.addAll(results[1]);
    });
  }

  Future<void> _loadLocalDemandesAnnonces() async {
    final demandesAnnonces = await BaseDeDonnes.fetchMesDemandes(
        context.read<SettingViewModel>().identifiant);
    setState(() {
      _demandesAnnonces = demandesAnnonces;
    });
  }

  void _showMoreItems() {
    setState(() {
      _visibleItems += 15;
    });
  }

  void _deleteAnnonce(int index) async {
    final bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer la demande'),
        content: Text('Voulez-vous vraiment supprimer cette demande ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmDelete != null && confirmDelete) {
      await BaseDeDonnes.supprimerDemande(_demandesAnnonces[index].id);
      setState(() {
        _demandesAnnonces.removeAt(index);
      });
    }
  }

  void _search(String query) {
    if (query.isEmpty) {
      _loadLocalDemandesAnnonces();
    } else {
      setState(() {
        _demandesAnnonces = _demandesAnnonces
            .where((annonce) =>
                annonce.titre.toLowerCase().contains(query.toLowerCase()) ||
                annonce.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  void _filterByCategory(String category) {
    if (category == 'Toutes') {
      _loadLocalDemandesAnnonces();
    } else {
      setState(() {
        _demandesAnnonces = _demandesAnnonces
            .where((annonce) => annonce.categorie == category)
            .toList();
      });
    }
  }

  void _filterByState(String state) {
    if (state == 'Tous') {
      _loadLocalDemandesAnnonces();
    } else {
      setState(() {
        _demandesAnnonces = _demandesAnnonces
            .where((annonce) => annonce.etat == state)
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int ceQuiFautAfficher = _visibleItems < _demandesAnnonces.length
        ? _visibleItems
        : _demandesAnnonces.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Demandes'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownButton<String>(
                value: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                    _filterByCategory(value);
                  });
                },
                items:
                    _categories.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                hint: Text('Catégorie'),
              ),
              DropdownButton<String>(
                value: _selectedState,
                onChanged: (value) {
                  setState(() {
                    _selectedState = value!;
                    _filterByState(value);
                  });
                },
                items: _states.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                hint: Text('État'),
              ),
            ],
          ),
          TextField(
            controller: _searchController,
            onChanged: (query) {
              _search(query);
            },
            decoration: InputDecoration(
              labelText: 'Recherche',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          Expanded(
            child: _demandesAnnonces.isEmpty
                ? Center(
                    child: Text('Aucune demande de prêt n\'a été trouvée.'),
                  )
                : ListView.builder(
                    itemCount: ceQuiFautAfficher,
                    itemBuilder: (context, index) {
                      final demandeAnnonce = _demandesAnnonces[index];
                      return ListTile(
                        title: Text(demandeAnnonce.titre),
                        subtitle: Text(demandeAnnonce.description),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteAnnonce(index),
                        ),
                      );
                    },
                  ),
          ),
          if (_demandesAnnonces.length > _visibleItems)
            TextButton(
              onPressed: _showMoreItems,
              child: Text('Voir plus'),
            ),
        ],
      ),
    );
  }
}
