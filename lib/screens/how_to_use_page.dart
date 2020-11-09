import 'package:flutter/material.dart';

class HowToUse extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '사용법',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: Scaffold(
        appBar: AppBar(
            title: Center(child: Text('DuDuHan')),
            actions: <Widget>[
              Opacity(
                  opacity: 0,
                  child: IconButton(icon: Icon(Icons.menu), onPressed: null)),
            ],
            leading: GestureDetector(
              child: Icon(Icons.arrow_back),
              onTap: () async {
                final result = await Navigator.pushNamed(context, '/first');
                print(result);
              },
            )),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 30,
              ),
              Expanded(
                child: Card(
                  color: Colors.indigo[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text.rich(TextSpan(
                          text: '1. ',
                          style: TextStyle(fontSize: 18),
                          children: <TextSpan>[
                            TextSpan(
                              text: '학생증',
                              style: TextStyle(color: Colors.indigo),
                            ),
                            TextSpan(
                              text: '을 업로드 한다',
                            ),
                          ])),
                      Text('(학생증 인증 없이 신청 할 경우 신청 삭제)'),
                      Text('(별도의 인증 완료 통보는 없음)'),
                      Text('(사진이 불분명할 경우 메일로 재업로드 요청)'),
                      Container(
                        height: 50,
                      ),
                      Text.rich(TextSpan(
                          text: '2. ',
                          style: TextStyle(fontSize: 18),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Me',
                              style: TextStyle(color: Colors.indigo),
                            ),
                            TextSpan(
                              text: '와',
                            ),
                            TextSpan(
                              text: 'You',
                              style: TextStyle(color: Colors.indigo),
                            ),
                            TextSpan(
                              text: '의 모든 항목을 작성하고 ',
                            ),
                          ])),
                      Text.rich(TextSpan(
                          text: '',
                          style: TextStyle(fontSize: 18),
                          children: <TextSpan>[
                            TextSpan(
                              text: '신청하기',
                              style: TextStyle(color: Colors.indigo),
                            ),
                            TextSpan(
                              text: '를 누른다',
                            ),
                          ])),
                      Text(
                        '(신청 기간 : 화 ~ 금)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        height: 50,
                      ),
                      Text.rich(TextSpan(
                          text: '3. ',
                          style: TextStyle(fontSize: 18),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Result',
                              style: TextStyle(color: Colors.indigo),
                            ),
                            TextSpan(
                              text: '에서 ',
                            ),
                            TextSpan(
                              text: '매칭 결과',
                              style: TextStyle(color: Colors.indigo),
                            ),
                            TextSpan(
                              text: '를 확인한다',
                            ),
                          ])),
                      Text(
                        '(확인 기간 : 일)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("(일요일 자정, 데이터가 초기화 되기 때문에 이후 확인 불가)"),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: <Widget>[
//                    Text('본 앱은 현 시국에 안전한 CC탄생을 응원합니다.'),
                    Text("'개발자와의 소개팅' 및 각종 문의 사항은"),
                    Text("아래 메일로 부탁드립니다."),
                    Text("dodohanyang@gmail.com"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
