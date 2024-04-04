import 'dart:typed_data';

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
    //await deleteDatabase('all_o.db');
    _initialiser = await openDatabase('all_o.db', version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE materiel (id_materiel INTEGER PRIMARY KEY AUTOINCREMENT, titre VARCHAR, categorie VARCHAR, nom_etat VARCHAR, image LONGBLOB)');
      await db.execute(
          'CREATE TABLE annonce (id_annonce INTEGER PRIMARY KEY AUTOINCREMENT, description TEXT, debut_acces Timestamp, fin_acces Timestamp, id_materiel INTEGER, etat VARCHAR, est_annonce BOOLEAN, categorie VARCHAR)');
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

  static Future<void> supprimerMateriel(int id, String identifiant) async {
    await _initialiser
        .delete('materiel', where: 'id_materiel = ?', whereArgs: [id]);
    await _initialiser
        .delete('annonce', where: 'id_materiel = ?', whereArgs: [id]);

    await Supabase.instance.client
        .from('materiel')
        .select('id_materiel')
        .eq('id_bien_utilisateur', id)
        .eq('nom_utilisateur', identifiant)
        .then((value) async => {
              for (int i = 0; i < value.length; i++)
                {
                  await Supabase.instance.client
                      .from('annonce')
                      .delete()
                      .eq('id_materiel', value[i]['id_materiel'])
                }
            });

    await Supabase.instance.client
        .from('materiel')
        .delete()
        .eq('id_bien_utilisateur', id)
        .eq('nom_utilisateur', identifiant);

    print('Materiel supprimé');
  }

  static Future<List<Bien>> fetchAllMateriels() async {
    final List<Map<String, dynamic>> materiels =
        await _initialiser.query('materiel');
    return materiels.map((map) => Bien.fromMap(map, null)).toList();
  }

  static Future<void> insererAnnonceSurSupabase(
      Bien materiel,
      String identifiant,
      String description,
      DateTime debutAcces,
      DateTime finAcces,
      bool estPubliee) async {
    String debutAccesString = debutAcces.toIso8601String();
    String finAccesString = finAcces.toIso8601String();

    final response = await Supabase.instance.client.from("materiel").insert(
      {
        'id_bien_utilisateur': materiel.id,
        'nom_utilisateur': identifiant,
        'titre': materiel.titre,
        'categorie': materiel.categorie,
        'etat': materiel.nomEtat,
        'image': materiel.image != null ? materiel.id : null,
      },
    );

    if (response != null && response.error != null) {
      print('Erreur lors de l\'insertion de l\'annonce');
      return;
    }

    final int idMateriel =
        await recupererIdMaterielAPArtirDunTitre(materiel.titre);

    final response2 = await Supabase.instance.client.from("annonce").insert(
      {
        'description': description,
        'debut_acces': debutAccesString,
        'fin_acces': finAccesString,
        'id_materiel': idMateriel,
        'etat': estPubliee ? 'Ouvert' : 'Fermé',
        'nom_utilisateur': identifiant,
      },
    );

    if (response2 != null && response2.error != null) {
      print('Erreur lors de l\'insertion de l\'annonce');
      return;
    }

    if (materiel.image != null) {
      await Supabase.instance.client.storage
          .from('annonce')
          .download('annonce/${materiel.id}.jpg')
          .then((value) => {
                if (value.isEmpty)
                  {
                    Supabase.instance.client.storage
                        .from('annonce')
                        .uploadBinary('annonce/${materiel.id}.jpg',
                            Uint8List.fromList(materiel.image!))
                  }
              });
    }

    await _initialiser.insert('annonce', {
      'description': description,
      'debut_acces': debutAccesString,
      'fin_acces': finAccesString,
      'id_materiel': idMateriel,
      'etat': estPubliee ? 'Ouvert' : 'Fermé',
      'est_annonce': true,
    });

    print('Annonce ajoutée');
  }

  static Future<int> recupererIdMaterielAPArtirDunTitre(String titre) async {
    final response = await Supabase.instance.client
        .from('materiel')
        .select('id_materiel')
        .eq('titre', titre)
        .order('id_materiel', ascending: false)
        .limit(1);
    if (response.isEmpty) {
      return -1;
    }
    final List<dynamic> data = response;
    final int idMateriel = data[0]['id_materiel'];
    return idMateriel;
  }

  static Future<List<UneAnnonce>> fetchAnnonces() async {
    final response = await Supabase.instance.client.from('annonce').select();
    final materielResponse =
        await Supabase.instance.client.from('materiel').select();

    if (response.isEmpty) {
      return [];
    }

    final List<dynamic> annonceData = response;
    final List<dynamic> materielData = materielResponse;

    final Map<int, dynamic> materielMap = {};

    for (var materielEntry in materielData) {
      materielMap[materielEntry['id']] = materielEntry;
    }

    final List<UneAnnonce> annonces = [];

    for (var annonceEntry in annonceData) {
      final materielId = annonceEntry['id_materiel'];
      final materielInfo = materielMap[materielId];
      if (materielInfo != null) {
        annonces.add(UneAnnonce.fromMap(annonceEntry, materielInfo));
      } else {
        annonces.add(UneAnnonce.fromMap(annonceEntry, null));
      }
    }

    return annonces;
  }

  static Future<List<int>> fetchImage(String nomImage) async {
    final response = await Supabase.instance.client.storage
        .from('annonce')
        .download('annonce/$nomImage.jpg');
    final List<int> image = response;
    return image;
  }

  static Future<void> ajouterUneDemandes(String categorie, String description,
      DateTime debutAcces, DateTime finAcces, String nomUtilisateur) async {
    String debutAccesString = debutAcces.toIso8601String();
    String finAccesString = finAcces.toIso8601String();
    final response2 = await Supabase.instance.client.from("annonce").insert(
      {
        'description': description,
        'categorie': categorie,
        'etat': 'Ouvert',
        'debut_acces': debutAccesString,
        'fin_acces': finAccesString,
        'est_annonce': false,
        'nom_utilisateur': nomUtilisateur,
      },
    );

    if (response2 != null && response2.error != null) {
      print('Erreur lors de l\'insertion de la demande');
      return;
    }

    await _initialiser.insert('annonce', {
      'description': description,
      'categorie': categorie,
      'etat': 'Ouvert',
      'debut_acces': debutAccesString,
      'fin_acces': finAccesString,
      'est_annonce': false,
    });

    print('Demandes ajoutée');
  }

  static Future<List<UneAnnonce>> fetchMesDemandes(String identifiant) async {
    final response = await Supabase.instance.client
        .from('annonce')
        .select()
        .eq('nom_utilisateur', identifiant)
        .eq('est_annonce', false);
    if (response.isEmpty) {
      final List<Map<String, dynamic>> annonces =
          await _initialiser.query('annonce');
      return annonces.map((map) => UneAnnonce.fromMap(map, null)).toList();
    }
    final List<dynamic> data = response;
    final List<UneAnnonce> annonces =
        data.map((e) => UneAnnonce.fromMap(e, null)).toList();
    final List<Map<String, dynamic>> annoncesLocales =
        await _initialiser.query('annonce');
    for (int i = 0; i < annonces.length; i++) {
      if (annoncesLocales.length <= i) {
        continue;
      }
      if (annonces[i].etat != annoncesLocales[i]['etat']) {
        await _initialiser.update('annonce', {'etat': annonces[i].etat},
            where: 'id_annonce = ?', whereArgs: [annonces[i].id]);
      }
    }
    return annonces;
  }

  static Future<List<UneAnnonce>> fetchMesAnnonces(String identifiant) async {
    final response = await Supabase.instance.client
        .from('annonce')
        .select()
        .eq('nom_utilisateur', identifiant)
        .eq('est_annonce', true);

    if (response.isEmpty) {
      final List<Map<String, dynamic>> annoncesData =
          await _initialiser.query('annonce');
      return annoncesData.map((map) => UneAnnonce.fromMap(map, null)).toList();
    }

    final List<dynamic> annonceData = response;
    final List<Map<String, dynamic>> annoncesLocales =
        await _initialiser.query('annonce');

    final List<UneAnnonce> annonces = [];

    final materielResponse =
        await Supabase.instance.client.from('materiel').select();
    final List<dynamic> materielData = materielResponse;
    final Map<int, dynamic> materielMap = {};
    for (var materielEntry in materielData) {
      materielMap[materielEntry['id_materiel']] = materielEntry;
    }

    for (int i = 0; i < annonceData.length; i++) {
      final annonceEntry = annonceData[i];
      final materielId = annonceEntry['id_materiel'];
      final materielInfo = materielMap[materielId];

      final annonce = materielInfo != null
          ? UneAnnonce.fromMap(
              annonceEntry,
              Bien.fromMap(
                  materielInfo,
                  materielInfo['image'] != null
                      ? await fetchImage(materielInfo['image'].toString())
                      : null))
          : UneAnnonce.fromMap(annonceEntry, null);

      annonces.add(annonce);

      if (annoncesLocales.length <= i) {
        continue;
      }

      if (annonce.etat != annoncesLocales[i]['etat']) {
        await _initialiser.update('annonce', {'etat': annonce.etat},
            where: 'id_annonce = ?', whereArgs: [annonce.id]);
      }
    }

    return annonces;
  }

  static Future<void> publierAnnonce(int id, String etat) async {
    await _initialiser.update('annonce', {'etat': etat},
        where: 'id_annonce = ?', whereArgs: [id]);
    await Supabase.instance.client
        .from('annonce')
        .update({'etat': etat}).eq('id_annonce', id);
    print('Annonce publiée $etat');
  }

  static Future<void> supprimerAnnonce(int id) async {
    await _initialiser
        .delete('annonce', where: 'id_annonce = ?', whereArgs: [id]);
    await Supabase.instance.client
        .from('annonce')
        .delete()
        .eq('id_annonce', id);
    print('Annonce supprimée');
  }

  static Future<void> supprimerDemande(int id) async {
    await _initialiser
        .delete('annonce', where: 'id_annonce = ?', whereArgs: [id]);
    await Supabase.instance.client
        .from('annonce')
        .delete()
        .eq('id_annonce', id);
    print('Demande supprimée');
  }
}
