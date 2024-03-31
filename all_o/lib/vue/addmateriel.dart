import 'dart:io';

import 'package:flutter/material.dart';
import 'package:all_o/modele/basededonnees.dart';
import 'package:all_o/vue/monmateriel.dart';
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
  late String _categoryValue = '';
  late String _stateValue = '';
  late List<String> categories = [''];
  late List<String> states = [''];
  bool _isButtonClicked = false;
  bool _isTitleEmpty = false;
  File? _selectedImage;

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
                                _categoryValue,
                                _stateValue,
                                imageBytes,
                              );
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
