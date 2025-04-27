// 剧场页组件
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tiktok/pages/home_page.dart';

class TheaterPage extends StatelessWidget {
  const TheaterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  GestureDetector(
        onTap: ()=> Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        ),
        child: Center(
          child: Text('剧场内容区域', style: TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}
