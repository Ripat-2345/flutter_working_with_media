import 'package:flutter/material.dart';
import 'package:flutter_working_with_media/data/api/api_service.dart';
import 'package:flutter_working_with_media/providers/audio_notifier.dart';
import 'package:flutter_working_with_media/providers/home_provider.dart';
import 'package:flutter_working_with_media/providers/upload_provider.dart';
import 'package:flutter_working_with_media/providers/video_notifier.dart';
import 'package:flutter_working_with_media/screens/home_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UploadProvider(
            ApiService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => AudioNotifier(),
        ),
        ChangeNotifierProvider(
          create: (context) => VideoNotifier(),
        ),
      ],
      child: const MaterialApp(
        home: HomePage(),
      ),
    );
  }
}
