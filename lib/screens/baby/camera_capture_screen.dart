import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';

class CameraCaptureResult {
  final XFile? file;
  final bool useFallback;

  const CameraCaptureResult._({this.file, this.useFallback = false});
  const CameraCaptureResult.file(XFile file) : this._(file: file);
  const CameraCaptureResult.fallback() : this._(useFallback: true);
}

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  XFile? _capturedFile;
  String? _errorMessage;
  bool _initializing = true;
  bool _capturing = false;
  int _cameraIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed && _capturedFile == null) {
      _initialize();
    }
  }

  Future<void> _initialize() async {
    if (!mounted) return;
    setState(() {
      _initializing = true;
      _errorMessage = null;
    });
    try {
      final cameras = await availableCameras();
      if (!mounted) return;
      if (cameras.isEmpty) {
        throw CameraException(
          'NoCamera',
          'Không tìm thấy camera trên thiết bị.',
        );
      }
      _cameras = cameras;
      if (_cameraIndex >= cameras.length) _cameraIndex = 0;
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        final backIndex = cameras.indexWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
        );
        if (backIndex >= 0 && _controller == null) _cameraIndex = backIndex;
      }
      await _createController(cameras[_cameraIndex]);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _errorMessage = _cameraErrorMessage(error);
      });
    }
  }

  Future<void> _createController(CameraDescription description) async {
    await _controller?.dispose();
    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _controller = controller;
    await controller.initialize();
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() => _initializing = false);
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _capturing) return;
    setState(() => _initializing = true);
    try {
      _cameraIndex = (_cameraIndex + 1) % _cameras.length;
      await _createController(_cameras[_cameraIndex]);
    } catch (error) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _errorMessage = _cameraErrorMessage(error);
        });
      }
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (_capturing || controller == null || !controller.value.isInitialized) {
      return;
    }
    setState(() => _capturing = true);
    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      setState(() {
        _capturedFile = file;
        _capturing = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _capturing = false);
      _show(_cameraErrorMessage(error));
    }
  }

  String _cameraErrorMessage(Object error) {
    if (error is CameraException) {
      final code = error.code.toLowerCase();
      if (code.contains('accessdenied') || code.contains('permission')) {
        return 'Ứng dụng chưa được cấp quyền camera. Mẹ hãy bật quyền Camera trong Cài đặt; trên Windows vào Settings > Privacy & security > Camera.';
      }
      if (code.contains('inuse') || code.contains('busy')) {
        return 'Camera đang được ứng dụng khác sử dụng. Mẹ hãy đóng ứng dụng đó rồi thử lại.';
      }
      if (code.contains('nocamera'))
        return 'Không tìm thấy camera trên thiết bị.';
    }
    return 'Không thể khởi tạo camera. Mẹ hãy kiểm tra webcam hoặc thử lại.';
  }

  void _show(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final file = _capturedFile;
    return Scaffold(
      backgroundColor: AppColors.textDark,
      appBar: AppBar(
        title: Text(file == null ? 'Chụp ảnh cho bé' : 'Xem lại ảnh'),
        actions: [
          if (file == null && _cameras.length > 1)
            IconButton(
              onPressed: _switchCamera,
              icon: const Icon(Icons.cameraswitch_outlined),
              tooltip: 'Đổi camera',
            ),
        ],
      ),
      body: _buildBody(file),
    );
  }

  Widget _buildBody(XFile? file) {
    if (file != null) {
      return Column(
        children: [
          Expanded(
            child: Center(
              child: Image.file(File(file.path), fit: BoxFit.contain),
            ),
          ),
          _bottomActions([
            OutlinedButton(
              onPressed: () => setState(() => _capturedFile = null),
              child: const Text('Chụp lại'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, CameraCaptureResult.file(file)),
              child: const Text('Dùng ảnh này'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
          ]),
        ],
      );
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.white,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.white),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(
                  context,
                  const CameraCaptureResult.fallback(),
                ),
                child: const Text('Dùng camera hệ thống'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
            ],
          ),
        ),
      );
    }
    if (_initializing || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.white),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_controller!),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 28),
            child: IconButton(
              onPressed: _capturing ? null : _capture,
              iconSize: 76,
              icon: Icon(
                Icons.radio_button_checked,
                color: _capturing ? AppColors.textMuted : AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomActions(List<Widget> actions) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
    child: Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: actions,
    ),
  );
}
