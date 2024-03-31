import 'dart:io';

import 'package:all_o/modele/basededonnees.dart';
import 'package:all_o/vue/monmateriel.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MaterielFormPage extends StatefulWidget {
  const MaterielFormPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MaterielFormPageState createState() => _MaterielFormPageState();
}

class _MaterielFormPageState extends State<MaterielFormPage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late String _categoryValue = '';
  late String _stateValue = '';
  late List<String> categories = [''];
  late List<String> states = [''];
  bool _isAnnouncement = false;
  File? _selectedImage;
  DateTime? _startDate;
  DateTime? _endDate;

  bool _isButtonClicked = false;
  bool _isTitleEmpty = false;

  Future<void> _getImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final cat = BaseDeDonnes.fetchCategories();
    cat.then((value) {
      setState(() {
        categories = value;
        _categoryValue = categories[0];
      });
    });
    final sta = BaseDeDonnes.fetchStates();
    sta.then((value) {
      setState(() {
        states = value;
        _stateValue = states[0];
      });
    });
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: _endDate ?? DateTime(2100),
    );
    if (pickedDate != null) {
      if (_endDate != null && pickedDate.isAfter(_endDate!)) {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Erreur"),
            content: const Text(
                "La date de début ne peut pas être après la date de fin."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          _startDate = pickedDate;
        });
      }
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _endDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter du matériel'),
        centerTitle: true,
        backgroundColor: Theme.of(context).secondaryHeaderColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              GestureDetector(
                onTap: _getImage,
                child: Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : const Icon(Icons.camera_alt,
                          size: 50, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Titre',
                  border: const OutlineInputBorder(),
                  errorText: _isButtonClicked && _isTitleEmpty
                      ? 'Le titre est requis'
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _isTitleEmpty = value.isEmpty;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _categoryValue,
                onChanged: (value) {
                  setState(() {
                    _categoryValue = value!;
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
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _stateValue,
                onChanged: (value) {
                  setState(() {
                    _stateValue = value!;
                  });
                },
                items: states.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'État du matériel',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              Column(
                children: <Widget>[
                  const Text('Annonce', style: TextStyle(fontSize: 16)),
                  Switch(
                    value: _isAnnouncement,
                    onChanged: (value) {
                      setState(() {
                        _isAnnouncement = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              if (_isAnnouncement) ...[
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => _selectStartDate(context),
                      child: Text(
                        _startDate != null
                            ? 'Date de début d\'accessibilité : ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                            : 'Sélectionner une date de début d\'accessibilité',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _selectEndDate(context),
                      child: Text(
                        _endDate != null
                            ? 'Date de fin d\'accessibilité : ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                            : 'Sélectionner une date de fin d\'accessibilité',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isButtonClicked = true;
                    _isTitleEmpty = _titleController.text.isEmpty;
                  });
                  if (_isTitleEmpty) {
                    return;
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmation'),
                        content: const Text(
                            'Êtes-vous sûr de vouloir ajouter ce matériel ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () async {
                              List<int>? imageBytes;
                              if (_selectedImage != null) {
                                imageBytes = _selectedImage!.readAsBytesSync();
                              }
                              await BaseDeDonnes.insererMateriel(
                                _titleController.text,
                                _descriptionController.text,
                                _categoryValue,
                                _stateValue,
                                imageBytes,
                              );
                              Navigator.pushReplacement(
                                // ignore: use_build_context_synchronously
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Materiel(),
                                ),
                              );
                            },
                            child: const Text('Ajouter'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: const Text('Ajouter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
