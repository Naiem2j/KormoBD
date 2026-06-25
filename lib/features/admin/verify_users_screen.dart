import 'package:flutter/material.dart';
import '../../core/services/user_service.dart';
import '../../models/user_model.dart';

class VerifyUsersScreen extends StatefulWidget {
  const VerifyUsersScreen({super.key});

  @override
  State<VerifyUsersScreen> createState() => _VerifyUsersScreenState();
}

class _VerifyUsersScreenState extends State<VerifyUsersScreen> {
  void _approve(UserModel u) {
    UserService.instance.approveUser(u.id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Approved: ${u.name}')));
  }

  void _reject(UserModel u) {
    UserService.instance.rejectUser(u.id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Rejected: ${u.name}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Users')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder<List<UserModel>>(
          valueListenable: UserService.instance.users,
          builder: (context, users, _) {
            final pending = users.where((u) => u.status == 'pending').toList();
            if (pending.isEmpty) {
              return Center(
                child: Text(
                  'No users to verify',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }
            return ListView.separated(
              itemCount: pending.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final u = pending[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.grey.shade100,
                          child: Text(
                            u.name[0],
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                u.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${u.role[0].toUpperCase()}${u.role.substring(1)} • ${u.status}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () => _approve(u),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Approve'),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () => _reject(u),
                              child: const Text('Reject'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
