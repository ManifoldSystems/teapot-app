import 'package:flutter/material.dart';

/// Navigation item data for both rail and bar
class NavItem {
  final String label;
  final IconData icon;
  final String route;

  const NavItem({required this.label, required this.icon, required this.route});
}
