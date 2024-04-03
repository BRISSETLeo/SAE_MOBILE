class UneAnnonce {
  final int id;
  final String titre;
  final String description;
  final String debut_acces;
  final String fin_acces;
  String etat;
  final String categorie;
  final String nom_utilisateur;
  final bool est_annonce;
  final bool a_image;

  UneAnnonce({
    required this.id,
    required this.titre,
    required this.description,
    required this.debut_acces,
    required this.fin_acces,
    required this.etat,
    required this.categorie,
    required this.nom_utilisateur,
    required this.est_annonce,
    required this.a_image,
  });

  factory UneAnnonce.fromMap(Map<String, dynamic> map) {
    return UneAnnonce(
      id: map['id_annonce'] ?? 0,
      titre: map['titre'] ?? '',
      description: map['description'],
      debut_acces: map['debut_acces'],
      fin_acces: map['fin_acces'],
      etat: map['etat'],
      categorie: map['categorie'] ?? '',
      nom_utilisateur: map['nom_utilisateur'],
      est_annonce: map['est_annonce'],
      a_image: map['a_image'] ?? false,
    );
  }
}
