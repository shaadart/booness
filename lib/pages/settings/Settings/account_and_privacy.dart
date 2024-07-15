import 'package:booness/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

class AccountAndPrivacyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accounts and Privacy'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(PhosphorIcons.user),
            title: Text('Account Settings'),
            onTap: () {
              // Handle account settings tap
            },
          ),

          Divider(),
          ListTile(
            leading: Icon(PhosphorIcons.sign_out),
            title: Text('Log Out'),
            onTap: () {
              signOut(context);
            },
          ),
          ListTile(
            leading: Icon(PhosphorIcons.trash),
            title: Text('Delete Account'),
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
