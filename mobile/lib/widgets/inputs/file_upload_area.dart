import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FileUploadArea extends StatefulWidget {
  final void Function(List<String> paths)? onFilesSelected;
  final int maxFiles;
  const FileUploadArea({super.key, this.onFilesSelected, this.maxFiles = 5});

  @override
  State<FileUploadArea> createState() => _FileUploadAreaState();
}

class _FileUploadAreaState extends State<FileUploadArea> {
  final List<String> _files = [];

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() { _files.addAll(images.map((i) => i.path).take(widget.maxFiles - _files.length)); });
      widget.onFilesSelected?.call(_files);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      GestureDetector(
        onTap: _pickImages,
        child: Container(
          width: double.infinity, height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF0F4C3A), style: BorderStyle.solid, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.cloud_upload_outlined, size: 32, color: Color(0xFF0F4C3A)),
            SizedBox(height: 8),
            Text('Drag & drop or tap to upload', style: TextStyle(color: Color(0xFF6B7280))),
            Text('Max 5 photos, 10MB each', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
          ]),
        ),
      ),
      if (_files.isNotEmpty) ...[
        const SizedBox(height: 8),
        SizedBox(height: 60, child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _files.length,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(children: [
              ClipRRect(borderRadius: BorderRadius.circular(8), child: SizedBox(width: 60, height: 60, child: Container(color: Colors.grey.shade200, child: const Icon(Icons.image)))),
              Positioned(top: 0, right: 0, child: GestureDetector(
                onTap: () { setState(() => _files.removeAt(i)); widget.onFilesSelected?.call(_files); },
                child: Container(decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white)),
              )),
            ]),
          ),
        )),
      ],
    ]);
  }
}
