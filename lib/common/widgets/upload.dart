import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import '../services/auth.dart' as auth;
import '../services/utils.dart';
import 'common.dart';
import '../services/data_transport.dart' as data_transport;
import 'package:file_picker/file_picker.dart';
import '../../support/app_theme.dart' as app_theme;

class UploadWidget extends StatefulWidget {
  final String buttonLabel;
  final String label;
  final String uploadUrl;
  final String placeholderNetworkImage;
  final ButtonStyle? buttonStyle;
  final FileType pickingType;
  final bool allowMultiple;
  final Function? onSuccess;
  final Function? thenCallback;
  final Function? onError;
  final Function? onStart;
  const UploadWidget(
      {super.key,
      required this.uploadUrl,
      required this.label,
      this.buttonLabel = 'Select file',
      this.placeholderNetworkImage = '',
      this.allowMultiple = false,
      this.pickingType = FileType.image,
      this.buttonStyle,
      this.onSuccess,
      this.thenCallback,
      this.onError,
      this.onStart});
  @override
  State<UploadWidget> createState() => _UploadWidgetState();
}

class _UploadWidgetState extends State<UploadWidget> {
  String uploadedImageName = '';
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10, top: 0),
                child: Text(
                  widget.label,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              // if (_isLoading == false)
              Stack(
                children: [
                  if (uploadedImageName != '' && _isLoading == false)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8), // Image border
                      child: AppCachedNetworkImage(
                        imageUrl: uploadedImageName,
                        height: 250,
                      ),
                    )
                  else
                    (widget.placeholderNetworkImage == '')
                        ? const Text('Upload New Image')
                        : (uploadedImageName != '' && _isLoading)
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(8), // Image border
                                  child: AppCachedNetworkImage(
                                    imageUrl: widget.placeholderNetworkImage,
                                    height: 250,
                                  ),
                                ),
                              ),
                  /* Builder(
                      builder: (BuildContext context) => */
                  _isLoading
                      ? const SizedBox(
                          height: 250,
                          child: Center(
                            child: AppItemProgressIndicator(),
                          ),
                        )
                      : Container()
                  // ),
                ],
              ),
              TextButton(
                style: widget.buttonStyle,
                onPressed: () {
                  pickAndUploadFile(context, widget.uploadUrl,
                      pickingType: widget.pickingType,
                      allowMultiple: widget.allowMultiple,
                      onStart: (imageSelected) {
                    setState(() {
                      uploadedImageName = imageSelected;
                      _isLoading = true;
                    });
                  }, thenCallback: (data) {
                    if (widget.thenCallback != null) {
                      widget.thenCallback!(data);
                    }
                  }, onSuccess: (data) {
                    setState(() {
                      _isLoading = false;
                      uploadedImageName = data['data']['image_url'];
                    });
                    if (widget.onSuccess != null) {
                      widget.onSuccess!(data);
                    }
                  }, onError: (error) {
                    setState(() {
                      _isLoading = false;
                    });
                    if (widget.onError != null) {
                      widget.onError!(error);
                    }
                  });
                },
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(CupertinoIcons.cloud_upload),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(widget.buttonLabel),
                  )
                ]),
              )
            ],
          )
        ],
      ),
    );
  }

  void pickAndUploadFile(context, url,
      {Function? onSuccess,
      Function? thenCallback,
      Function? onError,
      Function? onStart,
      FileType pickingType = FileType.image,
      bool allowMultiple = false,
      String? allowedExtensions = ''}) async {
    // _resetState();
    try {
      // _directoryPath = null;
      var paths = (await FilePicker.platform.pickFiles(
        type: pickingType,
        allowMultiple: allowMultiple,
        // onFileLoading: (FilePickerStatus status) => pr(status),
        allowedExtensions: (allowedExtensions?.isNotEmpty ?? false)
            ? allowedExtensions?.replaceAll(' ', '').split(',')
            : null,
      ))
          ?.files;
      // setState(() {
      String uploadedImageName = paths?[0].path ?? '';
      // });
      if ((uploadedImageName == '') || (uploadedImageName == null)) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
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
      setState(() {
        _isLoading = false;
      });
      if (onError != null) {
        onError(e);
      }
      pr('Unsupported operation ${e.toString()}');
      showToastMessage(context, 'Failed', type: 'error');
    } catch (e) {
      pr(e.toString());
      setState(() {
        _isLoading = false;
      });
      if (onError != null) {
        onError(e);
      }
      showToastMessage(context, 'Failed', type: 'error');
    }
  }
}

