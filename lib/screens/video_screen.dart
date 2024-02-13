import 'package:flutter/material.dart';
import 'package:flutter_working_with_media/providers/video_notifier.dart';
import 'package:flutter_working_with_media/utils/utils.dart';
import 'package:flutter_working_with_media/widgets/buffer_slider_controller_widget.dart';
import 'package:flutter_working_with_media/widgets/video_controller_widget.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  VideoPlayerController? controller;
  bool isVideoInitialize = false;

  void videoInitialize() async {
    final previousVideoController = controller;
    final videoController = VideoPlayerController.asset(
      "assets/butterfly.mp4",
    );

    await previousVideoController?.dispose();

    try {
      await videoController.initialize();
    } on Exception catch (e) {
      print("Error initializing video: $e");
    }

    // Setelah proses inisialisasi berhasil, periksa kembali apakah video player siap dipakai atau tidak. Gunakanlah properti mounted untuk mengecek apakah HomeScreen sedang berada di widget tree atau tidak. Gunakan variabel controller untuk memperbarui controller yang baru dan isVideoInitialize untuk memperbarui state.
    if (mounted) {
      setState(() {
        controller = videoController;
        isVideoInitialize = controller!.value.isInitialized;
      });
    }

    // Kita bisa memperhatikan perubahan state pada pemutar video ketika player siap digunakan. Jadi, tambahkanlah method listener ketika player dipakai. Kemudian, perbarui state player dengan mengakses VideoNotifier.
    if (isVideoInitialize) {
      // ignore: use_build_context_synchronously
      final provider = context.read<VideoNotifier>();
      controller?.addListener(() {
        provider.duration = controller?.value.duration ?? Duration.zero;
        provider.position = controller?.value.position ?? Duration.zero;
        provider.isPlay = controller?.value.isPlaying ?? false;
      });
    }
  }

  @override
  void initState() {
    videoInitialize();
    super.initState();
  }

  // Jangan lupa untuk men-dispose pengontrol video player menggunakan method dispose. Hal ini perlu dilakukan agar tidak terjadi memory leak.
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Player Project"),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          isVideoInitialize
              ? AspectRatio(
                  aspectRatio: controller!.value.aspectRatio,
                  child: VideoPlayer(
                    controller!,
                  ),
                )
              : const CircularProgressIndicator(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<VideoNotifier>(
                  builder: (context, provider, child) {
                    final duration = provider.duration;
                    final position = provider.position;

                    return BufferSliderControllerWidget(
                      maxValue: duration.inSeconds.toDouble(),
                      currentValue: position.inSeconds.toDouble(),
                      minText: durationToTimeString(position),
                      maxText: durationToTimeString(duration),
                      onChanged: (value) async {
                        final newPosition = Duration(seconds: value.toInt());
                        await controller?.seekTo(newPosition);

                        await controller?.play();
                      },
                    );
                  },
                ),
                Consumer<VideoNotifier>(
                  builder: (context, provider, child) {
                    final isPlay = provider.isPlay;

                    return VideoControllerWidget(
                      onPlayTapped: () {
                        controller?.play();
                      },
                      onPauseTapped: () {
                        controller?.pause();
                      },
                      isPlay: isPlay,
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
