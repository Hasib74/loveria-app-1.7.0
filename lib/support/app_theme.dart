import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// Logo image
final logoImage = SvgPicture.asset(
  "assets/images/logo.svg",
);
final premiumBadge = SvgPicture.asset(
  "assets/images/premium-badge.svg",
);
const backgroundImage = AssetImage(
  "assets/images/bgs/bg2.jpg",
);

// colors
const Color black = Color.fromARGB(255, 27, 27, 35);
const Color white = Color(0xFFFFFFFF);
const Color primary = Color.fromARGB(255, 198, 29, 97);
const Color sidebarBgColor = Color.fromARGB(255, 27, 27, 35);
const LinearGradient primaryGradient = LinearGradient(
  colors: [
    white,
    primary,
    primary,
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
const Color secondary = Color.fromRGBO(247, 250, 252, 1.0);
const Color error = Color.fromRGBO(245, 54, 92, 1.0);
const Color success = Color.fromRGBO(45, 206, 137, 1.0);
const Color warning = Color.fromRGBO(215, 168, 27, 1);
