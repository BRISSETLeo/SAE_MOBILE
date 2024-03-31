import 'dart:io';

import 'package:all_o/modele/object/bien.dart';
import 'package:all_o/modele/object/uneAnnonce.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite/sqflite.dart';

class BaseDeDonnes {
  // stocker la bd
  static late Database _initialiser;
  BaseDeDonnes() {
    Supabase.initialize(
      url: 'https://xdtyuhdwbjpepbpyelkx.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhkdHl1aGR3YmpwZXBicHllbGt4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTE3OTg2MjgsImV4cCI6MjAyNzM3NDYyOH0.tZBcpfKBs6gKQQOvh4EW1r3vx9rl_VM9h522L32O_M4',
    );
    initialiserBaseDeDonnees();
  }

  static Future<void> initialiserBaseDeDonnees() async {
    await deleteDatabase('all_o.db');
    _initialiser = await openDatabase('all_o.db', version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE materiel (id_materiel INTEGER AUTO_INCREMENT PRIMARY KEY, titre VARCHAR, categorie VARCHAR, nom_etat VARCHAR, image LONGBLOB)');
      print('Tables créées');
    });
  }

  static Future<List<String>> fetchCategories() async {
    final response =
        await Supabase.instance.client.from('categorie').select('nom_cat');
    if (response.isEmpty) {
      return [];
    }
    final List<dynamic> data = response;
    final List<String> categories =
        data.map((e) => e['nom_cat'].toString()).toList();
    return categories;
  }

  static Future<List<String>> fetchStates() async {
    final response =
        await Supabase.instance.client.from('etatbien').select('nom_etat_bien');
    if (response.isEmpty) {
      return [];
    }
    final List<dynamic> data = response;
    final List<String> states =
        data.map((e) => e['nom_etat_bien'].toString()).toList();
    return states;
  }

  static Future<void> insererMateriel(
      String nom, String nomCat, String nomEtat, List<int>? image) async {
    await _initialiser.insert('materiel', {
      'titre': nom,
      'categorie': nomCat,
      'nom_etat': nomEtat,
      'image': image,
    });
    print('Materiel ajouté');
  }

  static Future<void> supprimerMateriel(int id) async {
    await _initialiser
        .delete('materiel', where: 'id_materiel = ?', whereArgs: [id]);
    print('Materiel supprimé');
  }

  static Future<List<Bien>> fetchAllMateriels() async {
    final List<Map<String, dynamic>> materiels =
        await _initialiser.query('materiel');
    return materiels.map((map) => Bien.fromMap(map)).toList();
  }

  static Future<void> insererAnnonceSurSupabase(
      String titre,
      String description,
      DateTime debutAcces,
      DateTime finAcces,
      String etat,
      String categorie,
      String nomUtilisateur,
      List<int>? image,
      File? imageFile) async {
    String debutAccesString = debutAcces.toIso8601String();
    String finAccesString = finAcces.toIso8601String();

    await Supabase.instance.client.from('annonce').insert([
      {
        'titre': titre,
        'description': description,
        'debut_acces': debutAccesString,
        'fin_acces': finAccesString,
        'categorie': categorie,
        'nom_utilisateur': nomUtilisateur,
        'est_annonce': true,
        'etatBien': etat,
        'a_image': image != null ? true : false
      }
    ]);
    if (image != null && imageFile != null) {
      final response = await Supabase.instance.client
          .from('annonce')
          .select('max(id_annonce)')
          .eq('titre', titre)
          .eq('description', description)
          .eq('debut_acces', debutAccesString)
          .eq('fin_acces', finAccesString)
          .eq('categorie', categorie)
          .eq('nom_utilisateur', nomUtilisateur)
          .eq('est_annonce', true)
          .eq('etatBien', etat)
          .eq('a_image', true);
      if (response.isEmpty) {
        return;
      }
      final int id = response[0]['max(id_annonce)'] as int;
      await Supabase.instance.client.storage
          .from('annonce')
          .upload('annonce/$id.jpg', imageFile);
      print('Image ajoutée');
    }
    print('Annonce ajoutée');
  }

  static Future<List<UneAnnonce>> fetchAnnonces() async {
    final response = await Supabase.instance.client.from('annonce').select();
    if (response.isEmpty) {
      return [];
    }
    final List<dynamic> data = response;
    final List<UneAnnonce> annonces =
        data.map((e) => UneAnnonce.fromMap(e)).toList();
    return annonces;
  }

  static Future<List<int>> fetchImage(String nomImage) async {
    final response = await Supabase.instance.client.storage
        .from('annonce')
        .download('annonce/$nomImage.jpg');
    final List<int> image = response;
    return image;
  }
}
