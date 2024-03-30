import 'package:all_o/modele/supabase.dart';
import 'package:all_o/repository/settingsmodel.dart';
import 'package:all_o/vue/accueil.dart';
import 'package:all_o/vue/identification.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mytheme.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var db = await openDatabase('my_db.db');
  // Créer la table si elle n'existe pas
  await db.execute(
      'CREATE TABLE IF NOT EXISTS settings (id INTEGER PRIMARY KEY, identifiant TEXT, motdepasse TEXT, isDark INTEGER)');

  // si la table est vide, on insère des valeurs par défaut
  List<Map<String, dynamic>> settings = await db.query('settings');
  if (settings.isEmpty) {
    await db.insert('settings', {
      'identifiant': '',
      'motdepasse': '',
      'isDark': 0,
    });
    print("Insertion des valeurs par défaut");
  }
  print("Valeurs de la table settings: $settings");

  await db.close();
  BaseDeDonnes();
  runApp(const MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          SettingViewModel settingViewModel = SettingViewModel();
          return settingViewModel;
        }),
      ],
      child: Consumer<SettingViewModel>(
        builder: (context, SettingViewModel notifier, child) {
          return MaterialApp(
              theme: notifier.isDark ? MyTheme.dark() : MyTheme.light(),
              title: "ALL'O",
              home: notifier.identifiant == "" || notifier.motdepasse == ""
                  ? const LoginPage()
                  : const Accueil());
        },
      ),
    );
  }
}
