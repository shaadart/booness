import 'package:booness/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

class AccountAndPrivacyPage extends StatelessWidget {
  const AccountAndPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts and Privacy'),
      ),
      body: ListView(
        children: [
          // ListTile(
          //   leading: const Icon(PhosphorIcons.user),
          //   title: const Text('Account Settings'),
          //   onTap: () {
          //     // Handle account settings tap
          //   },
          // ),

          // const Divider(),
          ListTile(
            leading: const Icon(PhosphorIcons.sign_out),
            title: const Text('Log Out'),
            onTap: () {
              signOut(context);
            },
          ),
          ListTile(
            leading: const Icon(PhosphorIcons.trash),
            title: const Text('Delete Account'),
            onTap: () {
              // Handle security settings tap
            },
          ),
          // Add more list tiles for additional options
        ],
      ),
    );
  }
}
