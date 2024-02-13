import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({
    super.key,
    required this.cameras,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  bool _isBackCameraSelected = true;
  bool _isCameraInitialized = false;

  CameraController? controller;

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    final cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
    );
    await previousCameraController?.dispose();

    try {
      await cameraController.initialize();
    } catch (e) {
      print("Error initializing camera: $e");
    }

    if (mounted) {
      setState(() {
        controller = cameraController;
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  // Untuk menangani perubahan siklus aplikasi, tambahkan method didChangeAppLifecycleState
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    onNewCameraSelected(widget.cameras.first);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Ambil Gambar"),
          actions: [
            IconButton(
              onPressed: () => _onCameraSwitch(),
              icon: const Icon(Icons.cameraswitch),
            ),
          ],
        ),
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              _isCameraInitialized
                  ? CameraPreview(controller!)
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
              Align(
                alignment: const Alignment(0, 0.95),
                child: _actionWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionWidget() {
    return FloatingActionButton(
      heroTag: "take-picture",
      tooltip: "Ambil Gambar",
      onPressed: () => _onCameraButtonClick(),
      child: const Icon(Icons.camera_alt),
    );
  }

  Future<void> _onCameraButtonClick() async {
    final navigator = Navigator.of(context);
    final image = await controller?.takePicture();

    navigator.pop(image);
  }

  void _onCameraSwitch() {
    setState(() {
      _isCameraInitialized = false;
    });

    onNewCameraSelected(
      widget.cameras[_isBackCameraSelected ? 1 : 0],
    );

    setState(() {
      _isBackCameraSelected = !_isBackCameraSelected;
    });
  }
}


/* 
Kita dapat mengetahui siklus aplikasi dengan bantuan kelas WidgetsBindingObserver. Didukung dengan method didChangeAppLifecycleState, siklus aplikasi dapat dideteksi secara lebih tepat. Berikut empat siklus yang dapat Anda pantau.

AppLifecycleState.resumed: kondisi yang menunjukkan aplikasi telah tampil dan siap menerima aksi dari pengguna.
AppLifecycleState.inactive: kondisi yang menunjukkan aplikasi tidak aktif dan tidak bisa menerima aksi dari pengguna.
AppLifecycleState.paused: kondisi yang menunjukkan aplikasi tidak aktif dan berada di background.
AppLifecycleState.detached: kondisi yang menunjukkan aplikasi masih berjalan pada Flutter Engine, tetapi tampilan aplikasi tidak muncul.
Anda dapat pelajari lebih dalam terkait siklus aplikasi pada laman AppLifecycleState enum.
*/