import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:hanyang_app/tools/camera.dart';
import 'package:intl/intl.dart';
import 'package:sortedmap/sortedmap.dart';
import 'main_page.dart';

class ResultPage extends StatefulWidget {
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  //뒷 부분에 listView 갯수 변수 전달 위해서 앞에로 뺌
  //학교를 중복 제거한 Set 선언
  //{[한양대], [땡땡대]}
  Set whatUniv = <String>{};

  //listView 에 쓸 학교 리스트 선언
  List whatUnivToList = [];

  String kakao;
  int manNum = 0;
  int womanNum = 0;
  int matchedNum = 0;

  int manNum1 = 0;
  int womanNum1 = 0;
  int manNum2 = 0;
  int womanNum2 = 0;
  int manNum3 = 0;
  int womanNum3 = 0;
  int manNum4 = 0;
  int womanNum4 = 0;
  int manNum5 = 0;
  int womanNum5 = 0;
  int manNum6 = 0;
  int womanNum6 = 0;
  int manNum7 = 0;
  int womanNum7 = 0;
  int manNum8 = 0;
  int womanNum8 = 0;
  int manNum9 = 0;
  int womanNum9 = 0;
  int manNum10 = 0;
  int womanNum10 = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('result').snapshots(),
        builder: (context, snapshot2) {
          return Scaffold(
            resizeToAvoidBottomPadding: false,
            body: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('resultKakao')
                  .snapshots(),
              builder: (context, snapshot3) {
                return StreamBuilder(
                    //스트림할 컬렉션 설정
                    stream: FirebaseFirestore.instance
                        .collection('info')
                        .snapshots(),
                    builder: (context, snapshot) {
                      // result Collection Map 형식으로 저장(뒤에 텍스트 부분에도 쓸꺼라 미리 선언...)
                      final Map result = snapshot2.data.docs[0].data();
                      //다른 Library 들고 와서 Map 을 Key 순으로 정렬
                      //sortedMap = {sfas남: 0, sfas여: 1, 동아대남: 1, 동아대여: 0, 한양대남: 9, 한양대여: 1}
                      var sortedMap = SortedMap(Ordering.byKey());
                      sortedMap.addAll(result);
                      print(sortedMap);

                      // 하는 김에 resultKakao도 선언 ㅇㅅㅇ..?
                      final Map resultKakao = snapshot3.data.docs[0].data();

                      //result 페이지 결과값 표현 위한 Map 형태의 result 값의 key 값 List 선언
                      List sortedKeys = sortedMap.keys.toList();
                      List sortedValues = sortedMap.values.toList();

                      //result Key 부분에서 '남','여' 떼는 for문
                      //univList = [sfas, sfas, 동아대, 동아대, 한양대, 한양대]
                      List univList = [];
                      for (int i = 0; i < sortedKeys.length; i++) {
                        String a = sortedKeys[i];
                        String b = a.substring(0, a.length - 1);
                        univList.add(b);
                      }

                      if ((!snapshot.hasData) || (!snapshot2.hasData))
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
                      return Center(
                        child: Column(children: <Widget>[
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(height: 45),
                                RaisedButton(
                                  color: Colors.indigoAccent,
                                  child: Text(
                                    '결과 확인',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    // 원래 async를 setState에 뒀고 아래 다섯줄을 360번째 줄 쯤 업데이트 하는데 썻는데
                                    // setState() callback argument returned a Future.와 같은 오류 뜸.
                                    // 다음과 같이 setState 밖으로 async와 await 부분을 빼주라해서 수정함
                                    CollectionReference collectionReference =
                                        FirebaseFirestore.instance
                                            .collection('result');
                                    QuerySnapshot querySnapshot =
                                        await collectionReference.get();

                                    //kakao 아이디 업데이트할 resultKakao 컬렉션에 넣을 준비
                                    CollectionReference collectionReference2 =
                                        FirebaseFirestore.instance
                                            .collection('resultKakao');
                                    QuerySnapshot querySnapshot2 =
                                        await collectionReference2.get();

                                    //관리자 아이디로 매칭 결과 업로드 하게 (매칭 알고리즘 모든 계정에서 돌리니 서버 무료 이용량 초과함)
                                    if (FirebaseAuth
                                            .instance.currentUser.email ==
                                        'insoon0930@gmail.com') {
                                      setState(() {
                                        //컬렉션 안의 다큐먼트 동적 변수 선언 (doc1, doc2, doc3, ...)
                                        //매칭 로직 위한 리스트 선언 docs = [doc1, doc2, doc, ...]
                                        final Map info = {};
                                        List<String> docs = List<String>();

                                        List<String> matched = List<String>();
                                        List<String> matchedKakao =
                                            List<String>();

                                        for (int i = 0;
                                            i < snapshot.data.docs.length;
                                            i++) {
                                          info['doc' + i.toString()] =
                                              snapshot.data.docs[i].data();
                                          docs.add('doc$i');
                                        }

                                        //나이(본인, 이상형) string > int 선언
                                        int doc0age(String doc) {
                                          return 10 *
                                                  int.parse(
                                                      info[doc]['age'][1]) +
                                              int.parse(info[doc]['age'][2]);
                                        }

                                        int doc0age2up(String doc) {
                                          return 10 *
                                                  int.parse(
                                                      info[doc]['age2up'][1]) +
                                              int.parse(info[doc]['age2up'][2]);
                                        }

                                        int doc0age2under(String doc) {
                                          return 10 *
                                                  int.parse(info[doc]
                                                      ['age2under'][1]) +
                                              int.parse(
                                                  info[doc]['age2under'][2]);
                                        }

                                        int doc1age(String doc) {
                                          return 10 *
                                                  int.parse(
                                                      info[doc]['age'][1]) +
                                              int.parse(info[doc]['age'][2]);
                                        }

                                        int doc1age2up(String doc) {
                                          return 10 *
                                                  int.parse(
                                                      info[doc]['age2up'][1]) +
                                              int.parse(info[doc]['age2up'][2]);
                                        }

                                        int doc1age2under(String doc) {
                                          return 10 *
                                                  int.parse(info[doc]
                                                      ['age2under'][1]) +
                                              int.parse(
                                                  info[doc]['age2under'][2]);
                                        }

                                        //키(본인, 이상형) string > int 선언
                                        int doc0height(String doc) {
                                          return 100 +
                                              10 *
                                                  int.parse(
                                                      info[doc]['height'][2]) +
                                              int.parse(info[doc]['height'][3]);
                                        }

                                        int doc0height2up(String doc) {
                                          return 100 +
                                              10 *
                                                  int.parse(info[doc]
                                                      ['height2up'][2]) +
                                              int.parse(
                                                  info[doc]['height2up'][3]);
                                        }

                                        int doc0height2under(String doc) {
                                          return 100 +
                                              10 *
                                                  int.parse(info[doc]
                                                      ['height2under'][2]) +
                                              int.parse(
                                                  info[doc]['height2under'][3]);
                                        }

                                        int doc1height(String doc) {
                                          return 100 +
                                              10 *
                                                  int.parse(
                                                      info[doc]['height'][2]) +
                                              int.parse(info[doc]['height'][3]);
                                        }

                                        int doc1height2up(String doc) {
                                          return 100 +
                                              10 *
                                                  int.parse(info[doc]
                                                      ['height2up'][2]) +
                                              int.parse(
                                                  info[doc]['height2up'][3]);
                                        }

                                        int doc1height2under(String doc) {
                                          return 100 +
                                              10 *
                                                  int.parse(info[doc]
                                                      ['height2under'][2]) +
                                              int.parse(
                                                  info[doc]['height2under'][3]);
                                        }

                                        //match 구문
                                        for (int i = 0;
                                            i < docs.length - 1;
                                            i) {
                                          for (int j = i + 1;
                                              j < docs.length;
                                              j++) {
                                            //매치값 제거된 리스트의 원소로 비교하기 위함
                                            String put1 = docs[i];
                                            String put2 = docs[j];
                                            //univ, smoke, shape, drink, religion (==)
                                            if (((info[put1]['univ'] ==
                                                    info[put2]['univ']) &&
                                                (((info[put1]['smoke2'] == info[put2]['smoke']) || (info[put1]['smoke2'] == '[상관없음]')) &&
                                                    ((info[put2]['smoke2'] == info[put1]['smoke']) ||
                                                        (info[put2]['smoke2'] ==
                                                            '[상관없음]'))) &&
                                                (((info[put1]['shape2'] == info[put2]['shape']) || (info[put1]['shape2'] == '[상관없음]')) &&
                                                    ((info[put2]['shape2'] == info[put1]['shape']) ||
                                                        (info[put2]['shape2'] ==
                                                            '[상관없음]'))) &&
                                                (((info[put1]['drink2'] == info[put2]['drink']) || (info[put1]['drink2'] == '[상관없음]')) &&
                                                    ((info[put2]['drink2'] == info[put1]['drink']) ||
                                                        (info[put2]['drink2'] ==
                                                            '[상관없음]'))) &&
                                                (((info[put1]['religion2'] == info[put2]['religion']) || (info[put1]['religion2'] == '[상관없음]')) &&
                                                    ((info[put2]['religion2'] ==
                                                            info[put1]
                                                                ['religion']) ||
                                                        (info[put2]['religion2'] ==
                                                            '[상관없음]'))) &&
                                                //major (!=)
                                                (((info[put1]['major2'] != info[put2]['major']) || (info[put1]['major2'] == '[상관없음]')) &&
                                                    ((info[put2]['major2'] !=
                                                            info[put1]['major']) ||
                                                        (info[put2]['major2'] == '[상관없음]'))) &&
                                                //sex (!=)
                                                (info[put1]['sex'] != info[put2]['sex']) &&
                                                //age, height (&&, <)
                                                (((doc0age2up(put1) <= doc1age(put2)) && (doc1age(put2) <= doc0age2under(put1))) && ((doc1age2up(put2) <= doc0age(put1)) && (doc0age(put1) <= doc1age2under(put2)))) &&
                                                (((doc0height2up(put1) <= doc1height(put2)) && (doc1height(put2) <= doc0height2under(put1))) && ((doc1height2up(put2) <= doc0height(put1)) && (doc0height(put1) <= doc1height2under(put2)))))) {
                                              //리스트에서 매칭된 원소 제거
                                              docs.remove(put1);
                                              docs.remove(put2);
                                              //확인력, email(본인 매칭 확인 위함), kakao(매칭시 상대방에게 제공 위함) 리스트화
                                              print('$put1 x $put2 매치됨');
                                              matched.add(info[put1]['email']);
                                              matched.add(info[put2]['email']);
                                              matchedKakao
                                                  .add(info[put1]['kakao']);
                                              matchedKakao
                                                  .add(info[put2]['kakao']);
                                              print(docs);
                                              //for문에서 i++이 아니라 i이기 때문에 새로운 리스트로 처음부터 비교 연산
                                              break;
                                            }
                                            //매치 안됐을 시
                                            else {
                                              print('$put1 x $put2 매치안됨');
                                              //j가 끝까지 돌았을 때, i++
                                              if (j == docs.length - 1) {
                                                print('한바퀴 끝');
                                                i++;
                                              }
                                            }
                                          }
                                        }
                                        matchedNum = matched.length;

                                        //matched = [aaa123@gmail.com, ggg123@gmail.com, eee123@gmail.com, hhh123@gmail.com, iii123@naver.com, sdafasdf@gmail.com]
                                        //matchedKakao = [aasdfafds, asdfas, asdfas, aasdfafds, sadfasdf, aasdfafds]
                                        //로그인 된 이메일로 비교해서 매칭 되었는지 확인.
                                        print(matched);
                                        for (int i = 0;
                                            i < matched.length;
                                            i++) {
                                          if (FirebaseAuth
                                                  .instance.currentUser.email ==
                                              matched[i]) {
                                            print('matched!!!');
                                            //상대방 카카오아이디 출력
                                            if (i % 2 == 0) {
                                              kakao = matchedKakao[i + 1];
                                              print(kakao);
                                            } else {
                                              kakao = matchedKakao[i - 1];
                                              print(kakao);
                                            }
                                            break;
                                          } else {
                                            if (i == matched.length - 1) {
                                              print('not matched...');
                                              kakao = '매치되지 않았습니다';
                                            }
                                          }
                                        }

                                        //남여 수 계산
                                        manNum = 0;
                                        womanNum = 0;
                                        for (int i = 0;
                                            i < snapshot.data.docs.length;
                                            i++) {
                                          if (info['doc$i']['sex'] == '[남]') {
                                            manNum++;
                                          } else {
                                            womanNum++;
                                          }
                                        }
                                        print(manNum);
                                        print(womanNum);

//                                  //학교를 중복 제거한 Set 선언, (앞으로 뺌)
//                                  //{[한양대], [땡땡대]}
//                                  Set whatUniv = <String>{};

                                        //신청서 당 '학교,성'을 묶어서 List 선언
                                        //[[[한양대], [여]], [[한양대], [남]], [[한양대], [남]], [[땡땡대], [여]], [[한양대], [남]], [[한양대], [남]]]
                                        List univSex = [];

                                        //whatUniv, univSex 동적으로 표현
                                        for (int i = 0;
                                            i < snapshot.data.docs.length;
                                            i++) {
                                          //whatUniv 동적으로 선언
                                          //[]괄호 떼서 넣어줘야 데이터 업로드 가능해서 그 작업도 해줌
                                          int theLength =
                                              info['doc$i']['univ'].length;
                                          String theUniv = info['doc$i']['univ']
                                              .substring(1, theLength - 1);

                                          whatUniv.add(theUniv);
                                          //univSex 동적으로 선언
                                          List a = [
                                            '$theUniv',
                                            '${info['doc$i']['sex']}'
                                          ];
                                          univSex.add(a);
                                        }

                                        //Set를 활용하기 위해 List로 선언
                                        //[한양대, 땡땡대]
                                        whatUnivToList = [...whatUniv];
                                        print(whatUniv);
                                        print(whatUnivToList);
                                        print(whatUnivToList[0]);

                                        //일단 학교수 두배를 원소로 다지는 리스트 선언(모든 원소는 int 0)
                                        //[0, 0, 0, 0]
                                        List countSex = [];
                                        for (int i = 0;
                                            i < 2 * (whatUnivToList.length);
                                            i++) {
                                          countSex.add(0);
                                        }

                                        //학교 별 남 녀 카운트
                                        for (int i = 0;
                                            i < whatUnivToList.length;
                                            i++) {
                                          for (int j = 0;
                                              j < univSex.length;
                                              j++) {
                                            if ('[${whatUnivToList[i]}, [남]]' ==
                                                univSex[j].toString()) {
                                              countSex[2 * i]++;
                                            } else if ('[${whatUnivToList[i]}, [여]]' ==
                                                univSex[j].toString()) {
                                              countSex[(2 * i) + 1]++;
                                            }
                                          }
                                        }

                                        print(countSex);

                                        //map 화 (뒤에 ListView.builder에 길이로 쓰기 위해서 밖으로 빼줌)
                                        //resultMap = {[한양대]남: 4, [한양대]여: 1, [땡땡대]남: 0, [땡땡대]여: 1}
                                        Map<String, dynamic> resultMap = {};

                                        print(whatUnivToList.length);
                                        print(univSex.length);

                                        //아 키가 같으면 위에 덮히는구나
                                        //학교별 남 여 구분해서 Map 으로 저장
                                        //resultMap = {[한양대]남: 4, [한양대]여: 1, [땡땡대]남: 0, [땡땡대]여: 1}
                                        for (int i = 0;
                                            i < whatUnivToList.length;
                                            i++) {
                                          resultMap.addAll({
                                            '${whatUnivToList[i]}남':
                                                '${countSex[2 * i]}',
                                            '${whatUnivToList[i]}여':
                                                '${countSex[2 * i + 1]}'
                                          });
                                        }

                                        print(resultMap);
                                        print(matchedKakao);

                                        Map<String, dynamic> resultKakao = {
                                          'kakao': matchedKakao
                                        };

                                        print(resultKakao);

                                        //result 콜렉션에 데이터 업데이트
                                        querySnapshot.docs[0].reference
                                            .update(resultMap);

                                        //resultKakao 콜렉션에 데이터 업데이트
                                        querySnapshot2.docs[0].reference
                                            .update(resultKakao);
                                      });
                                    } else {
                                      // ==7 인데 실험상 < 0
                                      if (0 < DateTime.now().weekday) {
                                        setState(() {
                                          //로그인 된 이메일로 비교해서 매칭 되었는지 확인.
                                          for (int i = 0;
                                              i < resultKakao['kakao'].length;
                                              i++) {
                                            if (FirebaseAuth.instance
                                                    .currentUser.email ==
                                                resultKakao['kakao'][i]) {
                                              print('matched!!!');
                                              //상대방 카카오아이디 출력
                                              if (i % 2 == 0) {
                                                kakao =
                                                    resultKakao['kakao'][i + 1];
                                                print(kakao);
                                              } else {
                                                kakao =
                                                    resultKakao['kakao'][i - 1];
                                                print(kakao);
                                              }
                                              break;
                                            } else {
                                              print('굴러간다잉@@@@@@@@@@@@@@');

                                              if (i ==
                                                  resultKakao['kakao'].length -
                                                      1) {
//                                                showDialog(
//                                                  context: context,
//                                                  barrierDismissible: false,
//                                                  builder: (_) => AlertDialog(
//                                                    title:
//                                                    Text('AlertDialog Demo'),
//                                                    content: Text(
//                                                        "Select button you want"),
//                                                    actions: <Widget>[
//                                                      FlatButton(
//                                                        child: Text('OK'),
//                                                        onPressed: () {
//                                                          Navigator.pop(
//                                                              context, "OK");
//                                                        },
//                                                      ),
//                                                      FlatButton(
//                                                        child: Text('Cancel'),
//                                                        onPressed: () {
//                                                          Navigator.pop(
//                                                              context, "Cancel");
//                                                        },
//                                                      ),
//                                                    ],
//                                                  ),
//                                                );
                                                whatthefuck(kakao);

                                                print('not matched...');
                                                kakao = '매치되지 않았습니다';
                                              }
                                            }
                                          }
                                        });
                                      } else {
                                        Scaffold.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text('일요일만 확인 가능합니다!'),
                                        ));
                                      }
                                    }
                                  },
                                ),
                                Container(
                                  height: 15,
                                ),
//                          Text('성비 : ${result['sexRatio']}'),
//                          Text('매칭 성공 수 : ${result['matched'].length}'),
                              ],
                            ),
                          ),
                          const Divider(
                            color: Colors.indigo,
                            thickness: 0.5,
                            indent: 25,
                            endIndent: 25,
                          ),
                          Container(
                            height: 250,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(8),
                              itemCount: ((sortedKeys.length) / 2).round(),
                              itemBuilder: (BuildContext context, int index) {
                                //일요일에만 세부 결과 공개(result)
                                if (7 == DateTime.now().weekday)
                                  return Column(
                                    children: <Widget>[
                                      Center(
                                          child: Text(
                                              '${univList[2 * index]} 신청 수 : ${int.parse(sortedValues[2 * index]) + int.parse(sortedValues[2 * index + 1])}')),
                                      Center(
                                          child: Text(
                                              '성비 : ${(int.parse(sortedValues[2 * index]) / int.parse(sortedValues[2 * index + 1])).toStringAsFixed(3)}')),
                                    ],
                                  );
                                return Container(
                                  height: 250,
                                  child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text('신청 인원'),
                                      Container(height: 10),
                                      Text('${snapshot.data.docs.length}', style: TextStyle(color: Colors.indigoAccent, fontSize: 30)),
                                      Container(height: 30),

                                    ],
                                  )),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      const Divider(
                                thickness: 0.5,
                                indent: 25,
                                endIndent: 25,
                              ),
                            ),
                          ),
                          const Divider(
                            color: Colors.indigo,
                            thickness: 0.5,
                            indent: 25,
                            endIndent: 25,
                          ),
                          Container(
                            height: 20,
                          ),
                          Container(
                            height: 70,
                          ),
                        ]),
                      );
                    });
              },
            ),
          );
        });
  }

  void whatthefuck(kakao) {
    showDialog(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text(kakao)),
        );
      },
    );
  }
}
