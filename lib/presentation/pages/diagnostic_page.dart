import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class DiagnosticPage extends StatefulWidget {
  @override
  _DiagnosticPageState createState() => _DiagnosticPageState();
}

class _DiagnosticPageState extends State<DiagnosticPage> {
  String diagnosticResult = 'Running diagnostics...';
  bool isRunning = true;

  @override
  void initState() {
    super.initState();
    runDiagnostics();
  }

  Future<void> runDiagnostics() async {
    try {
      setState(() {
        diagnosticResult =
            'Checking if app document directory is accessible...';
      });

      final documentsDir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(documentsDir.path, 'hadith.db');
      final dbFile = File(dbPath);

      setState(() {
        diagnosticResult += '\n✅ App documents directory: ${documentsDir.path}';
        print('App documents directory: ${documentsDir.path}');
      });

      // Check if database file exists
      if (await dbFile.exists()) {
        final fileSize = await dbFile.length();
        setState(() {
          print('✅ Database file exists at: $dbPath');
          diagnosticResult += '\n✅ Database file exists at: $dbPath';
          print('📊 Database size: $fileSize bytes');
          diagnosticResult += '\n📊 Database size: $fileSize bytes';
        });
      } else {
        setState(() {
          print('❌ Database file does not exist at: $dbPath');
          diagnosticResult += '\n❌ Database file does not exist at: $dbPath';
        });
      }

      // List assets directory structure
      setState(() {
        diagnosticResult += '\n\nChecking asset bundling...';
        print('Checking asset bundling...');
      });

      try {
        // We can't list directory contents in assets directly,
        // but we can check if specific files exist
        await rootBundle.loadString('AssetManifest.json');
        setState(() {
          diagnosticResult += '\n✅ Asset manifest is accessible';
          print('✅ Asset manifest is accessible');
        });
      } catch (e) {
        setState(() {
          diagnosticResult += '\n❌ Error accessing asset manifest: $e';
          print('❌ Error accessing asset manifest: $e');
        });
      }
    } catch (e) {
      setState(() {
        diagnosticResult += '\n❌ Error during diagnostics: $e';
        print('❌ Error during diagnostics: $e');
      });
    } finally {
      setState(() {
        isRunning = false;
        diagnosticResult += '\n\n✨ Diagnostics complete';
        print('✨ Diagnostics complete');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('App Diagnostics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diagnostic Results:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    diagnosticResult,
                    style: TextStyle(
                      color: Colors.green,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
            if (isRunning)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
