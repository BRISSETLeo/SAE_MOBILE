import 'package:all_o/modele/supabase.dart';
import 'package:all_o/repository/settingsmodel.dart';
import 'package:all_o/vue/identification.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mytheme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
                  : const MyHomePage());
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Hello World!',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
