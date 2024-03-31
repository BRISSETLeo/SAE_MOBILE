// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:all_o/modele/basededonnees.dart';
import 'package:all_o/repository/settingsmodel.dart';
import 'package:all_o/vue/monmateriel.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class MaterielFormPage extends StatefulWidget {
  const MaterielFormPage({Key? key}) : super(key: key);

  @override
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
  bool _isStartDateSelected = false;
  bool _isEndDateSelected = false;

  Future<void> _getImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final int sizeInBytes = await imageFile.length();
      final double sizeInMb = sizeInBytes / (1024 * 1024);
      if (sizeInMb > 3) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Image trop grande"),
            content:
                const Text("La taille de l'image ne peut pas dépasser 3 Mo."),
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
          _selectedImage = imageFile;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final cat = BaseDeDonnes.fetchCategories();
    final sta = BaseDeDonnes.fetchStates();
    final List<dynamic> results = await Future.wait([cat, sta]);
    setState(() {
      categories = results[0];
      states = results[1];
      _categoryValue = categories[0];
      _stateValue = states[0];
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
          _isStartDateSelected = true;
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
        _isEndDateSelected = true;
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
                            : _isStartDateSelected
                                ? ''
                                : 'Sélectionner une date de début d\'accessibilité',
                        style: TextStyle(
                          color: _isStartDateSelected
                              ? Theme.of(context).primaryColor == Colors.white
                                  ? Colors.black
                                  : Colors.white
                              : Colors.red,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _selectEndDate(context),
                      child: Text(
                        _endDate != null
                            ? 'Date de fin d\'accessibilité : ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                            : _isEndDateSelected
                                ? ''
                                : 'Sélectionner une date de fin d\'accessibilité',
                        style: TextStyle(
                          color: _isEndDateSelected
                              ? Theme.of(context).primaryColor == Colors.white
                                  ? Colors.black
                                  : Colors.white
                              : Colors.red,
                        ),
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
                  if (_isTitleEmpty ||
                      (_isAnnouncement &&
                          (!_isStartDateSelected || !_isEndDateSelected))) {
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
                                _startDate,
                                _endDate,
                                "En cours...",
                              );
                              if (_isAnnouncement) {
                                await BaseDeDonnes.insererAnnonceSurSupabase(
                                  _titleController.text,
                                  _descriptionController.text,
                                  _startDate!,
                                  _endDate!,
                                  _stateValue,
                                  _categoryValue,
                                  context.read<SettingViewModel>().identifiant,
                                  imageBytes,
                                  _selectedImage,
                                );
                              }
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              Navigator.pushReplacement(
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
