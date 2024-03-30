import 'package:flutter/material.dart';

class Annonce extends StatefulWidget {
  const Annonce({super.key});

  static const title = "Annonce";

  @override
  // ignore: library_private_types_in_public_api
  _EcranProfil createState() => _EcranProfil();
}

class _EcranProfil extends State<Annonce> {
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
