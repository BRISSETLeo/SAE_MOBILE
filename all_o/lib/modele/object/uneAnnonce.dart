import 'package:all_o/modele/object/bien.dart';

class UneAnnonce {
  final int id;
  final String description;
  final String debut_acces;
  final String fin_acces;
  final String etat;
  final String categorie;
  final String nom_utilisateur;
  final bool est_annonce;
  final Bien materiel;

  UneAnnonce({
    required this.id,
    required this.description,
    required this.debut_acces,
    required this.fin_acces,
    required this.etat,
    required this.categorie,
    required this.nom_utilisateur,
    required this.est_annonce,
    required this.materiel,
  });

factory UneAnnonce.fromMap(Map<String, dynamic> map) {
  return UneAnnonce(
    id: map['id_annonce'] ?? 0,
    description: map['description'] ?? '',
    debut_acces: map['debut_acces'] ?? '',
    fin_acces: map['fin_acces'] ?? '',
    etat: map['etat'] ?? '',
    categorie: map['categorie'] ?? '',
    nom_utilisateur: map['nom_utilisateur'] ?? '',
    est_annonce: map['est_annonce'] ?? false,
    materiel: Bien.fromMap(map),
  );
}


  List<int>? get image {
    return materiel.image;
  }

  String get titre {
    return materiel.titre;
  }
}