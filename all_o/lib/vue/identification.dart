import 'package:all_o/main.dart';
import 'package:all_o/repository/settingsmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api, no_logic_in_create_state
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isObscure = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // Libérer les ressources du contrôleur de texte
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20.0),
              const Text(
                'Identification',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _usernameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'L\'identifiant est requis';
                  }
                  return null;
                },
                textInputAction: TextInputAction
                    .next, // Passer au champ suivant après avoir appuyé sur "Entrée"
                onEditingComplete: () => FocusScope.of(context)
                    .nextFocus(), // Aller au champ suivant
                decoration: InputDecoration(
                  hintText: 'Entre ton identifiant',
                  labelText: 'Identifiant',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  errorText: _usernameController.text.isEmpty ? null : null,
                ),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _passwordController,
                obscureText: _isObscure,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Le mot de passe est requis';
                  }
                  return null;
                },
                textInputAction: TextInputAction
                    .done, // Exécuter lorsque "Entrée" est pressée
                onEditingComplete: () {
                  // Exécuter le code du bouton lorsque "Entrée" est pressée
                  _submitForm();
                },
                decoration: InputDecoration(
                  hintText: 'Entre ton mot de passe',
                  labelText: 'Mot de passe',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  errorText: _passwordController.text.isEmpty ? null : null,
                ),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _submitForm, // Appeler la méthode _submitForm lorsque le bouton est pressé
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    "Se connecter/S'inscrire",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_usernameController.text.isEmpty ||
          _passwordController.text.isEmpty) {
        setState(() {
          _usernameController.text.isEmpty ? _usernameController.clear() : null;
          _passwordController.text.isEmpty ? _passwordController.clear() : null;
        });
      } else {
        SupabaseClient client = Supabase.instance.client;

        String username = _usernameController.text;
        String password = _passwordController.text;

        client
            .from('utilisateur')
            .select()
            .eq('identifiant', username)
            .eq('motdepasse', password)
            .then((response) {
          if (response.isNotEmpty) {
            context.read<SettingViewModel>().identifiant = username;
            context.read<SettingViewModel>().motdepasse = password;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MyHomePage(),
              ),
            );
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Créer un compte ?'),
                  content: const Text(
                      'Aucun compte trouvé avec ces informations. Voulez-vous créer un nouveau compte ?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        client.from("utilisateur").insert(
                          {
                            'identifiant': username,
                            'motdepasse': password,
                          },
                        ).then((value) {
                          context.read<SettingViewModel>().identifiant =
                              username;
                          context.read<SettingViewModel>().motdepasse =
                              password;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyHomePage(),
                            ),
                          );
                        });
                      },
                      child: const Text('Oui'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Non'),
                    ),
                  ],
                );
              },
            );
          }
        });

        setState(() {
          _usernameController.clear();
          _passwordController.clear();
        });
      }
    }
  }
}
