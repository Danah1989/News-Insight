import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:news_insight/screens/Verification.dart';

import '../screens/HistoryScreen.dart';

class NewsInsightDrawer extends StatelessWidget {
  const NewsInsightDrawer({super.key});

  // Colours (same palette as the original app)
  static const Color _bgTop    = Color(0xFF1A3A8F); // deep navy
  static const Color _bgBottom = Color(0xffe8e8e8); // light blue-grey
  static const Color _btnFill  = Color(0xFF2952C4); // medium royal blue
  static const Color _btnHover = Color(0xFF3A66E0); // lighter on press
  static const Color _white    = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 285,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────
          _DrawerHeader(),

          // ── Menu items ──────────────────────────
          Expanded(
            child: Container(
              color: _bgBottom,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DrawerButton(
                    icon: Icons.verified_rounded,
                    label: 'News Verification',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context2) => const Verification()));
                    },
                  ),
                  const SizedBox(height: 14),
                  _DrawerButton(
                    icon: Icons.history_rounded,
                    label: 'History',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context2) => const HistoryScreen()));
                    },
                  ),
                  const Spacer(),
                  _DrawerButton(
                    icon: Icons.logout_rounded,
                    label: 'Logout',
                    onTap: () async {
                      Navigator.pop(context);
                      await FirebaseAuth.instance.signOut();
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    isDestructive: true,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Drawer header with logo + user info
// ─────────────────────────────────────────────
class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
      decoration: const BoxDecoration(
        color: Color(0xFF1A3A8F),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Globe icon + check badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.language_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'NEWS INSIGHT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Fact-check the world',
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 13,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reusable drawer button
// ─────────────────────────────────────────────
class _DrawerButton extends StatelessWidget {
  const _DrawerButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final Color fill = isDestructive
        ? const Color(0xFFB71C1C).withOpacity(0.88)
        : const Color(0xFF2952C4);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        child: Ink(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: fill.withOpacity(0.38),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 14),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.55),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}