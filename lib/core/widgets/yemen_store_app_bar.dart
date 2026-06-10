import 'package:flutter/material.dart';

class YemenStoreAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;

  const YemenStoreAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.bottom,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: title,
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
      bottom: bottom,
      elevation: theme.appBarTheme.elevation ?? 0,
      backgroundColor: theme.appBarTheme.backgroundColor,
      iconTheme: theme.appBarTheme.iconTheme,
      titleTextStyle: theme.appBarTheme.titleTextStyle,
      foregroundColor: theme.appBarTheme.foregroundColor,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}
