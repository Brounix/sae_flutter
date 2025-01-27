import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gif_view/gif_view.dart';
import 'package:provider/provider.dart';
import 'package:sae_flutter/data_source/api_manager.dart';
import 'package:sae_flutter/repo/game_repository.dart';
import 'package:sae_flutter/repo/user_repository.dart';
import 'package:sae_flutter/domain/game_detail_notifier.dart';
import 'package:sae_flutter/domain/game_list_notifier.dart';
import 'package:sae_flutter/domain/login_notifier.dart';
import 'package:sae_flutter/domain/profile_notifier.dart';
import 'package:sae_flutter/ui/login.dart';

import 'domain/creation_notifier.dart';
import 'domain/favorite_notifier.dart';
import 'domain/followers_notifier.dart';
import 'domain/neadry_user_notifier.dart';
import 'domain/user_detail_notifier.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoginNotifier(UserRepository(ApiManager())),
        ),
        ChangeNotifierProvider(
          create: (_) => GameListNotifier(GameRepository(ApiManager())),
        ),
        ChangeNotifierProvider(
          create: (_) => GameDetailNotifier(GameRepository(ApiManager())),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileNotifier(UserRepository(ApiManager())),
        ),
        ChangeNotifierProvider(
          create: (_) => CreationNotifier(GameRepository(ApiManager())),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesNotifier(GameRepository(ApiManager())),
        ),
        ChangeNotifierProvider(
          create: (_) => FollowersNotifier(UserRepository(ApiManager())),
        ),
        ChangeNotifierProvider(
          create: (_) => NearbyUsersNotifier(),
        ),
        ChangeNotifierProvider(create: (_) => SelectedUserNotifier()),

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  LoginPage()),
      );
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              SvgPicture.asset(
                'assets/rawg.svg',
                height: 50,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 200,
                child: GifView.asset('assets/splash.gif'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
