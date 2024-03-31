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
    _initialiser = await openDatabase('all_o.db', version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE categorie (id_cat INTEGER PRIMARY KEY, nom_cat TEXT)');
      await db.execute('CREATE TABLE etat (nom_etat VARCHAR PRIMARY KEY)');
      await db.execute(
          'CREATE TABLE materiel (id_materiel INTEGER PRIMARY KEY, nom_materiel TEXT, description TEXT, id_cat INTEGER, nom_etat VARCHAR, FOREIGN KEY (id_cat) REFERENCES categorie(id_cat), FOREIGN KEY (nom_etat) REFERENCES etat(nom_etat))');
      print('Tables créées');
    });
  }

  static Future<void> insererMateriel(
      String nom, String description, int idCat) async {
    await _initialiser.insert('materiel',
        {'nom_materiel': nom, 'description': description, 'id_cat': idCat});
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
}
