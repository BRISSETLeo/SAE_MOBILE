import 'package:flutter/material.dart';

class Demande extends StatefulWidget {
  const Demande({super.key});

  static const title = "Demandes de prêt";

  @override
  // ignore: library_private_types_in_public_api
  _EcranProfil createState() => _EcranProfil();
}

class _EcranProfil extends State<Demande> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text("Annonce"),
          ],
        ),
      ),
    );
  }
}