class UploadImagesWidget extends StatefulWidget {
  final String buttonLabel;
  final String label;
  final String uploadUrl;
  final String placeholderNetworkImage;
  final ButtonStyle? buttonStyle;
  final FileType pickingType;
  final bool allowMultiple;
  final Function? onSuccess;
  final Function? thenCallback;
  final Function? onError;
  final Function? onStart;
  const UploadImagesWidget(
      {super.key,
      required this.uploadUrl,
      required this.label,
      this.buttonLabel = 'Select file',
      this.placeholderNetworkImage = '',
      this.allowMultiple = false,
      this.pickingType = FileType.image,
      this.buttonStyle,
      this.onSuccess,
      this.thenCallback,
      this.onError,
      this.onStart});
  @override
  State<UploadImagesWidget> createState() => _UploadImagesWidgetState();
}

class _UploadImagesWidgetState extends State<UploadImagesWidget> {
  String uploadedImageName = '';
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  widget.label,
                  style: const TextStyle(color: app_theme.white, fontSize: 22),
                ),
              ),
              // if (_isLoading == false)
              Stack(
                children: [
                  if (uploadedImageName != '' && _isLoading == false)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8), // Image border
                      child: Image.network(
                        uploadedImageName,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 250,
                      ),
                    )
                  else
                    (widget.placeholderNetworkImage == '')
                        ? const Text('Upload New Image')
                        : (uploadedImageName != '' && _isLoading)
                            ? Container()
                            : ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(8), // Image border
                                child: Image.network(
                                  widget.placeholderNetworkImage,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 250,
                                ),
                              ),
                  _isLoading
                      ? const SizedBox(
                          height: 250,
                          child: Center(
                            child: AppItemProgressIndicator(),
                          ),
                        )
                      : Container()
                  // ),
                ],
              ),
              ElevatedButton(
                style: widget.buttonStyle,
                onPressed: () {
                  pickAndUploadFile(context, widget.uploadUrl,
                      pickingType: widget.pickingType,
                      allowMultiple: widget.allowMultiple,
                      onStart: (imageSelected) {
                    setState(() {
                      uploadedImageName = imageSelected;
                      pr(widget.placeholderNetworkImage);
                      pr(uploadedImageName);
                      _isLoading = true;
                    });
                  }, thenCallback: (data) {
                    if (widget.thenCallback != null) {
                      widget.thenCallback!(data);
                    }
                  }, onSuccess: (data) {
                    setState(() {
                      _isLoading = false;
                      uploadedImageName = data['data']['image_url'];
                    });
                    if (widget.onSuccess != null) {
                      widget.onSuccess!(data);
                    }
                  }, onError: (error) {
                    pr('error');
                    setState(() {
                      _isLoading = false;
                    });
                    if (widget.onError != null) {
                      widget.onError!(error);
                    }
                  });
                },
                child: Text(widget.buttonLabel),
              )
            ],
          )
        ],
      ),
    );
  }

  void pickAndUploadFile(context, url,
      {Function? onSuccess,
      Function? thenCallback,
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
      if ((uploadedImageName == '') || (uploadedImageName == null)) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
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
      setState(() {
        _isLoading = false;
      });
      if (onError != null) {
        onError(e);
      }
      pr('Unsupported operation ${e.toString()}');
      showToastMessage(context, 'Failed', type: 'error');
    } catch (e) {
      pr(e.toString());
      setState(() {
        _isLoading = false;
      });
      if (onError != null) {
        onError(e);
      }
      showToastMessage(context, 'Failed', type: 'error');
    }
  }
}
