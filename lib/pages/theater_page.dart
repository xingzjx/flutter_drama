// 剧场页组件
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TheaterPage extends StatelessWidget {
  const TheaterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('剧场内容区域',
            style: TextStyle(fontSize: 24)),
      ),
    );
  }
}