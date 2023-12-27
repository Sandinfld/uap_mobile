import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import 'ember_quest.dart';
import 'overlays/game_over.dart';  // Import file auth.dart yang telah dibuat

void main() {
  runApp(
    GameWidget<EmberQuestGame>.controlled(
      gameFactory: () => EmberQuestGame(),
      overlayBuilderMap: {
        'MainMenu': (_, game) => MainMenu(game: game),
        'GameOver': (_, game) => GameOver(game: game),
      },
      initialActiveOverlays: const ['MainMenu'],
    ),
  );
}

class MainMenu extends StatelessWidget {
  final EmberQuestGame game;
  final AuthService _auth = AuthService();  // Buat instansiasi AuthService

  MainMenu({required this.game, super.key});

  @override
  Widget build(BuildContext context) {
    const blackTextColor = Color.fromRGBO(0, 0, 0, 1.0);
    const whiteTextColor = Color.fromRGBO(255, 255, 255, 1.0);

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          height: 270,
          width: 300,
          decoration: const BoxDecoration(
            color: blackTextColor,
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Ember Quest',
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 75,
                child: ElevatedButton(
                  onPressed: () async {
                    // Ganti dengan fungsi login yang sesuai
                    User? user = await _auth.signInWithEmailAndPassword(
                      'email@example.com',
                      'password',
                    );

                    if (user != null) {
                      // Jika berhasil login, mulai permainan
                      game.overlays.remove('MainMenu');
                    } else {
                      // Jika gagal login, tampilkan pesan atau action sesuai kebutuhan
                      // Contoh:
                      print('Login failed');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteTextColor,
                  ),
                  child: const Text(
                    'Play',
                    style: TextStyle(
                      fontSize: 40.0,
                      color: blackTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Use WASD or Arrow Keys for movement.\n'
                'Space bar to jump.\n'
                'Collect as many stars as you can and avoid enemies!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
