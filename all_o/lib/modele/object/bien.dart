class Bien {
  final int id;
  final String titre;
  final String description;
  final String categorie;
  final String nomEtat;
  final List<int>? image;

  Bien({
    required this.id,
    required this.titre,
    required this.description,
    required this.categorie,
    required this.nomEtat,
    this.image,
  });

  factory Bien.fromMap(Map<String, dynamic> map) {
    return Bien(
      id: map['id_materiel'] ?? 0,
      titre: map['titre'],
      description: map['description'],
      categorie: map['categorie'],
      nomEtat: map['nom_etat'],
      image: map['image'] != null ? List<int>.from(map['image']) : null,
    );
  }

}