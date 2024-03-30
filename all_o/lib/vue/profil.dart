import 'package:all_o/mytheme.dart';
import 'package:all_o/repository/settingsmodel.dart';
import 'package:all_o/vue/identification.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:provider/provider.dart';

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EcranProfil createState() => _EcranProfil();
}

class _EcranProfil extends State<Profil> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Ajout de padding
        child: Center(
          child: SettingsList(
            darkTheme: SettingsThemeData(
              settingsListBackground: MyTheme.dark().scaffoldBackgroundColor,
              settingsSectionBackground: MyTheme.dark().scaffoldBackgroundColor,
            ),
            lightTheme: SettingsThemeData(
              settingsListBackground: MyTheme.light().scaffoldBackgroundColor,
              settingsSectionBackground:
                  MyTheme.light().scaffoldBackgroundColor,
            ),
            sections: [
              SettingsSection(
                tiles: [
                  SettingsTile(
                    title: const Text("Mes prêts"),
                    leading: const Icon(Icons.library_books),
                    onPressed: (BuildContext context) {
                      // Add your logic here
                    },
                  ),
                  SettingsTile(
                    title: const Text("Mes réservations"),
                    leading: const Icon(Icons.event_available),
                    onPressed: (BuildContext context) {
                      // Add your logic here
                    },
                  ),
                  SettingsTile(
                    title: const Text("Mon matériel"),
                    leading: const Icon(Icons.devices),
                    onPressed: (BuildContext context) {},
                  ),
                  SettingsTile.switchTile(
                    initialValue: context.watch<SettingViewModel>().isDark,
                    onToggle: (bool value) {
                      context.read<SettingViewModel>().isDark = value;
                    },
                    title: const Text('Mode Sombre'),
                    leading: const Icon(Icons.invert_colors),
                  ),
                  SettingsTile(
                    title: const Text("Se déconnecter"),
                    leading: const Icon(Icons.logout),
                    onPressed: (BuildContext context) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Se déconnecter"),
                            content: const Text(
                              "Voulez-vous vraiment vous déconnecter?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Annuler"),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<SettingViewModel>().identifiant =
                                      "";
                                  context.read<SettingViewModel>().motdepasse =
                                      "";
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginPage(),
                                    ),
                                  );
                                },
                                child: const Text("Se déconnecter"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
