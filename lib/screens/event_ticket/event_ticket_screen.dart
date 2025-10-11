import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../repositories/event_repository.dart';
import '../../models/event.dart';

class EventTicketScreen extends StatefulWidget {
  final String eventId;

  const EventTicketScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<EventTicketScreen> createState() => _EventTicketScreenState();
}

class _EventTicketScreenState extends State<EventTicketScreen> {
  Event? _event;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    try {
      final eventRepository = context.read<EventRepository>();
      final event = await eventRepository.getEventById(widget.eventId);
      setState(() {
        _event = event;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE91E63), // Pink
                Color(0xFF9C27B0), // Purple
                Color(0xFF673AB7), // Deep Purple
                Color(0xFF3F51B5), // Indigo
                Color(0xFF2196F3), // Blue
              ],
              stops: [0.0, 0.25, 0.5, 0.75, 1.0],
            ),
          ),
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Event Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),
              // Ticket Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : _event == null
                        ? const Center(
                            child: Text(
                              'Event not found',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : _buildTicketCard(_event!, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(event, bool isDark) {
    // Generate QR code data
    final qrData = 'EVENT:${event.id}|USER:97235526|DATE:${event.date.millisecondsSinceEpoch}';
    
    return Center(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Event details
              _buildEventDetails(event),
              const SizedBox(height: 24),
              
              // Attendee information
              _buildAttendeeInfo(),
              const SizedBox(height: 24),
              
              // Perforated line
              _buildPerforatedLine(),
              const SizedBox(height: 24),
              
              // QR Code
              _buildQRCode(qrData),
              const SizedBox(height: 16),
              
              // Instructions
              Text(
                'Scan your QR code at the entry.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventDetails(event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              '${_formatDate(event.date)} ~ INSAT, Tunis, Tunisia',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendeeInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Flen Ben Foulen',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'IEEE ID',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '97235526',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateShort(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Time',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '2:00 PM',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerforatedLine() {
    return Row(
      children: [
        Container(
          width: 20,
          height: 1,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(0.5),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(0.5),
            ),
            child: CustomPaint(
              painter: DashedLinePainter(),
            ),
          ),
        ),
        Container(
          width: 20,
          height: 1,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildQRCode(String data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: 200.0,
        backgroundColor: Colors.white,
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Colors.black,
        ),
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Colors.black,
        ),
      ),
    );
  }


  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day} ${date.year}';
  }

  String _formatDateShort(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day} ${date.year}';
  }
}

// Custom painter for dashed line
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
