// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/qr_scan_model.dart';
import '../providers/qr_provider.dart';
import '../widgets/qr_card.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QrProvider>().loadScans();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          AppStrings.clearAllConfirm,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
        ),
        content: const Text(
          AppStrings.confirmDelete,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(AppStrings.clear),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await context.read<QrProvider>().deleteAllScans();
      if (success && context.mounted) {
        _searchController.clear();
        _showSnack(context, AppStrings.historyCleared, AppColors.success);
      }
    }
  }

  Future<void> _deleteItem(BuildContext context, QrScanModel scan) async {
    final provider = context.read<QrProvider>();
    final success = await provider.deleteScan(scan.id!);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.itemDeleted),
          backgroundColor: AppColors.cardColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: AppStrings.undo,
            textColor: AppColors.primaryLight,
            onPressed: () => provider.undoDelete(scan),
          ),
        ),
      );
    }
  }

  void _showSnack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              // ── Header ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        AppStrings.historyTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Consumer<QrProvider>(
                      builder: (_, provider, __) => provider.hasScans
                          ? TextButton.icon(
                              onPressed: () => _confirmClearAll(context),
                              icon: const Icon(Icons.delete_sweep_rounded,
                                  size: 18, color: AppColors.error),
                              label: const Text(
                                AppStrings.clearAll,
                                style: TextStyle(
                                    color: AppColors.error, fontSize: 14),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              // ── Search Bar ────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 15),
                    onChanged: (val) => context.read<QrProvider>().search(val),
                    decoration: InputDecoration(
                      hintText: AppStrings.searchHint,
                      hintStyle: const TextStyle(
                          color: AppColors.textMuted, fontSize: 15),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.textMuted, size: 22),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded,
                                  color: AppColors.textMuted, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                context.read<QrProvider>().clearSearch();
                                _searchFocus.unfocus();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

              // ── List ─────────────────────────────────────
              Expanded(
                child: Consumer<QrProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    final scans = provider.scans;

                    if (scans.isEmpty) {
                      return _EmptyHistoryWidget(
                        isSearching: provider.isSearching,
                        query: provider.searchQuery,
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(top: 4, bottom: 24),
                      itemCount: scans.length,
                      itemBuilder: (context, index) {
                        final scan = scans[index];
                        return QrCard(
                          key: ValueKey(scan.id),
                          scan: scan,
                          onDelete: () => _deleteItem(context, scan),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ResultScreen(
                                  scan: scan,
                                  qrText: scan.qrText,
                                ),
                              ),
                            );
                          },
                        )
                            .animate()
                            .fadeIn(
                                delay: Duration(milliseconds: index * 50),
                                duration: 300.ms)
                            .slideX(
                                begin: 0.1,
                                end: 0,
                                delay: Duration(milliseconds: index * 50));
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHistoryWidget extends StatelessWidget {
  final bool isSearching;
  final String query;

  const _EmptyHistoryWidget({
    required this.isSearching,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider),
            ),
            child: Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : Icons.history_toggle_off_rounded,
              size: 48,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isSearching ? 'No results for "$query"' : AppStrings.noHistory,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Try a different search term'
                : AppStrings.noHistorySubtitle,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1, 1),
            duration: 400.ms,
          ),
    );
  }
}
