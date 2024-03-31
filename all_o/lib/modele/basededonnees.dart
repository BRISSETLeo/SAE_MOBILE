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
          'CREATE TABLE materiel (id_materiel INTEGER AUTO_INCREMENT PRIMARY KEY, titre VARCHAR, description TEXT, categorie VARCHAR, nom_etat VARCHAR, image LONGBLOB)');
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

  static Future<void> insererMateriel(String nom, String description,
      String nomCat, String nomEtat, List<int>? image) async {
    await _initialiser.insert('materiel', {
      'titre': nom,
      'description': description,
      'categorie': nomCat,
      'nom_etat': nomEtat,
      'image': image,
    });
    print('Materiel ajouté');
  }

  static Future<List<Bien>> fetchAllMateriels() async {
    final List<Map<String, dynamic>> materiels = await _initialiser.query('materiel');
    return materiels.map((map) => Bien.fromMap(map)).toList();
  }

  // recupere les annonces
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
