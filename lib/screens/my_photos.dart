import 'dart:math';
import 'package:animations/animations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../common/services/data_transport.dart' as data_transport;
import '../common/services/utils.dart';
import '../common/widgets/common.dart';
import 'user_common.dart';

class MyPhotosPage extends StatefulWidget {
  const MyPhotosPage({Key? key}) : super(key: key);

  @override
  State<MyPhotosPage> createState() => _MyPhotosPageState();
}

class _MyPhotosPageState extends State<MyPhotosPage> {
  int present = 0;
  int totalCount = 0;
  String uploadedImageName = '';
  bool isLoading = true;
  List<Widget> photosItems = [];
  List photosItemIds = [];
  List photosData = [];

  @override
  void initState() {
    if (mounted) {
      data_transport.get('uploaded-photos').then((dataReceived) {
        if (mounted) {
          setState(() {
            photosData = getItemValue(dataReceived, 'data.userPhotos');
            isLoading = false;
          });
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          mini: true,
          heroTag: 'myPhotosUpdate',
          child: const Icon(CupertinoIcons.cloud_upload),
          onPressed: () {
            pickAndUploadFile(context, 'upload-photos', allowMultiple: true,
                onStart: (imageSelected) {
              setState(() {
                uploadedImageName = imageSelected;
                isLoading = true;
              });
            }, onSuccess: (value, data) {
              setState(() {
                isLoading = false;
                uploadedImageName = data['data']['image_url'];
              });
            }, onError: (error) {
              setState(() {
                isLoading = false;
              });
            });
          }),
      body: (photosData.isNotEmpty
          ? LayoutBuilder(builder: (context, constraints) {
              return GridView.builder(
                shrinkWrap: true,
                itemCount: photosData.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  crossAxisCount: MediaQuery.of(context).size.width ~/ 180,
                ),
                itemBuilder: (BuildContext context, index) {
                  Map element = photosData[index];
                  if (element['image_url'] == '') {
                    return const Card(
                      color: Colors.transparent,
                      // alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: AppItemProgressIndicator(
                          size: 20,
                        ),
                      ),
                    );
                  } else {
                    return OpenContainer<bool>(
                      openColor: Theme.of(context).scaffoldBackgroundColor,
                      closedColor: Theme.of(context).scaffoldBackgroundColor,
                      transitionType: ContainerTransitionType.fade,
                      openBuilder:
                          (BuildContext _, VoidCallback openContainer) {
                        return ProfileImageView(
                          imageUrl: element['image_url'],
                        );
                      },
                      closedShape: const RoundedRectangleBorder(),
                      closedElevation: 0.0,
                      closedBuilder:
                          (BuildContext _, VoidCallback openContainer) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: AppCachedNetworkImage(
                                imageUrl: element['image_url'],
                                height: 220,
                              ),
                            ),
                            if ((element['is_processing'] != true))
                              Align(
                                alignment: Alignment.topRight,
                                child: TextButton(
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                    ),
                                    onPressed: () {
                                      showActionableDialog(context,
                                          confirmActionText: 'Yes',
                                          cancelActionText: 'No',
                                          description: const Text(
                                              'You want to delete this image?'),
                                          onConfirm: (() {
                                        setState(() {
                                          photosData[index]['is_processing'] =
                                              true;
                                        });
                                        data_transport
                                            .post(
                                                element['_uid'] +
                                                    '/delete-photos',
                                                context: context)
                                            .then((dataReceived) {
                                          setState(() {
                                            photosData.removeWhere((item) {
                                              return item['_uid'] ==
                                                  getItemValue(dataReceived,
                                                      'data.photoUid');
                                            });
                                          });
                                        });
                                      }));
                                    },
                                    child: const Icon(
                                      CupertinoIcons.trash,
                                      size: 20,
                                    )),
                              ),
                            if (element['is_processing'] == true)
                              const SizedBox(
                                height: 150,
                                width: double.infinity,
                                child: AppItemProgressIndicator(
                                  size: 20,
                                ),
                              )
                          ]),
                        );
                      },
                    );
                  }
                },
              );
            })
          : Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading)
                    const AppItemProgressIndicator()
                  else
                    const Text('There are no results to show.'),
                ],
              ),
            )),
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
        allowedExtensions: (allowedExtensions?.isNotEmpty ?? false)
            ? allowedExtensions?.replaceAll(' ', '').split(',')
            : null,
      ))
          ?.files;
      String uploadedImageName = paths?[0].path ?? '';
      if ((uploadedImageName == '')) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      if (onStart != null) {
        onStart(uploadedImageName);
      }
      // blank loader container
      var randomNumberId = Random().nextInt(99999);
      photosData.add({'image_url': '', 'randomNumberId': randomNumberId});
      data_transport.uploadFile(uploadedImageName, url, context: context,
          onError: (error) {
        setState(() {
          photosData.removeWhere((item) => item['image_url'] == '');
        });
        if (onError != null) {
          onError(e);
        }
      }, thenCallback: (data) {
        if (getItemValue(data, 'reaction') != 1) {
          setState(() {
            photosData.removeWhere((item) => item['image_url'] == '');
          });
        }
        if (thenCallback != null) {
          thenCallback(data);
        }
      }, onSuccess: (data) {
        setState(() {
          // remove loading container
          photosData
              .removeWhere((item) => item['randomNumberId'] == randomNumberId);
          photosData.add(data?['data']['stored_photo']);
        });
      });
    } on PlatformException catch (e) {
      setState(() {
        photosData.removeWhere((item) => item['image_url'] == '');
        isLoading = false;
      });
      if (onError != null) {
        onError(e);
      }
      pr('Unsupported operation ${e.toString()}');
      showToastMessage(context, 'Failed', type: 'error');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (onError != null) {
        onError(e);
      }
      showToastMessage(context, 'Failed', type: 'error');
    }
  }
}
