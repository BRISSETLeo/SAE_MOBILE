// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:all_o/modele/basededonnees.dart';

class DemandePret extends StatefulWidget {
  const DemandePret({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DemandePretState createState() => _DemandePretState();
}

class _DemandePretState extends State<DemandePret> {
  late String _selectedCategory = '';
  late TextEditingController _descriptionController;
  late List<String> categories = [''];
  late DateTime _startDate = DateTime.now();
  late DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final cat = BaseDeDonnes.fetchCategories();
    final List<dynamic> results = await Future.wait([cat]);
    setState(() {
      categories = results[0];
      _selectedCategory = categories[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajouter une demande de prêt',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                items: categories.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description de la demande',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
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
                        });
                      }
                    },
                    child: Text(
                      'Date de début: ${_startDate.day}/${_startDate.month}/${_startDate.year}',
                    ),
                  ),
                  TextButton(
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
                        });
                      }
                    },
                    child: Text(
                      'Date de fin: ${_endDate.day}/${_endDate.month}/${_endDate.year}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Ajouter la demande de prêt'),
                        content: const Text(
                            'Voulez-vous vraiment ajouter cette demande de prêt ?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () {
                              BaseDeDonnes.ajouterUneDemandes(
                                _selectedCategory,
                                _descriptionController.text,
                                _startDate,
                                _endDate,
                              );
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Ajouter'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Ajouter la demande de prêt'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
