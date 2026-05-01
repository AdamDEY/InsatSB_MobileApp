import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../repositories/admin_repository.dart';

enum AttendanceScanMode { checkin, checkout }

class AdminCheckinScreen extends StatefulWidget {
  const AdminCheckinScreen({super.key});

  @override
  State<AdminCheckinScreen> createState() => _AdminCheckinScreenState();
}

class _AdminCheckinScreenState extends State<AdminCheckinScreen> {
  final MobileScannerController _scannerController = MobileScannerController();

  bool _isProcessing = false;
  Map<String, dynamic>? _lastResult;
  AttendanceScanMode _scanMode = AttendanceScanMode.checkin;

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

    final adminRepository = context.read<AdminRepository>();
    await _scannerController.stop();

    try {
      final result = _scanMode == AttendanceScanMode.checkin
          ? await adminRepository.verifyCheckin(token)
          : await adminRepository.verifyCheckout(token);

      if (!mounted) return;
      setState(() {
        _lastResult = result;
        _isProcessing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _lastResult = {'error': true, 'message': e.toString()};
        _isProcessing = false;
      });
    }
  }

  Future<void> _resumeScanning() async {
    setState(() {
      _lastResult = null;
    });
    await _scannerController.start();
  }

  void _switchMode(AttendanceScanMode mode) {
    if (_scanMode == mode) return;

    setState(() {
      _scanMode = mode;
      _lastResult = null;
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _scanMode == AttendanceScanMode.checkin
        ? 'Event Check-in Scanner'
        : 'Event Check-out Scanner';

    return Scaffold(
      appBar: AppBar(title: Text(title), elevation: 0),
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
        Positioned(
          top: 24,
          left: 16,
          right: 16,
          child: Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Check-in Mode'),
                  selected: _scanMode == AttendanceScanMode.checkin,
                  onSelected: (_) => _switchMode(AttendanceScanMode.checkin),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Check-out Mode'),
                  selected: _scanMode == AttendanceScanMode.checkout,
                  onSelected: (_) => _switchMode(AttendanceScanMode.checkout),
                ),
              ),
            ],
          ),
        ),
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
              child: Text(
                _scanMode == AttendanceScanMode.checkin
                    ? 'Point camera at attendee\'s QR code to check in'
                    : 'Point camera at attendee\'s QR code to check out',
                style: const TextStyle(
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
    final alreadyCheckedOut = result['alreadyCheckedOut'] == true;
    final checkinWindow = result['checkinWindow'] as Map<String, dynamic>?;
    final windowStatus = checkinWindow?['status']?.toString();

    final String timingText;
    final Color timingColor;
    if (windowStatus == 'too_early') {
      timingText = 'Too Early';
      timingColor = Colors.orange;
    } else if (windowStatus == 'too_late') {
      timingText = 'Too Late';
      timingColor = Colors.red;
    } else if (windowStatus == 'on_time') {
      timingText = 'On Time';
      timingColor = Colors.green;
    } else {
      timingText = 'Window Unavailable';
      timingColor = Colors.blueGrey;
    }

    late final Color statusColor;
    late final IconData statusIcon;
    late final String statusText;

    if (isError) {
      statusColor = Colors.red;
      statusIcon = Icons.error_outline;
      statusText = _scanMode == AttendanceScanMode.checkin
          ? 'Check-in Failed'
          : 'Check-out Failed';
    } else if (_scanMode == AttendanceScanMode.checkin && alreadyCheckedIn) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning_amber_rounded;
      statusText = 'Already Checked In';
    } else if
        (_scanMode == AttendanceScanMode.checkout && alreadyCheckedOut) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning_amber_rounded;
      statusText = 'Already Checked Out';
    } else {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline;
      statusText = _scanMode == AttendanceScanMode.checkin
          ? 'Check-in Successful'
          : 'Check-out Successful';
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(statusIcon, size: 100, color: statusColor),
            const SizedBox(height: 24),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 24),
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
                      result['user']?['fullName']?.toString() ?? 'Unknown',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.email,
                      'Email',
                      result['user']?['email']?.toString() ?? 'Unknown',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.event,
                      'Event',
                      result['event']?['title']?.toString() ?? 'Unknown',
                    ),
                    if (checkinWindow != null) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.schedule,
                        'Timing Status',
                        timingText,
                        valueColor: timingColor,
                      ),
                    ],
                    if (result['event']?['startTime'] != null) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.play_arrow,
                        'Event Starts',
                        _formatDateTime(result['event']['startTime']),
                      ),
                    ],
                    if (result['event']?['endTime'] != null) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.stop,
                        'Event Ends',
                        _formatDateTime(result['event']['endTime']),
                      ),
                    ],
                    if (result['serverTime'] != null) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.access_time_filled,
                        'Server Time',
                        _formatDateTime(result['serverTime']),
                      ),
                    ],
                    if (result['checkedInAt'] != null) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.login,
                        'Checked In At',
                        _formatDateTime(result['checkedInAt']),
                      ),
                    ],
                    if (result['checkedOutAt'] != null) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.logout,
                        'Checked Out At',
                        _formatDateTime(result['checkedOutAt']),
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
                  result['message']?.toString() ?? 'Unknown error',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 32),
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
                  backgroundColor: _scanMode == AttendanceScanMode.checkin
                      ? const Color(0xFF0EA5E9)
                      : const Color(0xFF10B981),
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

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
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
