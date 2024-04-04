class Bien {
  final int id;
  final String titre;
  final String categorie;
  final String nomEtat;
  final List<int>? image;

  Bien({
    required this.id,
    required this.titre,
    required this.categorie,
    required this.nomEtat,
    this.image,
  });

  factory Bien.fromMap(Map<String, dynamic> map, List<int>? list) {
    return Bien(
      id: map['id_materiel'] ?? 0,
      titre: map['titre'],
      categorie: map['categorie'],
      nomEtat: map['etat'] ?? map['nom_etat'],
      image: list ?? map['image'],
    );
  }
}
