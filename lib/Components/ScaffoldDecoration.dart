import 'package:flutter/material.dart';

BoxDecoration MainScaffoldDecoration() {
  return BoxDecoration(
    gradient: new LinearGradient(
        colors: [
          const Color(0xFF3D3D3D),
          const Color(0xFF1D1D1D),
          const Color(0xFF111111),
          const Color(0xFF5D5D5D),
        ],
        begin: Alignment(-1.0, -1.2),
        end: Alignment(1.0, 1.2),
        stops: [0.0, 0.35, 0.65, 1.0],
        tileMode: TileMode.clamp),
  );
}