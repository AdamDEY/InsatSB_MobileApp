import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../repositories/admin_repository.dart';

class AdminCheckinScreen extends StatefulWidget {
  const AdminCheckinScreen({super.key});

  @override
  State<AdminCheckinScreen> createState() => _AdminCheckinScreenState();
}

class _AdminCheckinScreenState extends State<AdminCheckinScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;
  Map<String, dynamic>? _lastResult;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final token = barcode.rawValue!;

    setState(() {
      _isProcessing = true;
      _lastResult = null;
    });

    // Pause scanner while processing
    _scannerController.stop();

    try {
      final adminRepository = context.read<AdminRepository>();
      final result = await adminRepository.verifyCheckin(token);

      setState(() {
        _lastResult = result;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _lastResult = {'error': true, 'message': e.toString()};
        _isProcessing = false;
      });
    }
  }

  void _resumeScanning() {
    setState(() {
      _lastResult = null;
    });
    _scannerController.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Check-in Scanner'), elevation: 0),
      body: _lastResult != null ? _buildResultView() : _buildScannerView(),
    );
  }

  Widget _buildScannerView() {
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: _onBarcodeDetected,
        ),
        // Overlay with scanning frame
        Center(
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        // Instructions
        Positioned(
          bottom: 80,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'Point camera at attendee\'s QR code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        if (_isProcessing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Verifying...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResultView() {
    final result = _lastResult!;
    final isError = result['error'] == true;
    final alreadyCheckedIn = result['alreadyCheckedIn'] == true;

    final Color statusColor;
    final IconData statusIcon;
    final String statusText;

    if (isError) {
      statusColor = Colors.red;
      statusIcon = Icons.error_outline;
      statusText = 'Check-in Failed';
    } else if (alreadyCheckedIn) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning_amber_rounded;
      statusText = 'Already Checked In';
    } else {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline;
      statusText = 'Check-in Successful';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status icon
            Icon(statusIcon, size: 100, color: statusColor),
            const SizedBox(height: 24),

            // Status text
            Text(
              statusText,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 24),

            // Details card
            if (!isError)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      Icons.person,
                      'Name',
                      result['user']?['fullName'] ?? 'Unknown',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.email,
                      'Email',
                      result['user']?['email'] ?? 'Unknown',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.event,
                      'Event',
                      result['event']?['title'] ?? 'Unknown',
                    ),
                    if (result['checkedInAt'] != null) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.access_time,
                        'Checked In At',
                        _formatDateTime(result['checkedInAt']),
                      ),
                    ],
                  ],
                ),
              ),

            if (isError)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  result['message'] ?? 'Unknown error',
                  style: TextStyle(fontSize: 16, color: Colors.red.shade800),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 32),

            // Scan another button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _resumeScanning,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text(
                  'Scan Next Attendee',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(dynamic value) {
    try {
      final dateTime = DateTime.parse(value.toString());
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} $displayHour:$minute $period';
    } catch (_) {
      return value.toString();
    }
  }
}
