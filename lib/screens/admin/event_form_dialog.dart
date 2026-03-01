import 'package:flutter/material.dart';
import '../../models/event.dart';

class EventFormDialog extends StatefulWidget {
  final Event? event;
  final Function(Map<String, dynamic>) onSubmit;

  const EventFormDialog({super.key, this.event, required this.onSubmit});

  @override
  State<EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<EventFormDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _categoryController;
  late TextEditingController _attendeesNeededController;
  late TextEditingController _levelController;
  late TextEditingController _speakerNameController;
  late TextEditingController _speakerBioController;
  late TextEditingController _prerequisitesController;
  late TextEditingController _linkedinController;
  late Chapter _selectedChapter;
  late bool _isFeatured;

  // Available levels for the dropdown
  static const List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.event?.description ?? '',
    );
    _dateController = TextEditingController(
      text: widget.event?.date.toString().split(' ')[0] ?? '',
    );
    _startTimeController = TextEditingController(
      text: widget.event != null
          ? '${widget.event!.startTime.hour.toString().padLeft(2, '0')}:${widget.event!.startTime.minute.toString().padLeft(2, '0')}'
          : '',
    );
    _endTimeController = TextEditingController(
      text: widget.event != null
          ? '${widget.event!.endTime.hour.toString().padLeft(2, '0')}:${widget.event!.endTime.minute.toString().padLeft(2, '0')}'
          : '',
    );
    _categoryController = TextEditingController(
      text: widget.event?.category ?? '',
    );
    _attendeesNeededController = TextEditingController(
      text: widget.event?.attendeesNeeded.toString() ?? '',
    );
    _levelController = TextEditingController(
      text: widget.event?.level ?? 'Beginner',
    );
    _speakerNameController = TextEditingController(
      text: widget.event?.speakerFullName ?? '',
    );
    _speakerBioController = TextEditingController(
      text: widget.event?.aboutSpeaker ?? '',
    );
    _prerequisitesController = TextEditingController(
      text: widget.event?.prerequisites ?? '',
    );
    _linkedinController = TextEditingController(
      text: widget.event?.speakerLinkedIn ?? '',
    );
    _selectedChapter = widget.event?.chapter ?? Chapter.cs;
    _isFeatured = widget.event?.isFeatured ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _categoryController.dispose();
    _attendeesNeededController.dispose();
    _levelController.dispose();
    _speakerNameController.dispose();
    _speakerBioController.dispose();
    _prerequisitesController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.event == null ? 'Create Event' : 'Edit Event',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Event Title'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              // --- Chapter dropdown ---
              DropdownButtonFormField<Chapter>(
                value: _selectedChapter,
                decoration: const InputDecoration(labelText: 'Chapter'),
                items: Chapter.values.map((ch) {
                  return DropdownMenuItem(
                    value: ch,
                    child: Text(ch.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedChapter = value);
                  }
                },
              ),
              const SizedBox(height: 12),

              // --- Date picker ---
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    _dateController.text = picked.toIso8601String().split(
                      'T',
                    )[0];
                  }
                },
              ),
              const SizedBox(height: 12),

              // --- Start / End time row ---
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startTimeController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Start Time',
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      onTap: () => _pickTime(_startTimeController),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _endTimeController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'End Time',
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      onTap: () => _pickTime(_endTimeController),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category (e.g. Workshop, Seminar)',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _attendeesNeededController,
                decoration: const InputDecoration(labelText: 'Max Attendees'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              // --- Level dropdown ---
              DropdownButtonFormField<String>(
                value: _levels.contains(_levelController.text)
                    ? _levelController.text
                    : _levels.first,
                decoration: const InputDecoration(labelText: 'Level'),
                items: _levels
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) _levelController.text = value;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _speakerNameController,
                decoration: const InputDecoration(labelText: 'Speaker Name'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _speakerBioController,
                decoration: const InputDecoration(labelText: 'About Speaker'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _prerequisitesController,
                decoration: const InputDecoration(labelText: 'Prerequisites'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _linkedinController,
                decoration: const InputDecoration(
                  labelText: 'Speaker LinkedIn URL',
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),

              // --- isFeatured toggle ---
              SwitchListTile(
                title: const Text('Featured Event'),
                value: _isFeatured,
                onChanged: (value) => setState(() => _isFeatured = value),
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      controller.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  void _submitForm() {
    final date = _dateController.text.trim(); // YYYY-MM-DD
    final startTime = _startTimeController.text.trim(); // HH:mm
    final endTime = _endTimeController.text.trim(); // HH:mm

    // Validate required fields
    if (date.isEmpty || startTime.isEmpty || endTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Date, Start Time, and End Time are required'),
        ),
      );
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Title is required')));
      return;
    }

    // Build proper ISO-8601 datetime strings: "YYYY-MM-DDTHH:mm:ss.sssZ"
    final dateIso = '${date}T00:00:00.000Z';
    final startTimeIso = '${date}T$startTime:00.000Z';
    final endTimeIso = '${date}T$endTime:00.000Z';

    // Debug: print the exact payload being sent
    print('=== EVENT FORM SUBMIT ===');
    print('date raw: "$date"');
    print('startTime raw: "$startTime"');
    print('endTime raw: "$endTime"');
    print('dateIso: "$dateIso"');
    print('startTimeIso: "$startTimeIso"');
    print('endTimeIso: "$endTimeIso"');

    final eventData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'date': dateIso,
      'startTime': startTimeIso,
      'endTime': endTimeIso,
      'category': _categoryController.text.trim(),
      'attendeesNeeded': int.tryParse(_attendeesNeededController.text) ?? 0,
      'registrations': widget.event?.registrations ?? 0,
      'level': _levelController.text,
      'chapter': _selectedChapter.displayName,
      'isFeatured': _isFeatured,
      'speakerFullName': _speakerNameController.text.trim(),
      'aboutSpeaker': _speakerBioController.text.trim(),
      'prerequisites': _prerequisitesController.text.trim(),
      'speakerLinkedin': _linkedinController.text.trim(),
    };
    widget.onSubmit(eventData);
  }
}
