import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:economycraft/database_managment/supabase_helper.dart';
import 'package:flutter/widgets.dart';

const appVersion = '1.4';

class OutOfDateScreen extends StatefulWidget {
  const OutOfDateScreen({super.key});

  @override
  State<OutOfDateScreen> createState() => _OutOfDateScreenState();
}

class _OutOfDateScreenState extends State<OutOfDateScreen> {
  @override
  void initState() {
    super.initState();
    isOutOfDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Out of Date')),
      body: Center(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/background_images/quartz_background.png',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Your app is out of date!',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Please hard reload this page to get the latest version.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void isOutOfDate() async {
    final String version = await SupabaseHelper.versioning.getCurrentVersion();
    if (version == appVersion) {
      context.go('/home');
    }
  }
}
