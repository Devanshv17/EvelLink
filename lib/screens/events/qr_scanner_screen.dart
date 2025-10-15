import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import '../../providers/providers.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;
  bool _flashOn = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController qrController) {
    controller = qrController;

    controller?.scannedDataStream.listen((scanData) async {
      if (_isProcessing) return;
      setState(() {
        _isProcessing = true;
      });

      final qrData = scanData.code;
      if (qrData != null) {
        await _processQRCode(qrData);
      }

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  Future<void> _toggleFlash() async {
    try {
      await controller?.toggleFlash();
      setState(() {
        _flashOn = !_flashOn;
      });
    } catch (e) {
      print('Flash not available: $e');
    }
  }

  Future<void> _processQRCode(String qrData) async {
    try {
      // Parse QR data
      final qrDataModel = QRService.parseQRData(qrData);
      if (qrDataModel == null) {
        _showError('Invalid QR code format');
        return;
      }

      // Validate event timing
      if (!qrDataModel.isValid) {
        _showError('This event has expired or hasn\'t started yet');
        return;
      }

      // Get current user
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.currentUser == null) {
        _showError('Please create a profile first');
        return;
      }

      // Join event
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final success = await eventProvider.joinEvent(
        qrDataModel,
        userProvider.currentUser!.uid,
      );

      if (success && mounted) {
        // Show success and go back
        Helpers.showSnackBar(
          context,
          'Successfully joined ${qrDataModel.eventName}!',
        );
        Navigator.pop(context);
      } else if (mounted) {
        _showError(eventProvider.error ?? 'Failed to join event');
      }
    } catch (e) {
      _showError('Error processing QR code: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      Helpers.showSnackBar(context, message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // QR Scanner View
          _buildQRView(),

          // Custom Overlay
          _buildCustomOverlay(),

          // Header
          _buildHeader(),

          // Flash Toggle Button
          _buildFlashButton(),

          // Bottom Instructions
          _buildInstructions(),
        ],
      ),
    );
  }

  Widget _buildQRView() {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
    );
  }

  Widget _buildCustomOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
          stops: const [0.0, 0.2, 0.8, 1.0],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 100),
          Expanded(
            child: Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppConstants.primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: _isProcessing ? _buildProcessingOverlay() : _buildScanningAnimation(),
              ),
            ),
          ),
          const SizedBox(height: 180),
        ],
      ),
    );
  }

  Widget _buildScanningAnimation() {
    return Stack(
      children: [
        // Animated border
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 2000),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppConstants.primaryColor.withOpacity(0.6),
                width: 3,
              ),
            ),
          ),
        ),

        // Scanning line
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppConstants.primaryColor,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Corner decorations
        ..._buildScannerCorners(),
      ],
    );
  }

  List<Widget> _buildScannerCorners() {
    return [
      // Top Left
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: AppConstants.primaryColor, width: 4),
              left: BorderSide(color: AppConstants.primaryColor, width: 4),
            ),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(24)),
          ),
        ),
      ),

      // Top Right
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: AppConstants.primaryColor, width: 4),
              right: BorderSide(color: AppConstants.primaryColor, width: 4),
            ),
            borderRadius: const BorderRadius.only(topRight: Radius.circular(24)),
          ),
        ),
      ),

      // Bottom Left
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppConstants.primaryColor, width: 4),
              left: BorderSide(color: AppConstants.primaryColor, width: 4),
            ),
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24)),
          ),
        ),
      ),

      // Bottom Right
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppConstants.primaryColor, width: 4),
              right: BorderSide(color: AppConstants.primaryColor, width: 4),
            ),
            borderRadius: const BorderRadius.only(bottomRight: Radius.circular(24)),
          ),
        ),
      ),
    ];
  }

  Widget _buildProcessingOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Processing QR Code...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 60,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Column(
          children: [
            Text(
              'Scan Event QR Code',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Align the QR code within the frame',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashButton() {
    return Positioned(
      top: 60,
      right: 20,
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(30),
          ),
          child: IconButton(
            onPressed: _toggleFlash,
            icon: Icon(
              _flashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
              size: 28,
            ),
            style: IconButton.styleFrom(
              backgroundColor: _flashOn ? AppConstants.primaryColor : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.qr_code_scanner,
                  color: AppConstants.primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to scan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Position the QR code within the frame. Make sure it\'s clearly visible and well-lit.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}