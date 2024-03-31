import 'package:supabase_flutter/supabase_flutter.dart';

class BaseDeDonnes {
  BaseDeDonnes() {
    Supabase.initialize(
      url: 'https://xdtyuhdwbjpepbpyelkx.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhkdHl1aGR3YmpwZXBicHllbGt4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTE3OTg2MjgsImV4cCI6MjAyNzM3NDYyOH0.tZBcpfKBs6gKQQOvh4EW1r3vx9rl_VM9h522L32O_M4',
    );
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
