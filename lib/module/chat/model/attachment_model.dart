class AttachmentModel {
  final String fileName;
  final String fileUrl;
  final String? localPath;
  final String? mimeType;
  final String type; // e.g., 'video', 'image', 'file'
  final int? fileSize;
  final String? thumbnailPath;

  AttachmentModel({
    required this.fileName,
    required this.fileUrl,
    this.localPath,
    this.mimeType,
    required this.type,
    this.fileSize,
    this.thumbnailPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'fileUrl': fileUrl,
      'localPath': localPath,
      'mimeType': mimeType,
      'type': type,
      'fileSize': fileSize,
      'thumbnailFileUrl': thumbnailPath,
    };
  }

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      fileName: json['fileName'] ?? "",
      fileUrl: json['fileUrl'] ?? "",
      localPath: json['localPath'] ?? "",
      mimeType: json['mimeType'] ?? "",
      type: json['type'] ?? "",
      fileSize: json['fileSize'] ?? 0,
      thumbnailPath: json['thumbnailFileUrl'] ?? "",
    );
  }
}
