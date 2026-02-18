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
      text: widget.event?.startTime.toString() ?? '',
    );
    _endTimeController = TextEditingController(
      text: widget.event?.endTime.toString() ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.event?.category ?? '',
    );
    _attendeesNeededController = TextEditingController(
      text: widget.event?.attendeesNeeded.toString() ?? '',
    );
    _levelController = TextEditingController(text: widget.event?.level ?? '');
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
            children: [
              Text(
                widget.event == null ? 'Create Event' : 'Edit Event',
                style: Theme.of(context).textTheme.titleLarge,
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
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date (YYYY-MM-DD)',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category/Location',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _attendeesNeededController,
                decoration: const InputDecoration(labelText: 'Max Attendees'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _levelController,
                decoration: const InputDecoration(labelText: 'Level'),
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

  void _submitForm() {
    final eventData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'date': _dateController.text,
      'startTime': _startTimeController.text,
      'endTime': _endTimeController.text,
      'category': _categoryController.text,
      'attendeesNeeded': int.tryParse(_attendeesNeededController.text) ?? 0,
      'level': _levelController.text,
      'speakerFullName': _speakerNameController.text,
      'aboutSpeaker': _speakerBioController.text,
      'prerequisites': _prerequisitesController.text,
      'speakerLinkedin': _linkedinController.text,
      'registrations': widget.event?.registrations ?? 0,
      'isFeatured': widget.event?.isFeatured ?? false,
      'chapter': widget.event?.chapter.displayName ?? 'CS',
    };
    widget.onSubmit(eventData);
  }
}
