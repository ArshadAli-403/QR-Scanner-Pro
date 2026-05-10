// lib/screens/result_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/qr_scan_model.dart';
import '../utils/url_utils.dart';
import 'home_screen.dart';
import 'scanner_screen.dart';

class ResultScreen extends StatelessWidget {
  final QrScanModel? scan;
  final String qrText;

  const ResultScreen({
    super.key,
    required this.qrText,
    this.scan,
  });

  bool get _isUrl => UrlUtils.isUrl(qrText);
  String get _qrType => UrlUtils.getQrType(qrText);
  IconData get _typeIcon => UrlUtils.getQrIcon(qrText);

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: qrText));
    _showSnack(context, AppStrings.copied, AppColors.success);
  }

  Future<void> _openUrl(BuildContext context) async {
    try {
      final uri = Uri.parse(qrText.trim());
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showSnack(context, AppStrings.urlError, AppColors.error);
        }
      }
    } catch (_) {
      if (context.mounted) {
        _showSnack(context, AppStrings.urlError, AppColors.error);
      }
    }
  }

  Future<void> _share(BuildContext context) async {
    try {
      await Share.share(qrText, subject: 'QR Code Result');
    } catch (_) {
      if (context.mounted) {
        _showSnack(context, AppStrings.shareError, AppColors.error);
      }
    }
  }

  void _showSnack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
          child: Column(
            children: [
              // ── App Bar ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context)
                          .pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const HomeScreen()),
                            (route) => false,
                          ),
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        AppStrings.scanResult,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    children: [
                      // ── Success Icon ─────────────────────
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.success, Color(0xFF2E7D5A)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.success.withOpacity(0.4),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_circle_outline_rounded,
                          color: Colors.white,
                          size: 52,
                        ),
                      )
                          .animate()
                          .scale(
                            duration: 500.ms,
                            curve: Curves.elasticOut,
                            begin: const Offset(0, 0),
                            end: const Offset(1, 1),
                          )
                          .fadeIn(),

                      const SizedBox(height: 16),

                      Text(
                        'Scanned Successfully!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 24),

                      // ── Result Card ──────────────────────
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.divider),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Type badge header
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.12),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                                border: const Border(
                                  bottom: BorderSide(
                                    color: AppColors.divider,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(_typeIcon,
                                      color: AppColors.primaryLight,
                                      size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    _qrType,
                                    style: const TextStyle(
                                      color: AppColors.primaryLight,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () => _copy(context),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.copy_rounded,
                                              size: 14,
                                              color: AppColors.primaryLight),
                                          SizedBox(width: 4),
                                          Text(
                                            'Copy',
                                            style: TextStyle(
                                              color: AppColors.primaryLight,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // QR Text content
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: SelectableText(
                                qrText,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  height: 1.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),

                            // Scan Date
                            if (scan != null)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                        color: AppColors.divider, width: 1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.schedule_rounded,
                                      size: 14,
                                      color: AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${AppStrings.scanDate}: ${scan!.scanDate}',
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 400.ms)
                          .slideY(
                              begin: 0.2,
                              end: 0,
                              delay: 300.ms,
                              duration: 400.ms),

                      const SizedBox(height: 28),

                      // ── Action Buttons ───────────────────
                      _buildActionButton(
                        label: AppStrings.copyResult,
                        icon: Icons.copy_rounded,
                        color: AppColors.primary,
                        onTap: () => _copy(context),
                      ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.2),

                      const SizedBox(height: 12),

                      if (_isUrl)
                        _buildActionButton(
                          label: AppStrings.openLink,
                          icon: Icons.open_in_new_rounded,
                          color: AppColors.info,
                          onTap: () => _openUrl(context),
                        )
                            .animate()
                            .fadeIn(delay: 550.ms)
                            .slideY(begin: 0.2),

                      if (_isUrl) const SizedBox(height: 12),

                      _buildActionButton(
                        label: AppStrings.shareResult,
                        icon: Icons.share_rounded,
                        color: AppColors.accent,
                        onTap: () => _share(context),
                      ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.2),

                      const SizedBox(height: 12),

                      _buildActionButton(
                        label: AppStrings.scanAgain,
                        icon: Icons.qr_code_scanner_rounded,
                        color: AppColors.surface,
                        textColor: AppColors.textPrimary,
                        isOutlined: true,
                        onTap: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => const ScannerScreen()),
                        ),
                      ).animate().fadeIn(delay: 750.ms).slideY(begin: 0.2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    Color? textColor,
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : color,
          foregroundColor: textColor ?? Colors.white,
          side: isOutlined ? BorderSide(color: AppColors.divider) : null,
          elevation: isOutlined ? 0 : 4,
          shadowColor: color.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
