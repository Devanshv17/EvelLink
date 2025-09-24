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
      appBar: AppBar(
        title: const Text('Scan Event QR Code'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // QR view
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: AppConstants.primaryColor,
              borderRadius: 12,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 250,
            ),
          ),

          // Overlay controls and instructions
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
            child: Column(
              children: [
                const Spacer(),

                if (_isProcessing)
                  Container(
                    width: 250,
                    height: 250,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppConstants.primaryColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black54,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppConstants.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Processing...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    width: 250,
                    height: 250,
                  ),

                const SizedBox(height: 32),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        color: AppConstants.primaryColor,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Position the QR code within the frame',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Make sure the QR code is clearly visible',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppConstants.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
