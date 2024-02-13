import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_working_with_media/providers/audio_notifier.dart';
import 'package:flutter_working_with_media/utils/utils.dart';
import 'package:flutter_working_with_media/widgets/audio_controller_widget.dart';
import 'package:flutter_working_with_media/widgets/buffer_slider_controller_widget.dart';
import 'package:provider/provider.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  late final AudioPlayer audioPlayer;
  late final Source audioSource;

  @override
  void initState() {
    final provider = context.read<AudioNotifier>();
    audioPlayer = AudioPlayer();
    audioSource = AssetSource('cricket.wav');
    audioPlayer.setSource(audioSource);

    // Periksalah bagian player, apakah ia sedang berjalan dengan membandingkan state dengan enum PlayerState atau tidak. Lalu, perbarui state aplikasi dengan mengakses provider AudioNotifier.
    audioPlayer.onPlayerStateChanged.listen((state) {
      provider.isPlay = state == PlayerState.playing;
    });
    // Selanjutnya kita akan mengubah durasi audio. Maksud dari durasi ini adalah lamanya waktu audio berakhir. Gunakanlah properti onDurationChanged dan perbarui state durasinya.
    audioPlayer.onDurationChanged.listen((duration) {
      provider.duration = duration;
    });
    // Berikutnya adalah mengatur durasi audio saat ini. Konteks durasi ini merujuk pada perubahan durasi saat audio sedang berlangsung. Dengan begitu, kita dapat mengetahui posisi antara durasi saat ini dan lamanya audio berakhir. Gunakan properti onPositionChanged dan perbarui state posisinya.
    audioPlayer.onPositionChanged.listen((position) {
      provider.position = position;
    });
    // Setelah audio berakhir, kita perlu memastikan bahwa posisi durasi kembali ke semula (tidak berjalan) dan status player telah berhenti. Manfaatkan properti onPlayerComplete sekaligus perbarui state pada AudioNotifier.
    audioPlayer.onPlayerComplete.listen((_) {
      provider.position = Duration.zero;
      provider.isPlay = false;
    });
    // Satu hal lagi yang harus diperhatikan. Ketika pengguna menekan Stop Button, posisi durasi pun harus kembali ke semula. Dengan begitu, pengguna paham bahwa player telah berhenti dan tidak sedang memutar audio ataupun berhenti sejenak. Oleh karena itu, tambahkan pengecualian pada properti onPlayerStateChanged dan perbarui state posisi.
    audioPlayer.onPlayerStateChanged.listen((state) {
      provider.isPlay = state == PlayerState.playing;
      if (state == PlayerState.stopped) {
        provider.position = Duration.zero;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Audio Player Project"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Consumer<AudioNotifier>(
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
                  await audioPlayer.seek(newPosition);

                  await audioPlayer.resume();
                },
              );
            },
          ),
          Consumer<AudioNotifier>(
            builder: (context, provider, child) {
              final bool isPlay = provider.isPlay;
              return AudioControllerWidget(
                onPlayTapped: () {
                  audioPlayer.play(audioSource);
                },
                onPauseTapped: () {
                  audioPlayer.pause();
                },
                onStopTapped: () {
                  audioPlayer.stop();
                },
                isPlay: isPlay,
              );
            },
          ),
        ],
      ),
    );
  }
}
