import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_html/html.dart';

class FileDownloadBloc extends Bloc<FileDownloadEvent, FileDownloadState> {
  FileDownloadBloc() : super(FileDownloadInitial()) {
    on<FileDownload>((event, emit) async {
      emit(FileDownloadProgress());
      try {
        final response = await Dio().get(
          event.fileUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        final Uint8List bytes = response.data;
        final String extension = path.extension(event.fileUrl).split("?")[0];
        final String mimeType = getMimeTypeFromUrl(extension);
        final blob = Blob([bytes], mimeType);
        final url = Url.createObjectUrlFromBlob(blob);
        final anchor = AnchorElement(href: url);
        anchor.download = event.fileName + extension;
        anchor.click();
        Url.revokeObjectUrl(url);
        emit(FileDownloadSuccess());
      } catch (e) {
        if (kDebugMode) debugPrint("file download Error >> \n error: $e");
        emit(FileDownloadFailure(e));
      }
    });
  }
}

///states - inst
abstract class FileDownloadState {}

class FileDownloadInitial extends FileDownloadState {}

class FileDownloadProgress extends FileDownloadState {}

class FileDownloadSuccess extends FileDownloadState {}

class FileDownloadFailure extends FileDownloadState {
  FileDownloadFailure(this.error);
  final dynamic error;
}

///events impl
abstract class FileDownloadEvent {}

class FileDownload extends FileDownloadEvent {
  final String fileUrl;
  final String fileName;
  FileDownload({
    required this.fileUrl,
    required this.fileName,
  });
}

String getMimeTypeFromUrl(String extension) {
  switch (extension) {
    case ".jpg":
    case ".jpeg":
      return "image/jpeg";
    case ".png":
      return "image/png";
    case ".gif":
      return "image/gif";
    case ".pdf":
      return "application/pdf";
    case ".doc":
    case ".docx":
      return "application/msword";
    case ".ppt":
    case ".pptx":
      return "application/vnd.ms-powerpoint";
    case ".xls":
    case ".xlsx":
      return "application/vnd.ms-excel";
    case ".zip":
      return "application/zip";
    default:
      return "application/octet-stream";
  }
}
