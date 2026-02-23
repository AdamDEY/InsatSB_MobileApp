import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import 'admin_events_view_model.dart';
import 'event_form_dialog.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  @override
  void initState() {
    super.initState();
    // Load events on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Events are loaded when fetched from repository
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminEventsViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Events: ${viewModel.events.length}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _showCreateEventDialog(context, viewModel),
                      icon: const Icon(Icons.add),
                      label: const Text('New Event'),
                    ),
                  ],
                ),
              ),
              if (viewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(viewModel.errorMessage!),
                  ),
                ),
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.events.isEmpty
                    ? const Center(child: Text('No events yet'))
                    : ListView.builder(
                        itemCount: viewModel.events.length,
                        itemBuilder: (context, index) {
                          final event = viewModel.events[index];
                          return _buildEventCard(context, event, viewModel);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    Event event,
    AdminEventsViewModel viewModel,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        title: Text(event.title),
        subtitle: Text(
          '${event.date} - ${event.registrations}/${event.attendeesNeeded} registered',
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Edit'),
              onTap: () => _showEditEventDialog(context, event, viewModel),
            ),
            PopupMenuItem(
              child: const Text('Delete'),
              onTap: () => _showDeleteConfirmation(context, event, viewModel),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateEventDialog(
    BuildContext context,
    AdminEventsViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => EventFormDialog(
        onSubmit: (eventData) {
          viewModel.createEvent(eventData);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditEventDialog(
    BuildContext context,
    Event event,
    AdminEventsViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => EventFormDialog(
        event: event,
        onSubmit: (eventData) {
          viewModel.updateEvent(event.id, eventData);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Event event,
    AdminEventsViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteEvent(event.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
