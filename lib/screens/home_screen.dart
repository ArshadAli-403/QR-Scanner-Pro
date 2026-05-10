// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/qr_provider.dart';
import '../widgets/gradient_button.dart';
import 'scanner_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Load scan count on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QrProvider>().loadScans();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _navigateToScanner() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const ScannerScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _navigateToHistory() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const HistoryScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanCount = context.watch<QrProvider>().totalScans;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.gradientStart,
              AppColors.gradientMid,
              AppColors.gradientEnd,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // ── App Header ──────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.appName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$scanCount scans saved',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      // Settings-style icon badge
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: const Icon(
                          Icons.qr_code_rounded,
                          color: AppColors.primaryLight,
                          size: 24,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),

                  SizedBox(height: size.height * 0.06),

                  // ── Center Scanner Icon ─────────────────────
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) => Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow ring
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.15),
                              width: 2,
                            ),
                          ),
                        ),
                        // Middle ring
                        Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.25),
                              width: 2,
                            ),
                          ),
                        ),
                        // Inner icon container
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryDark,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.5),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 70,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ).animate().scale(
                        delay: 200.ms,
                        duration: 700.ms,
                        curve: Curves.elasticOut,
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                      ),

                  SizedBox(height: size.height * 0.05),

                  // ── Tagline ─────────────────────────────────
                  const Text(
                    'Scan any QR code instantly',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

                  const SizedBox(height: 8),

                  const Text(
                    'Fast, secure, and stored locally\non your device.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 450.ms, duration: 500.ms),

                  SizedBox(height: size.height * 0.06),

                  // ── Scan Button ─────────────────────────────
                  GradientButton(
                    label: AppStrings.scanQrCode,
                    icon: Icons.qr_code_scanner_rounded,
                    onTap: _navigateToScanner,
                    gradientColors: const [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                    height: 64,
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 500.ms)
                      .slideY(begin: 0.3, end: 0, delay: 600.ms),

                  const SizedBox(height: 16),

                  // ── History Button ──────────────────────────
                  GradientButton(
                    label: AppStrings.scanHistory,
                    icon: Icons.history_rounded,
                    onTap: _navigateToHistory,
                    gradientColors: const [
                      AppColors.accent,
                      AppColors.accentDark,
                    ],
                    height: 64,
                  )
                      .animate()
                      .fadeIn(delay: 750.ms, duration: 500.ms)
                      .slideY(begin: 0.3, end: 0, delay: 750.ms),

                  SizedBox(height: size.height * 0.05),

                  // ── Feature pills ───────────────────────────
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: const [
                      _FeaturePill(
                          icon: Icons.flash_on_rounded, label: 'Flashlight'),
                      _FeaturePill(
                          icon: Icons.storage_rounded, label: 'Local Storage'),
                      _FeaturePill(
                          icon: Icons.share_rounded, label: 'Share Results'),
                      _FeaturePill(
                          icon: Icons.search_rounded, label: 'Search History'),
                    ],
                  )
                      .animate()
                      .fadeIn(delay: 900.ms, duration: 500.ms)
                      .slideY(begin: 0.2, end: 0, delay: 900.ms),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primaryLight),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
