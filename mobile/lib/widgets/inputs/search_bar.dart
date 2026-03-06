import 'package:flutter/material.dart';

class AppSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final void Function(String)? onChanged;
  final VoidCallback? onFilterTap;

  const AppSearchBar({super.key, this.controller, this.hint = 'Search...', this.onChanged, this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(children: [
        const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.search, color: Color(0xFF9CA3AF))),
        Expanded(child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(hintText: hint, border: InputBorder.none, hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
        )),
        if (onFilterTap != null) IconButton(onPressed: onFilterTap, icon: const Icon(Icons.filter_list, color: Color(0xFF6B7280))),
      ]),
    );
  }
}
