// 福利页组件
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WelfarePage extends StatelessWidget {
  const WelfarePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('福利内容区域',
            style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

