// lib/screens/scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/qr_provider.dart';
import '../widgets/scanner_overlay.dart';
import 'result_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  late MobileScannerController _scannerController;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  bool _hasScanned = false;
  bool _isProcessing = false;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initScanner();
  }

  void _initScanner() {
    _scannerController = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
      formats: const [BarcodeFormat.qrCode],
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        if (!_hasScanned) _scannerController.start();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        _scannerController.stop();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    // Prevent duplicate scans and re-entry while processing
    if (_hasScanned || _isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.trim().isEmpty) return;

    setState(() {
      _hasScanned = true;
      _isProcessing = true;
    });

    // Stop camera
    await _scannerController.stop();

    // Vibrate on success
    try {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) {
        Vibration.vibrate(duration: 150, amplitude: 128);
      }
    } catch (_) {}

    if (!mounted) return;

    // Save to DB via provider
    final provider = context.read<QrProvider>();
    final saved = await provider.addScan(rawValue.trim());

    if (!mounted) return;

    // Navigate to result screen
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => ResultScreen(
          scan: saved,
          qrText: rawValue.trim(),
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  Future<void> _toggleFlash() async {
    try {
      await _scannerController.toggleTorch();
      setState(() => _isFlashOn = !_isFlashOn);
    } catch (e) {
      _showSnack('Flashlight not available');
    }
  }

  Future<void> _flipCamera() async {
    try {
      await _scannerController.switchCamera();
      setState(() => _isFrontCamera = !_isFrontCamera);
    } catch (e) {
      _showSnack('Could not switch camera');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.cardColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Camera Feed ──────────────────────────────────
          if (!_permissionDenied)
            MobileScanner(
              controller: _scannerController,
              onDetect: _onBarcodeDetected,
              errorBuilder: (context, error, child) {
                if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _permissionDenied = true);
                  });
                }
                return const SizedBox.shrink();
              },
            ),

          // ── Permission Denied UI ─────────────────────────
          if (_permissionDenied)
            Container(
              color: AppColors.gradientStart,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.no_photography_rounded,
                          size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 20),
                      const Text(
                        AppStrings.permissionDenied,
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Go Back'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Scanner Overlay ──────────────────────────────
          if (!_permissionDenied) const ScannerOverlay(),

          // ── Top AppBar ───────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _CircleButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Text(
                        AppStrings.scannerTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _CircleButton(
                      icon: _isFlashOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      color: _isFlashOn ? AppColors.warning : Colors.white,
                      onTap: _toggleFlash,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Hint Text ────────────────────────────────────
          const Positioned(
            bottom: 160,
            left: 0,
            right: 0,
            child: Text(
              AppStrings.alignQr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // ── Bottom Controls ──────────────────────────────
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CircleButton(
                  icon: Icons.flip_camera_ios_rounded,
                  size: 56,
                  iconSize: 26,
                  onTap: _flipCamera,
                ),
                const SizedBox(width: 24),
                // Shutter ring
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Center(
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white24,
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                _CircleButton(
                  icon: Icons.history_rounded,
                  size: 56,
                  iconSize: 26,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // ── Processing Overlay ───────────────────────────
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final double size;
  final double iconSize;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.color,
    this.size = 46,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black45,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(
          icon,
          color: color ?? Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}
