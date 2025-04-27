import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tiktok/pages/home_page.dart';
import 'package:flutter_tiktok/pages/profile_page.dart';
import 'package:flutter_tiktok/pages/theater_page.dart';
import 'package:flutter_tiktok/pages/welfare_page.dart';

final currentIndexProvider = StateProvider<int>((ref) => 0);

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tab Demo',
      themeMode: ThemeMode.dark, // 强制启用深色模式
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        //canvasColor: Colors.black87,
        //cardTheme: CardTheme(color: Colors.grey[900]),
      ),
      theme: ThemeData(
        useMaterial3: true,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: MainTabPage(),
    );
  }
}

// 主页面框架
class MainTabPage extends ConsumerWidget {
  MainTabPage({super.key});

  // 底部导航栏配置
  final List<BottomNavigationBarItem> _bottomItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: '首页',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.theaters),
      label: '剧场',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.card_giftcard),
      label: '福利',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: '我的',
    ),
  ];

  // 页面主体内容
  final List<Widget> _pages = [
    HomePage(),
    TheaterPage(),
    WelfarePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        items: _bottomItems,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => ref.read(currentIndexProvider.notifier).state = index,
      ),
    );
  }
}
