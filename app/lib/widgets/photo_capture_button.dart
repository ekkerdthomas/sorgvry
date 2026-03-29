import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../providers/media_providers.dart';
import '../theme.dart';

class PhotoCaptureButton extends ConsumerStatefulWidget {
  final String module;
  final String? session;
  final bool compact;

  const PhotoCaptureButton({
    super.key,
    required this.module,
    this.session,
    this.compact = false,
  });

  @override
  ConsumerState<PhotoCaptureButton> createState() => _PhotoCaptureButtonState();
}

class _PhotoCaptureButtonState extends ConsumerState<PhotoCaptureButton> {
  String? _photoPath;
  bool _saving = false;

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (photo == null) return;

    setState(() => _saving = true);

    final appDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(p.join(appDir.path, 'media'));
    if (!mediaDir.existsSync()) {
      mediaDir.createSync(recursive: true);
    }

    final suffix = widget.session != null
        ? '${widget.module}-${widget.session}'
        : widget.module;
    final fileName = '$suffix-${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = p.join(mediaDir.path, fileName);
    await File(photo.path).copy(savedPath);

    await ref
        .read(mediaRepoProvider)
        .savePhoto(
          module: widget.module,
          session: widget.session,
          localPath: savedPath,
        );

    if (mounted) {
      setState(() {
        _photoPath = savedPath;
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_photoPath != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(SorgvrySpacing.cardRadius),
            child: Image.file(
              File(_photoPath!),
              height: 120,
              width: 120,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _takePhoto,
            icon: const Icon(Icons.camera_alt),
            label: const Text('WEER'),
          ),
        ],
      );
    }

    if (_saving) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      );
    }

    if (widget.compact) {
      return OutlinedButton.icon(
        onPressed: _takePhoto,
        icon: const Icon(Icons.camera_alt),
        label: const Text('NEEM FOTO'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(SorgvrySpacing.buttonHeight - 16),
        ),
      );
    }

    return FilledButton.icon(
      onPressed: _takePhoto,
      icon: const Icon(Icons.camera_alt, size: 28),
      label: const Text('NEEM FOTO'),
    );
  }
}
