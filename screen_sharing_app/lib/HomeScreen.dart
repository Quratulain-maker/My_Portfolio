import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // App palette
  static const kBlue = Color(0xFF6DA9FF);
  static const kBlueDeep = Color(0xFF4D7DF9);
  static const kShadow = Color(0x19000000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Home', style: TextStyle(color: Colors.black)),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          // ---- KEEP EXACT TITLES ----
          const Text(
            'WELCOME TO !',
            style: TextStyle(
              color: kBlue,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Screen Sharing',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 28,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 20),

          // ---- THREE CARDS ----
          _plainCard(
            title: 'Screen Sharing',
            icon: Icons.cast_connected,
            onTap: () => _open(context, const _Stub(title: 'Screen Sharing')),
          ),
          const SizedBox(height: 12),

          _plainCard(
            title: 'Screen Casting',
            icon: Icons.cast,
            onTap: () => _open(context, const _Stub(title: 'Screen Casting')),
          ),
          const SizedBox(height: 12),

          _plainCard(
            title: 'How To Use',
            icon: Icons.help_outline,
            onTap: () => _open(context, const _Stub(title: 'How To Use')),
          ),

          // ---- NEW SECTIONS BELOW ----
          const SizedBox(height: 22),
          _bigCta(
            title: 'Enable\nScreen Mirroring',
            onTap: () => _open(context, const _Stub(title: 'Enable Screen Mirroring')),
          ),

          const SizedBox(height: 16),
          _socialRow(),

          const SizedBox(height: 16),
          _quickToolsGrid(context),

          const SizedBox(height: 12),
          _moreTools(onTap: () => _open(context, const _Stub(title: 'More Tools'))),
        ],
      ),
    );
  }

  // ---------- helpers ----------

  static void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // Your plain cards (no highlight color)
  static Widget _plainCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF0F0F0)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: kShadow, blurRadius: 10, offset: Offset(0, 6))],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE3E7EF)),
            boxShadow: const [BoxShadow(color: kShadow, blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: Icon(icon, color: kBlue),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        trailing: const CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white,
          child: Icon(Icons.arrow_forward, size: 18, color: kBlue),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      ),
    );
  }

  // Big CTA with your app colors
  static Widget _bigCta({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [kBlue, kBlueDeep],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [BoxShadow(color: kShadow, blurRadius: 20, offset: Offset(0, 10))],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _squareIcon(), // <-- not const call; returns a widget
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // icon box used in CTA
  static Widget _squareIcon() {
    return const SizedBox(
      width: 54,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        child: Icon(Icons.cast_rounded, color: Colors.white, size: 30),
      ),
    );
  }

  // Social buttons row — ALL in app blue
  static Widget _socialRow() {
    Widget box(IconData i) => Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: kShadow, blurRadius: 10, offset: Offset(0, 6))],
      ),
      child: Icon(i, color: kBlue, size: 28), // not const: uses variable i
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        box(Icons.ondemand_video),
        box(Icons.g_mobiledata),
        box(Icons.facebook),
        box(Icons.camera_alt_outlined),
        box(Icons.live_tv_outlined),
      ],
    );
  }

  // Quick tools — fixed height & centered content so text never drops/cuts
  static Widget _quickToolsGrid(BuildContext context) {
    Widget t(String title, IconData icon) => Container(
      height: 84,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: kShadow, blurRadius: 10, offset: Offset(0, 6))],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: kBlue.withOpacity(.12),
              child: Icon(icon, color: kBlue), // not const: icon is variable
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            const Icon(Icons.chevron_right, color: kBlue),
          ],
        ),
      ),
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: t('Videos', Icons.videocam_rounded)),
            const SizedBox(width: 12),
            Expanded(child: t('Images', Icons.image_rounded)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: t('Audios', Icons.mic_rounded)),
            const SizedBox(width: 12),
            Expanded(child: t('Documents', Icons.insert_drive_file_rounded)),
          ],
        ),
      ],
    );
  }

  static Widget _moreTools({VoidCallback? onTap}) {
    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: kShadow, blurRadius: 10, offset: Offset(0, 6))],
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: kBlue.withOpacity(.12),
          child: const Icon(Icons.build_outlined, color: kBlue),
        ),
        title: const Text('More Tools', style: TextStyle(fontWeight: FontWeight.w700)),
        subtitle: const Text('Explore More'),
        trailing: const Icon(Icons.chevron_right, color: kBlue),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}

// minimal placeholder so onTap works; replace with your real screens later
class _Stub extends StatelessWidget {
  const _Stub({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(title)),
      body: Center(child: Text('$title screen', style: const TextStyle(fontSize: 18))),
    );
  }
}
