import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.blue,
      leading: showBackButton ? BackButton() : null, // 뒤로가기 버튼 추가
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
