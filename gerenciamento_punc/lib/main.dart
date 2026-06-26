import 'package:flutter/material.dart';
import './nucleo/temas/appTheme.dart';


Future<void> main() async {

  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: PUNCAppTheme.theme,
        darkTheme: PUNCAppTheme.darkTheme,
        home: const PaginaEntrada(),
      )
    );
}