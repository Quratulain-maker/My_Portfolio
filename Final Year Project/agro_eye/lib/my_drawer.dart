import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'privacy_policy_screen.dart';
import 'history_screen.dart';
import 'about_us_screen.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // ---------- Header ----------
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Image.asset('assets/images/agro_eye_logo.png', height: 80),
                  const SizedBox(height: 12),
                  const Text(
                    'Agro Eye',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0C3B2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Scan • Protect • Grow',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
              ),
            ),

            const Divider(),

            // ---------- Menu Items ----------
            _drawerItem(
              context,
              icon: CupertinoIcons.house_fill,
              title: 'Home',
              onTap: () {
                Navigator.pop(context);
              },
            ),

            _drawerItem(
              context,
              icon: CupertinoIcons.clock_fill,
              title: 'History',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
            ),

            _drawerItem(
              context,
              icon: CupertinoIcons.lock_fill,
              title: 'Privacy Policy',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),
            _drawerItem(
              context,
              icon: CupertinoIcons.info_circle_fill,
              title: 'About Us',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutUsScreen(),
                  ),
                );
              },
            ),

            const Spacer(),

            // ---------- Footer ----------
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Agro Eye © 2025',
                style: TextStyle(color: Colors.black45, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2F7D32)),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}
