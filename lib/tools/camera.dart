import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../screens/main_page.dart';


CameraState pageState;

class Camera extends StatefulWidget {
  Camera(int authState);

  @override
  CameraState createState() {
    pageState = CameraState();
    return pageState;
  }
}

class CameraState extends State<Camera> {
  File _image;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User _user;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  String _profileImageURL = "";

  @override
  void initState() {
    super.initState();
    _prepareService();
  }

  void _prepareService() async {
    _user = await _firebaseAuth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // 업로드할 이미지를 출력할 CircleAvatar
        CircleAvatar(
          child: Text('학생증'),
          backgroundImage:
          (_image != null) ? FileImage(_image) : NetworkImage(""),
          radius: 30,
        ),
        // 업로드할 이미지를 선택할 이미지 피커 호출 버튼
        StreamBuilder(
          stream: FirebaseFirestore.instance.collection('auth').snapshots(),
          builder: (context, snapshot) {

            //바뀔 다큐먼트 changeDoc 선언 (null)
            int changeDoc;

            //for문 돌려서 changeDoc 찾음
            for (int i = 0; i < snapshot.data.docs.length; i++) {

              //email 맞는거 찾으면 해당 changeDoc 저장하고 탈출
              if (FirebaseAuth.instance.currentUser.email ==
                  snapshot.data.docs[i].data()['email']) {
                changeDoc = i;
                break;
              }
            }
//            print('바뀐 상태 번호 : $changeDoc');

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  child: Text("겔러리"),
                  onPressed: () {
                    if(authState!=3){
                      //changeDoc 인수로 받음
                      _uploadImageToStorage(ImageSource.gallery, changeDoc);
                    }
                    Scaffold.of(context)
                        .showSnackBar(SnackBar(content: Text('이미 인증되었습니다')));
                    },
                ),
                RaisedButton(
                  child: Text("카메라"),
                  onPressed: () {
                    if(authState!=3){
                      //changeDoc 인수로 받음
                      _uploadImageToStorage(ImageSource.camera, changeDoc);
                    }
                    Scaffold.of(context)
                        .showSnackBar(SnackBar(content: Text('이미 인증되었습니다')));
                  },
                ),
              ],
            );
          }
        ),
      ],
    );
  }

  void _uploadImageToStorage(ImageSource source, changeDoc) async {

    final _picker = ImagePicker();
    final pickedFile = await _picker.getImage(source: source);

    final File image = File(pickedFile.path);

    if (image == null) return;
    setState(() {
      _image = image;
    });

    // 프로필 사진을 업로드할 경로와 파일명을 정의. 사용자의 uid를 이용하여 파일명의 중복 가능성 제거
    StorageReference storageReference =
    _firebaseStorage.ref().child("profile/${FirebaseAuth.instance.currentUser.email}");

    // 파일 업로드
    StorageUploadTask storageUploadTask = storageReference.putFile(_image);

    // 파일 업로드 완료까지 대기
    await storageUploadTask.onComplete;

    //업로드 되면 authState 업데이트 함!
    updateData(changeDoc);

    // 업로드한 사진의 URL 획득
    String downloadURL = await storageReference.getDownloadURL();


    // 업로드된 사진의 URL을 페이지에 반영
    setState(() {
      _profileImageURL = downloadURL;
    });
  }

  //상태를 1로 바꾸는 함수
  updateData(i) async{
    CollectionReference collectionReference = FirebaseFirestore.instance.collection('auth');
    QuerySnapshot querySnapshot = await collectionReference.get();
    querySnapshot.docs[i].reference.update({'auth' : 1});
  }
  
}
