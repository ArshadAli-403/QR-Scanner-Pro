// lib/widgets/qr_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../models/qr_scan_model.dart';
import '../utils/url_utils.dart';

class QrCard extends StatelessWidget {
  final QrScanModel scan;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const QrCard({
    super.key,
    required this.scan,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final qrType = UrlUtils.getQrType(scan.qrText);
    final isUrl = UrlUtils.isUrl(scan.qrText);
    final typeIcon = UrlUtils.getQrIcon(scan.qrText);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.divider,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
              child: Row(
                children: [
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          typeIcon,
                          size: 13,
                          color: AppColors.primaryLight,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          qrType,
                          style: const TextStyle(
                            color: AppColors.primaryLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Action buttons
                  _ActionIconButton(
                    icon: Icons.copy_rounded,
                    tooltip: 'Copy',
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: scan.qrText));
                      _showSnack(context, 'Copied to clipboard!');
                    },
                  ),
                  if (isUrl)
                    _ActionIconButton(
                      icon: Icons.open_in_new_rounded,
                      tooltip: 'Open Link',
                      onTap: () =>
                          UrlUtils.openUrl(context, scan.qrText),
                    ),
                  _ActionIconButton(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'Delete',
                    color: AppColors.error.withOpacity(0.8),
                    onTap: onDelete,
                  ),
                ],
              ),
            ),

            // QR Text
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Text(
                scan.qrText,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Date
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 14),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    scan.scanDate,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;

  const _ActionIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: color ?? AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
