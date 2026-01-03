import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_colors.dart';

/// Barcode Scanner Screen with real camera support for mobile devices
class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen> {
  MobileScannerController? _controller;
  bool _isScanning = true;
  bool _flashOn = false;
  bool _isMobile = false;
  bool _cameraInitialized = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _checkPlatformAndInitCamera();
  }

  void _checkPlatformAndInitCamera() {
    // Check if running on supported platform (Android, iOS, macOS, Windows if supported by package)
    // mobile_scanner 5.0+ supports most platforms. Let's try initializing for all except maybe Web if specific handling needed.
    // For now, we assume if it's not web, we try to use it.

    if (kIsWeb) {
      _isMobile = false; // Web handling
      _cameraInitialized = true;
      return;
    }

    // Try to initialize camera for all native platforms
    _isMobile = true; // reusing this flag to mean "Native Camera Supported"
    _initializeCamera();
  }

  void _initializeCamera() async {
    try {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        torchEnabled: false,
        facing: CameraFacing.back,
        formats: const [BarcodeFormat.all],
      );

      // Controller starts automatically when attached to widget in 5.x
      setState(() => _cameraInitialized = true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _initError = e.toString();
          _cameraInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scannerBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scannerBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scan Product',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          if (_isMobile && _controller != null)
            IconButton(
              icon: Icon(
                _flashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
              ),
              onPressed: _toggleFlash,
            ),
        ],
      ),
      body: Column(
        children: [
          // Scanner/Camera Area
          Expanded(
            flex: 3,
            child: _cameraInitialized
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      // Camera View or Placeholder
                      if (_isMobile &&
                          _controller != null &&
                          _initError == null)
                        MobileScanner(
                          controller: _controller!,
                          onDetect: _onBarcodeDetected,
                          errorBuilder: (context, error, child) {
                            return _buildCameraError(error.toString());
                          },
                        )
                      else
                        _buildDemoScanArea(),

                      // Scan Frame Overlay
                      _buildScanFrame(),
                    ],
                  )
                : const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
          ),

          // Bottom Section
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildScanFrame() {
    return Container(
      width: 280,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary, width: 3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Corner decorations
          ...List.generate(4, (index) {
            final isTop = index < 2;
            final isLeft = index.isEven;
            return Positioned(
              top: isTop ? 0 : null,
              bottom: isTop ? null : 0,
              left: isLeft ? 0 : null,
              right: isLeft ? null : 0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  border: Border(
                    top: isTop
                        ? const BorderSide(color: AppColors.primary, width: 4)
                        : BorderSide.none,
                    bottom: isTop
                        ? BorderSide.none
                        : const BorderSide(color: AppColors.primary, width: 4),
                    left: isLeft
                        ? const BorderSide(color: AppColors.primary, width: 4)
                        : BorderSide.none,
                    right: isLeft
                        ? BorderSide.none
                        : const BorderSide(color: AppColors.primary, width: 4),
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: isTop && isLeft
                        ? const Radius.circular(12)
                        : Radius.zero,
                    topRight: isTop && !isLeft
                        ? const Radius.circular(12)
                        : Radius.zero,
                    bottomLeft: !isTop && isLeft
                        ? const Radius.circular(12)
                        : Radius.zero,
                    bottomRight: !isTop && !isLeft
                        ? const Radius.circular(12)
                        : Radius.zero,
                  ),
                ),
              ),
            );
          }),
          // Scanning line animation
          if (_isScanning && _isMobile)
            AnimatedPositioned(
              duration: const Duration(seconds: 2),
              top: 10,
              left: 10,
              right: 10,
              child: Container(height: 2, color: AppColors.primary),
            ),
        ],
      ),
    );
  }

  Widget _buildDemoScanArea() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _initError != null
                  ? Icons.error_outline
                  : Icons.camera_alt_outlined,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _initError != null
                  ? 'Camera Error'
                  : (_isMobile ? 'Initializing Camera...' : 'Demo Mode'),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 16,
              ),
            ),
            if (!_isMobile) ...[
              const SizedBox(height: 8),
              Text(
                'Use the demo products below',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCameraError(String error) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Camera Error',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: AppColors.scannerBackground),
      child: Column(
        children: [
          Text(
            _isMobile && _initError == null
                ? 'Position barcode within frame'
                : 'Enter barcode manually or use demo products',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Manual Entry Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showManualEntryDialog,
              icon: const Icon(Icons.keyboard),
              label: const Text('Enter Barcode Manually'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // View Cart Button
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              if (cart.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/cart'),
                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                  label: Text(
                    'View Cart (${cart.itemCount} items)',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _toggleFlash() async {
    if (_controller != null) {
      await _controller!.toggleTorch();
      setState(() => _flashOn = !_flashOn);
    }
  }

  void _onBarcodeDetected(BarcodeCapture capture) async {
    if (!_isScanning) return;

    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null || barcode.isEmpty) return;

    setState(() => _isScanning = false);

    await _addProductByBarcode(barcode);

    // Resume scanning after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isScanning = true);
    });
  }

  Future<void> _addProductByBarcode(String barcode) async {
    // Check if we are in "picker" mode (called from Add Product screen)
    final args = ModalRoute.of(context)?.settings.arguments;
    final isPicker = args != null && args is Map && args['isPicker'] == true;

    if (isPicker) {
      Navigator.pop(context, barcode);
      return;
    }

    final cart = context.read<CartProvider>();

    if (cart.currentStore == null) {
      _showErrorSnackbar('No store selected. Please enter a store first.');
      return;
    }

    final product = await cart.addProductByBarcode(barcode);

    if (mounted) {
      if (product != null) {
        _showSuccessSnackbar(product.name);
      } else {
        _showErrorSnackbar('Product not found in current store: $barcode');
      }
    }
  }

  void _showSuccessSnackbar(String productName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Text('Added to cart', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showManualEntryDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Barcode'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.text,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Scan or type barcode',
            prefixIcon: Icon(Icons.qr_code),
          ),
          onSubmitted: (value) {
            Navigator.pop(context);
            if (value.isNotEmpty) {
              _addProductByBarcode(value);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (controller.text.isNotEmpty) {
                _addProductByBarcode(controller.text);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
