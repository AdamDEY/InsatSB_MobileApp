import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import 'admin_users_view_model.dart';
import 'user_form_dialog.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminUsersViewModel>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminUsersViewModel>(
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
                      'Total Users: ${viewModel.users.length}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _showCreateUserDialog(context, viewModel),
                      icon: const Icon(Icons.person_add),
                      label: const Text('New User'),
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
                    : viewModel.users.isEmpty
                    ? const Center(child: Text('No users found'))
                    : ListView.builder(
                        itemCount: viewModel.users.length,
                        itemBuilder: (context, index) {
                          final user = viewModel.users[index];
                          return _buildUserCard(context, user, viewModel);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    AppUser user,
    AdminUsersViewModel viewModel,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        title: Text(user.fullName),
        subtitle: Text(user.email),
        trailing: Chip(
          label: Text(user.role.displayName),
          backgroundColor: user.role.isAdmin ? Colors.orange : Colors.blue,
          labelStyle: const TextStyle(color: Colors.white),
        ),
        onTap: () => _showUserOptions(context, user, viewModel),
      ),
    );
  }

  void _showUserOptions(
    BuildContext context,
    AppUser user,
    AdminUsersViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('User Details'),
              subtitle: Text(user.email),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.security),
              title: user.role.isAdmin
                  ? const Text('Remove Admin Role')
                  : const Text('Make Admin'),
              onTap: () {
                viewModel.updateUserRole(user.id, !user.role.isAdmin);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      user.role.isAdmin
                          ? 'Admin role removed'
                          : 'Admin role granted',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete User',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _showDeleteConfirmation(context, user, viewModel),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateUserDialog(
    BuildContext context,
    AdminUsersViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(
        onSubmit: (userData) async {
          final success = await viewModel.createUser(userData);
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? 'User created successfully'
                      : viewModel.errorMessage ?? 'Failed to create user',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    AppUser user,
    AdminUsersViewModel viewModel,
  ) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to delete ${user.fullName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteUser(user.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user.fullName} deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
