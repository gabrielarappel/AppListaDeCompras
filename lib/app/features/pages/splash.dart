import 'package:flutter/material.dart';

class SplashView extends StatefulWidget {
  final Widget nextPage;

  const SplashView({Key? key, required this.nextPage}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateToNextPage();
  }

  void _navigateToNextPage() async {
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => widget.nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        child: Stack(children: [
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
              'lib/app/assets/logo_app.png',
              width: 310,
              height: 310,
            ),
          ),
        ]),
        onTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => widget.nextPage),
        ),
      ),
    );
  }
}
