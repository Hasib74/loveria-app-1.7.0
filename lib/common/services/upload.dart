import 'package:flutter/services.dart';

import 'data_transport.dart' as data_transport;
import 'package:file_picker/file_picker.dart';
import 'utils.dart';

typedef OnCallbackType = Function? Function(Map<String, dynamic>? responseData);

class UploadService {
  void pickAndUploadFile(context, url,
      {OnCallbackType? onSuccess,
      OnCallbackType? thenCallback,
      Function? onError,
      Function? onStart,
      FileType pickingType = FileType.image,
      bool allowMultiple = false,
      String? allowedExtensions = ''}) async {
    try {
      var paths = (await FilePicker.platform.pickFiles(
        type: pickingType,
        allowMultiple: allowMultiple,
        allowedExtensions: (allowedExtensions?.isNotEmpty ?? false)
            ? allowedExtensions?.replaceAll(' ', '').split(',')
            : null,
      ))
          ?.files;
      String uploadedImageName = paths?[0].path ?? '';
      if (onStart != null) {
        onStart(uploadedImageName);
      }
      data_transport.uploadFile(
        uploadedImageName,
        url,
        context: context,
        onSuccess: (responseData) {
          onSuccess!(responseData);
          return;
        },
        onError: onError,
        thenCallback: (responseData) {
          thenCallback!(responseData);
          return;
        },
      );
    } on PlatformException catch (e) {
      if (onError != null) {
        onError(e);
      }
      pr('Unsupported operation ${e.toString()}');
      showToastMessage(context, 'Failed', type: 'error');
    } catch (e) {
      pr(e.toString());
      if (onError != null) {
        onError(e);
      }
      showToastMessage(context, 'Failed', type: 'error');
    }
  }
}
