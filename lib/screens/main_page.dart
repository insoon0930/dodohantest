import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:hanyang_app/data/join_or_login.dart';
import 'package:hanyang_app/tools/camera.dart';
import 'result_page.dart';
import 'package:provider/provider.dart';


//두 클래스에서 쓸 수 있게 젤 위에 상태 선언...
int authState;
String authStateText;

//메인 페이지 표현 위한 클래스
class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _kakaoController = TextEditingController();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();
  final TextEditingController _univController = TextEditingController();
  final GlobalKey<FormState> _formKey3 = GlobalKey<FormState>();
  final TextEditingController _majorController = TextEditingController();

  int _selectedIndex = 0;

  List<String> _last = [
    '[]',
    '[]',
    '[]',
    '[]',
    '[]',
    '[]',
    '[]',
    '[]',
    '[]',
    '[]',
    '[]',
    '[]',
    '[]',
    '[]',
    '[]',
    '[]',
    '[]',
    '[]',
    '[]',
  ];

  Map data;

  addData(_last) {
    Map<String, dynamic> demodata = {
      'email': '${FirebaseAuth.instance.currentUser.email}',
      'sex': '${_last[0]}',
      'major': '${_last[1]}',
      'height': '${_last[2]}',
      'age': '${_last[3]}',
      'shape': '${_last[4]}',
      'smoke': '${_last[5]}',
      'drink': '${_last[6]}',
      'religion': '${_last[7]}',
      'kakao': '${_last[8]}',
      'major2': '${_last[9]}',
      'height2up': '${_last[10]}',
      'height2under': '${_last[11]}',
      'age2up': '${_last[12]}',
      'age2under': '${_last[13]}',
      'shape2': '${_last[14]}',
      'smoke2': '${_last[15]}',
      'drink2': '${_last[16]}',
      'religion2': '${_last[17]}',
      'univ': '${_last[18]}',
    };

    CollectionReference collectionreference =
        FirebaseFirestore.instance.collection('info');
    collectionreference.add(demodata);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('info').snapshots(),
        builder: (context, snapshot) {
          //로그인 로딩시, 로딩 화면 제공
          if (!snapshot.hasData)
            return Container(
              color: Colors.white,
              child: Dialog(
                child: new Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    new CircularProgressIndicator(),
                    new Text("Loading"),
                  ],
                ),
              ),
            );
          return Scaffold(
            resizeToAvoidBottomPadding: false,
            drawer: Drawer(
              child: ListView(
                children: <Widget>[
                  DrawerHeader(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child:
                              Text('${FirebaseAuth.instance.currentUser.email}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  )),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.indigoAccent,
                    ),
                  ),
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('로그아웃'),
                    ),
                    onTap: () async{
                      await FirebaseAuth.instance.signOut();
                    },
                  ),
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('회원탈퇴'),
                    ),
                    onTap: () async{
                      await FirebaseAuth.instance.currentUser.delete();
                    },
                  ),
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('이용방법 및 문의'),
                    ),
                    onTap: () async {
                      final result =
                          await Navigator.pushNamed(context, '/second');
                      print(result);
                    },
                  ),
                ],
              ),
            ),
            appBar:
                AppBar(title: Center(child: Text('DuDuHan')), actions: <Widget>[
              Opacity(
                opacity: 0,
                child: IconButton(icon: Icon(Icons.menu), onPressed: null),
              ),
            ]),
            body: IndexedStack(
              index: _selectedIndex,
              children: <Widget>[
                _MePage(size),
                _YouPage(size),
                ResultPage(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              onTap: _onItemTapped,
              currentIndex: _selectedIndex,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), title: Text('Me')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.favorite), title: Text('You')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.check), title: Text('Result')),
              ],
            ),
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Builder(builder: (context) {
                  return FloatingActionButton.extended(
                    onPressed: () async {
                      // 0 > 1로 수정!
                      if ((0 < DateTime.now().weekday) &&
                          (DateTime.now().weekday < 6)) {
                        // 학생증 인증 상태가 3(인증됨)일 때만 통과
                        if(authState==3){
                          //info를 Map형식으로 저장
                          final Map info = {};
                          for (int i = 0;
                          i < await snapshot.data.docs.length;
                          i++) {
                            info['doc' + i.toString()] =
                            await snapshot.data.docs[i].data();
                          }
                          //현재 사용자가 신청한 이메일과 일치하는게 있는지 확인.(중복 신청 방지)
                          int firstTime = 0;
                          for (int i = 0;
                          i < await snapshot.data.docs.length;
                          i++) {
                            if (FirebaseAuth.instance.currentUser.email ==
                                await info['doc$i']['email']) {
                              firstTime++;
                            }
                          }

                          //처음이면 버튼 실행(중복 신청 아니면)
                          if (firstTime == 0) {
                            int full = 0;
                            for (var i = 0; i < _last.length; i++) {
                              _last[i][1] == ']' ? full-- : full++;
                            }
                            if (full == _last.length) {
                              addData(_last);
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text('신청 완료!'),
                              ));
                            } else {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text('Me와 You의 모든 항목을 체크해주세요!'),
                              ));
                            }
                          } else{
                            //처음이 아니면 신청되었다는 스낵바 표시
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text('이미 신청되었습니다!'),
                            ));
                          }
                        } else {
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text("학생증 미인증 상태입니다!"),
                          ));
                        }
                      } else {
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text("신청 기간이 아닙니다!('화~금' 신청 가능)"),
                        ));
                      }
                    },
                    label: Text('신청하기'),
                    backgroundColor: Colors.indigoAccent,
                  );
                }),
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        });
  }

  Widget _MePage(Size size) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          color: Colors.white,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 3),
              child: Camera(authState),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: AuthState(),
            ),
            Expanded(
              flex: 5,
              child: Container(
                width: size.width * 0.9,
                height: size.height * 0.45,
                color: Colors.white,
                child: _ListMe(size),
              ),
            ),
            Container(
              height: size.height * 0.11,
              color: Colors.white,
            ),
          ],
        ),
      ],
    );
  }

  Widget _YouPage(Size size) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          color: Colors.white,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: size.height * 0.06,
              color: Colors.white,
            ),
            Expanded(
              child: Container(
                width: size.width * 0.9,
                height: size.height * 0.65,
                color: Colors.white,
                child: _ListYou(size),
              ),
            ),
            Container(
              height: size.height * 0.11,
              color: Colors.white,
            ),
          ],
        ),
      ],
    );
  }

  Widget _ListMe(Size size) {
    List<String> _checked = [];

    return ListView(
      padding: const EdgeInsets.all(5),
      children: <Widget>[
        ExpansionTile(
          title: Text('학교 ${_last[18]}'),
          children: <Widget>[
            Form(
              key: _formKey2,
              child: Row(
                children: <Widget>[
                  new Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextFormField(
                        controller: _univController,
                        decoration: InputDecoration(
                            icon: Icon(Icons.school),
                            labelText: 'OO대학교 (정식 명칭 입력)'),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return '학교를 입력해주세요!';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  Builder(builder: (context) {
                    return RaisedButton(
                      child: Text(
                        '입력',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      color: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onPressed: () {
                        if (_formKey2.currentState.validate()) {
                          Scaffold.of(context)
                              .showSnackBar(SnackBar(content: Text('입력 완료!')));
                        }
                        _last[18] = '[${_univController.text}]';
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
        ExpansionTile(
            title: Text(
              '학과 ${_last[1]}',
            ),
            children: <Widget>[
              Form(
                key: _formKey3,
                child: Row(
                  children: <Widget>[
                    new Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextFormField(
                          controller: _majorController,
                          decoration: InputDecoration(
                              icon: Icon(Icons.book),
                              labelText: 'OO과 (정식 명칭 입력)'),
                          validator: (String value) {
                            if (value.isEmpty) {
                              return '학과를 입력해주세요!';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Builder(builder: (context) {
                      return RaisedButton(
                        child: Text(
                          '입력',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        color: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onPressed: () {
                          if (_formKey3.currentState.validate()) {
                            Scaffold.of(context)
                                .showSnackBar(SnackBar(content: Text('입력 완료!')));
                          }
                          _last[1] = '[${_majorController.text}]';
                        },
                      );
                    }),
                  ],
                ),
              ),
            ]),
        ExpansionTile(
          title: Text('성별 ${_last[0]}'),
          children: <Widget>[
            CheckboxGroup(
              labels: ['남', '여'],
              onSelected: (List selected) => setState(() {
                if (selected.length > 1) {
                  selected.removeAt(0);
                }
                _checked = selected;
                _last[0] = '$_checked';
              }),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('키 ${_last[2]}'),
          children: <Widget>[
            Container(
              height: 150,
              child: ListView(
                children: <Widget>[
                  CheckboxGroup(
                    labels: _height(),
                    onSelected: (List selected) => setState(() {
                      if (selected.length > 1) {
                        selected.removeAt(0);
                      }
                      _checked = selected;
                      _last[2] = '$_checked';
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('나이 ${_last[3]}'),
          children: <Widget>[
            Container(
              height: 150,
              child: ListView(
                children: <Widget>[
                  CheckboxGroup(
                    labels: _age(),
                    onSelected: (List selected) => setState(() {
                      if (selected.length > 1) {
                        selected.removeAt(0);
                      }
                      List _checked = selected;
                      _last[3] = '$_checked';
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('체형 ${_last[4]}'),
          children: <Widget>[
            Container(
              height: 150,
              child: ListView(
                children: <Widget>[
                  CheckboxGroup(
                    labels: [
                      '마른',
                      '보통',
                      '통통한',
                      '근육있는',
                      '볼륨있는',
                      '글래머한'
                    ],
                    onSelected: (List selected) => setState(() {
                      if (selected.length > 1) {
                        selected.removeAt(0);
                      }
                      _checked = selected;
                      _last[4] = '$_checked';
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('흡연 ${_last[5]}'),
          children: <Widget>[
            CheckboxGroup(
              labels: ['흡연', '비흡연'],
              onSelected: (List selected) => setState(() {
                if (selected.length > 1) {
                  selected.removeAt(0);
                }
                _checked = selected;
                _last[5] = '$_checked';
              }),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('음주 ${_last[6]}'),
          children: <Widget>[
            CheckboxGroup(
              labels: ['전혀안함', '가끔', '자주'],
              onSelected: (List selected) => setState(() {
                if (selected.length > 1) {
                  selected.removeAt(0);
                }
                _checked = selected;
                _last[6] = '$_checked';
              }),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('종교 ${_last[7]}'),
          children: <Widget>[
            Container(
              height: 150,
              child: ListView(
                children: <Widget>[
                  CheckboxGroup(
                    labels: [
                      '무교',
                      '기독교',
                      '불교',
                      '천주교',
                      '기타',
                    ],
                    onSelected: (List selected) => setState(() {
                      if (selected.length > 1) {
                        selected.removeAt(0);
                      }
                      _checked = selected;
                      _last[7] = '$_checked';
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
        ExpansionTile(
            title: Text(
              '카카오톡 ${_last[8]}',
            ),
            children: <Widget>[
              Form(
                key: _formKey,
                child: Row(
                  children: <Widget>[
                    new Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextFormField(
                          controller: _kakaoController,
                          decoration: InputDecoration(
                              icon: Icon(Icons.person),
                              labelText: 'kakao ID (매칭되면 서로 전송)'),
                          validator: (String value) {
                            if (value.isEmpty) {
                              return '카카오톡 아이디를 입력해주세요!';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Builder(builder: (context) {
                      return RaisedButton(
                        child: Text(
                          '입력',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        color: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            Scaffold.of(context)
                                .showSnackBar(SnackBar(content: Text('입력 완료!')));
                          }
                          _last[8] = '[${_kakaoController.text}]';
                        },
                      );
                    }),
                  ],
                ),
              ),
            ]),
      ],
    );
  }

  Widget _ListYou(Size size) {
    List<String> _checked = [];

    return ListView(
      padding: const EdgeInsets.all(5),
      children: <Widget>[
        ExpansionTile(
            title: Text(
              '본인 학과 배제 ${_last[9]}',
            ),
            children: <Widget>[
              Container(
                height: 100,
                child: ListView(
                  children: <Widget>[
                    CheckboxGroup(
                      labels: [
                        '예',
                        '아니오',
                      ],
                      onSelected: (List selected) => setState(() {
                        if (selected.length > 1) {
                          selected.removeAt(0);
                        }
                        _checked = selected;
                        _last[9] = '$_checked';
                        print(_last[9]);
                        if(_last[9]=='[예]') {
                          _last[9] = _last[1];
                        } else {
                          _last[9] = '[상관없음]';
                        }
                      }),
                    ),
                  ],
                ),
              ),
            ]),
        ExpansionTile(
          title: Text('키(이상) ${_last[10]}'),
          children: <Widget>[
            Container(
              height: 150,
              child: ListView(
                children: <Widget>[
                  CheckboxGroup(
                    labels: _height(),
                    onSelected: (List selected) => setState(() {
                      if (selected.length > 1) {
                        selected.removeAt(0);
                      }
                      _checked = selected;
                      _last[10] = '$_checked';
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('키(이하) ${_last[11]}'),
          children: <Widget>[
            Container(
              height: 150,
              child: ListView(
                children: <Widget>[
                  CheckboxGroup(
                    labels: _height(),
                    onSelected: (List selected) => setState(() {
                      if (selected.length > 1) {
                        selected.removeAt(0);
                      }
                      _checked = selected;
                      _last[11] = '$_checked';
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('나이(이상) ${_last[12]}'),
          children: <Widget>[
            Container(
              height: 150,
              child: ListView(
                children: <Widget>[
                  CheckboxGroup(
                    labels: _age(),
                    onSelected: (List selected) => setState(() {
                      if (selected.length > 1) {
                        selected.removeAt(0);
                      }
                      _checked = selected;
                      _last[12] = '$_checked';
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('나이(이하) ${_last[13]}'),
          children: <Widget>[
            Container(
              height: 150,
              child: ListView(
                children: <Widget>[
                  CheckboxGroup(
                    labels: _age(),
                    onSelected: (List selected) => setState(() {
                      if (selected.length > 1) {
                        selected.removeAt(0);
                      }
                      _checked = selected;
                      _last[13] = '$_checked';
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('체형 ${_last[14]}'),
          children: <Widget>[
            Container(
              height: 150,
              child: ListView(
                children: <Widget>[
                  CheckboxGroup(
                    labels: [
                      '상관없음',
                      '마른',
                      '보통',
                      '통통한',
                      '근육있는',
                      '볼륨있는',
                      '글래머한'
                    ],
                    onSelected: (List selected) => setState(() {
                      if (selected.length > 1) {
                        selected.removeAt(0);
                      }
                      _checked = selected;
                      _last[14] = '$_checked';
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('흡연 ${_last[15]}'),
          children: <Widget>[
            CheckboxGroup(
              labels: ['상관없음', '흡연', '비흡연'],
              onSelected: (List selected) => setState(() {
                if (selected.length > 1) {
                  selected.removeAt(0);
                }
                _checked = selected;
                _last[15] = '$_checked';
              }),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('음주 ${_last[16]}'),
          children: <Widget>[
            CheckboxGroup(
              labels: ['상관없음', '전혀안함', '가끔', '자주'],
              onSelected: (List selected) => setState(() {
                if (selected.length > 1) {
                  selected.removeAt(0);
                }
                _checked = selected;
                _last[16] = '$_checked';
              }),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('종교 ${_last[17]}'),
          children: <Widget>[
            Container(
              height: 150,
              child: ListView(
                children: <Widget>[
                  CheckboxGroup(
                    labels: [
                      '상관없음',
                      '무교',
                      '기독교',
                      '불교',
                      '천주교',
                      '기타',
                    ],
                    onSelected: (List selected) => setState(() {
                      if (selected.length > 1) {
                        selected.removeAt(0);
                      }
                      _checked = selected;
                      _last[17] = '$_checked';
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<String> _height() {
    List<String> items = [];
    for (var i = 140; i < 190; i++) {
      items.add('$i');
    }
    return items;
  }

  List<String> _age() {
    List<String> items = [];
    for (var i = 19; i < 35; i++) {
      items.add('$i');
    }
    return items;
  }
  
}


//상태 표현 위한 클래스
class AuthState extends StatefulWidget {
  @override
  _AuthStateState createState() => _AuthStateState();
}

class _AuthStateState extends State<AuthState> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('auth').snapshots(),
        builder: (context, snapshot) {
          //authState 선언 (null), authStateText 선언

          //for문 돌려서 상태 찾음
          for (int i = 0; i < snapshot.data.docs.length; i++) {
            print('포문 실행됨');

            //email 맞는거 찾으면 해당 authState 저장하고 탈출
            if (FirebaseAuth.instance.currentUser.email ==
                snapshot.data.docs[i].data()['email']) {
              authState = snapshot.data.docs[i].data()['auth'];
              break;
            }
          }

          //다 돌렷는데 없으면(인증받고 삭제 당해서) authState 3으로 저장
          if(authState==null) {
            authState = 3;
          }

          //숫자 > 텍스트로 변형
          switch(authState) {
            case 0: { authStateText = '학생증을 업로드 해주세요!'; }
            break;

            case 1: { authStateText = '확인중입니다!'; }
            break;

            case 2: { authStateText = "반려되었습니다. '이름', '학번', '사진'이 식별 가능한지 확인해주세요!"; }
            break;

            case 3: { authStateText = '인증되었습니다!'; }
            break;

//              default: { authState = '학생증을 업로드 해주세요!'; }
//              break;
          }
          return Text(authStateText);
        }
    );
  }
}

