import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lista de compras',
      theme: ThemeData(),
      home: const SplashView(),
    );
  }
}

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Future.delayed(const Duration(seconds: 3), () {
    //   context.pushReplacement('/tela da lista');
    // });

    return Scaffold(
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff11ee62), Color(0xffd2f8d6)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              stops: [0.0, 1.0],
            ),
          ),
        ),
        Center(
          child: Image.asset(
            'lib/app/assets/logoapp.png',
            width: 250,
            height: 250,
          ),
        ),
      ]),
    );
  }
}
