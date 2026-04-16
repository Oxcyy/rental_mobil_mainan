import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/theme_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showLogout;

  const CustomAppBar({super.key, required this.title, this.showLogout = false});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final canPop = Navigator.canPop(context);

    final bgColor = isDark ? Colors.black : const Color(0xFFFFEB3B);
    final borderColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.white : Colors.black;
    final textColor = isDark ? Colors.white : Colors.black;

    Widget? leadingWidget;
    if (showLogout) {
      leadingWidget = IconButton(
        icon: Icon(Icons.logout, color: iconColor, size: 26),
        onPressed: () => _confirmLogout(context, isDark),
      );
    } else if (canPop) {
      leadingWidget = IconButton(
        icon: Icon(Icons.arrow_back, color: iconColor, size: 28),
        onPressed: () => Navigator.pop(context),
      );
    }

    return AppBar(
      leading: leadingWidget,
      title: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: textColor,
          letterSpacing: 1.5,
        ),
      ),
      centerTitle: true,
      backgroundColor: bgColor,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4.0),
        child: Container(color: borderColor, height: 4.0),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            color: iconColor,
          ),
          onPressed: () => themeProvider.toggleTheme(),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context, bool isDark) {
    final borderColor = isDark ? Colors.white : Colors.black;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF222222) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), 
          side: BorderSide(color: borderColor, width: 3)
        ),
        title: Text('KELUAR?', style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black)),
        content: Text('Yakin ingin keluar dari akun ini?', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: Text('BATAL', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w900))
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Supabase.instance.client.auth.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8A80),
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.black, width: 2),
              elevation: 0,
            ),
            child: const Text('KELUAR', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4.0);
}