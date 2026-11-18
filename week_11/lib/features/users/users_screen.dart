import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_detail_screen.dart';
import 'user_form_screen.dart';
import 'users_model.dart';
import 'widgets/state_views.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const UserFormScreen())),
        icon: const Icon(Icons.person_add),
        label: const Text('New user'),
      ),
      body: _body(m),
    );
  }

  Widget _body(UsersModel m) {
    if (m.loading) return const LoadingView();
    // exhaustive, because ApiException is sealed — no default
    return switch (m.error) {
      null => UserList(m.items, onRefresh: m.load),
      NoConnectionException() => Offline(onRetry: m.load),
      NotFoundException() || UnauthorizedException() => const RequestFailed(),
      ServerException(:final status) => ServerError(status, onRetry: m.load),
      BadResponseException() => const GenericError(),
    };
  }
}

class UserList extends StatelessWidget {
  const UserList(this.users, {super.key, required this.onRefresh});

  final List<User> users;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        // lets the list be pulled even when it is short
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: users.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final u = users[i];
          return ListTile(
            title: Text(u.name),
            subtitle: Text('${u.email}\n${u.address.city}'),
            isThreeLine: true,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => UserDetailScreen(user: u),
              ),
            ),
          );
        },
      ),
    );
  }
}
