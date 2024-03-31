import 'package:all_o/repository/settingsmodel.dart';
import 'package:all_o/vue/addmateriel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Materiel extends StatefulWidget {
  const Materiel({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EcranMateriel createState() => _EcranMateriel();
}

class _EcranMateriel extends State<Materiel> {
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
        body: const Column(
          children: <Widget>[
            Text("Mon matériel"),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(context));
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
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
    );
  }
}
