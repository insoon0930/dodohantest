// ignore: avoid_web_libraries_in_flutter
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hanyang_app/data/join_or_login.dart';
import 'package:hanyang_app/screens/forget_pw.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  //데이터 업데이트 위한 클레스
  addAuthData() {
    Map<String, dynamic> data = {
      'auth': 0,
      'email': FirebaseAuth.instance.currentUser.email,
    };

    CollectionReference collectionreference =
    FirebaseFirestore.instance.collection('auth');
    collectionreference.add(data);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            color: Colors.white,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              _logoImage(isJoin: Provider.of<JoinOrLogin>(context).isJoin),
              Stack(
                children: <Widget>[
                  _inputForm(size),
                  _authButton(size),
                ],
              ),
              Container(
                height: size.height * 0.07,
              ),
              Consumer<JoinOrLogin>(
                builder: (context, joinOrLogin, child) => GestureDetector(
                    onTap: () {
                      joinOrLogin.toggle();
                    },
                    child: Text(
                      joinOrLogin.isJoin
                          ? "이미 회원이신가요? 로그인하러 가기"
                          : "계정이 없으신가요? 회원가입하러 가기",
                      style: TextStyle(
                          color: joinOrLogin.isJoin
                              ? Colors.redAccent
                              : Colors.indigo),
                    )),
              ),
              Container(
                height: size.height * 0.05,
              ),
            ],
          )
        ],
      ),
    );
  }

  void _register(BuildContext context) async {
    final UserCredential result = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text);
    final User user = result.user;

    if (user == null) {
      final snackBar = SnackBar(
        content: Text('다시 시도해주세요'),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    }
    //회원가입시, 학생증 인증 위한 데이터 auth 컬렉션에 업로드
    addAuthData();
  }

  void _login(BuildContext context) async {
    final UserCredential result = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text);
    final User user = result.user;

    if (user == null) {
      final snackBar = SnackBar(
        content: Text('다시 시도해주세요'),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  Widget _logoImage({bool isJoin}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 30,
          left: 15,
          right: 15,
        ),
        child: FittedBox(
          fit: BoxFit.contain,
          child: CircleAvatar(
            backgroundColor: isJoin ? Colors.redAccent : Colors.white,
            child: Image.asset('assets/11.-사랑해.png'),
          ),
        ),
      ),
    );
  }

  Widget _inputForm(Size size) {
    return Padding(
      padding: EdgeInsets.all(size.width * 0.05),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 13, right: 13, top: 14, bottom: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      icon: Icon(Icons.account_circle), labelText: '이메일'),
                  validator: (String value) {
                    if (value.isEmpty) {
                      return '알맞은 이메일을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  obscureText: true,
                  controller: _passwordController,
                  decoration: InputDecoration(
                      icon: Icon(Icons.vpn_key), labelText: '비밀번호'),
                  validator: (String value) {
                    if (value.isEmpty) {
                      return '알맞은 비밀번호를 입력해주세요.';
                    }
                    return null;
                  },
                ),
                Container(
                  height: 10,
                ),
                Consumer<JoinOrLogin>(
                  builder: (context, value, child) => Opacity(
                      opacity: value.isJoin ? 0 : 1,
                      child: GestureDetector(
                          onTap: value.isJoin ? null : (){goToForgetPW(context);},
                          child: Text('비밀번호를 잊으셨나요?', style: TextStyle(color: Colors.grey),))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  goToForgetPW(BuildContext context) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ForgetPW()),);
  }

  Widget _authButton(Size size) {
    return Positioned(
      left: size.width * 0.2,
      right: size.width * 0.2,
      bottom: 0,
      child: SizedBox(
        height: 40,
        child: Consumer<JoinOrLogin>(
          builder: (context, joinOrLogin, child) => RaisedButton(
            child: Text(
              joinOrLogin.isJoin ? "회원가입" : '로그인',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            color: joinOrLogin.isJoin ? Colors.redAccent : Colors.indigoAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                joinOrLogin.isJoin ? _register(context) : _login(context);
              }
            },
          ),
        ),
      ),
    );
  }
}
