import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class ScreenAddFace extends StatefulWidget {
  const ScreenAddFace({super.key});

  @override
  State<ScreenAddFace> createState() => _ScreenAddFaceState();
}

class _ScreenAddFaceState extends State<ScreenAddFace> {
  List<XFile> _images = [];
  bool _isEditMode = false;

  Future<void> _pickImagesFromGallery() async {
    // 권한 상태 확인 및 요청
    var status = await Permission.photos.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      // 권한이 거부된 경우, 다시 요청
      status = await Permission.photos.request();
    }

    if (status.isGranted || status.isLimited) {
      // 권한이 허용된 경우 이미지 선택
      final pickedFiles = await ImagePicker().pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          //기존 이미지와 새로 선택한 이미지를 합치고 중복 제거
          _images = [
            ..._images,
            ...pickedFiles.where((newFile) => !_images
                .any((existingFile) => existingFile.path == newFile.path))
          ];
        });
      }
    } else {
      // 사용자가 권한 요청을 거부한 경우 알림 표시
      _showPermissionDeniedDialog();
    }
  }

  Future<void> _takePhoto() async {
    // 카메라 권한 상태 확인 및 요청
    var status = await Permission.camera.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      // 권한이 거부된 경우, 다시 요청
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      // 권한이 허용된 경우 사진 촬영
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          // 기존 이미지와 새로 촬영한 이미지를 합치고 중복 제거
          if (!_images
              .any((existingFile) => existingFile.path == pickedFile.path)) {
            _images.add(pickedFile);
          }
        });
      }
    } else {
      // 사용자가 권한 요청을 거부한 경우 알림 표시
      _showPermissionDeniedDialog();
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      if (_images.isEmpty) _isEditMode = false; //사진 전부 삭제시 편집모드 종료
    });
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Denied'),
        content: Text('Access to photos or camera is required.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _viewImage(BuildContext context, int index) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Image.file(
          File(_images[index].path),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Future<void> uploadImages(
      List<XFile> images, String category, String name, String info) async {
    print('들어간거 맞음?');
    final uuid = Uuid();
    final personId = uuid.v4(); // 고유 ID 생성
    List<String> imageUrls = [];
    print('들어간거 맞음?2');
    for (var image in images) {
      print('들어간거 맞음?3');
      try {
        print('들어간거 맞음?4');
        // Upload image to Firebase Storage
        final storageRef = FirebaseStorage.instance.ref();
        print('들어간거 맞음?5');
        final uniqueFileName =
            '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        print('들어간거 맞음?6');
        final imageRef =
            storageRef.child('$category/$personId/$uniqueFileName');
        print('들어간거 맞음?7');
        print('파일 경로: ${image.path}');

        await imageRef.putFile(File(image.path));
        print('들어간거 맞음?8');
        // Get download URL
        final downloadUrl = await imageRef.getDownloadURL();
        print('Image uploaded: $downloadUrl');
        imageUrls.add(downloadUrl);
        // Save metadata and URL to Firestore
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
    print('이거 실행 된거 맞음?');
    await savePersonData(category, personId, name, info, imageUrls);
  }

  Future<void> savePersonData(String category, String personId, String name,
      String info, List<String> imageUrls) async {
    final docRef = FirebaseFirestore.instance
        .collection('data')
        .doc('doorlock')
        .collection('FaceCategory')
        .doc(category)
        .collection('people')
        .doc(personId);

    await docRef.set({
      'name': name,
      'info': info,
      'imageUrls': imageUrls,
    });
  }

  // void _toggleEditMode() {
  //   setState(() {
  //     _isEditMode = !_isEditMode;
  //   });
  // }

  final _formKey = GlobalKey<FormState>();
  List<String> dropDownListCategory = ["가족", "지인"];
  String selectCategory = '가족';
  String name = '';
  String info = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('얼굴 등록',style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    DropdownButton2(
                      items: dropDownListCategory
                          .map((item) =>
                              DropdownMenuItem(value: item, child: Text(item)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectCategory = value!;
                        });
                      },
                      value: selectCategory,
                      alignment: AlignmentDirectional.centerStart,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(labelText: '이름 입력'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이름은 필수입니다.';
                    }
                    return null;
                  },
                  onSaved: (value) => name = value!,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(labelText: '기본 정보 입력'),
                  onSaved: (value) {
                    if (value == null || value.isEmpty) {
                      info = '';
                    } else {
                      info = value;
                    }
                  },
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _pickImagesFromGallery,
                child: Text('Select from Gallery'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _takePhoto,
                child: Text('Take Photo'),
              ),
            ],
          ),
          if (_isEditMode)
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.yellow,
              child: Center(child: Text('업로드 목록 수정 중')),
            ),
          if (_isEditMode)
            Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() {
                    _isEditMode = false;
                  }),
                  child: Text(
                    '이미지 목록 편집 취소',
                    style: TextStyle(),
                  ),
                ),
              ),
            ]),
          Expanded(
            child: GridView.builder(
              itemCount: _images.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () => _viewImage(context, index),
                  onLongPress: () => setState(() => _isEditMode = true),
                  child: Stack(
                    children: [
                      Image.file(File(_images[index].path), fit: BoxFit.cover),
                      if (_isEditMode)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => _removeImage(index),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: (_images.isEmpty)
                ? () {
                    // 이미지가 없을 경우 알림 표시
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('알림'),
                          content: Text('이미지를 1개 이상 등록하세요.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('확인'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                : () {
                    bool isValid = _formKey.currentState!.validate();
                    print('폼 검증 결과: $isValid');
                    if (isValid) {
                      print('통과했냐?');
                      _formKey.currentState!.save();
                      uploadImages(_images, selectCategory, name, info)
                          .then((_) {
                        // 등록 완료 후 안내 메시지 표시
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('등록 완료'),
                              content: Text('등록이 성공적으로 완료되었습니다.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // 다이얼로그 닫기
                                    Navigator.of(context).pop(); // 이전 화면으로 이동
                                  },
                                  child: Text('확인'),
                                ),
                              ],
                            );
                          },
                        );
                      });
                      // Perform registration logic
                    }
                  },
            child: Text('Register'),
          ),
        ],
      ),
    );
  }
}
