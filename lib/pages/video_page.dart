import 'package:flutter_tiktok/mock/video.dart';
import 'package:flutter_tiktok/style/physics.dart';
import 'package:flutter_tiktok/views/tikTokCommentBottomSheet.dart';
import 'package:flutter_tiktok/views/tikTokScaffold.dart';
import 'package:flutter_tiktok/views/tikTokVideo.dart';
import 'package:flutter_tiktok/views/tikTokVideoButtonColumn.dart';
import 'package:flutter_tiktok/controller/tikTokVideoListController.dart';
import 'package:flutter_tiktok/views/tiktokTabBar.dart';
import 'package:flutter/material.dart';
import 'package:safemap/safemap.dart';
import 'package:video_player/video_player.dart';

/// 单独修改了bottomSheet组件的高度
import 'package:flutter_tiktok/other/bottomSheet.dart' as CustomBottomSheet;

class VideoPage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<VideoPage> with WidgetsBindingObserver {
  TikTokPageTag tabBarType = TikTokPageTag.home;

  TikTokScaffoldController tkController = TikTokScaffoldController();

  PageController _pageController = PageController();

  TikTokVideoListController _videoListController = TikTokVideoListController();

  /// 记录点赞
  Map<int, bool> favoriteMap = {};

  List<UserVideo> videoDataList = [];

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) {
      _videoListController.currentPlayer.pause();
    }
  }

  @override
  void dispose() {
    print("video page dispose=============");
    WidgetsBinding.instance.removeObserver(this);
    _videoListController.currentPlayer.pause();
    _videoListController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    videoDataList = UserVideo.fetchVideo();
    WidgetsBinding.instance.addObserver(this);
    _videoListController.init(
      pageController: _pageController,
      initialList: videoDataList
          .map(
            (e) => VPVideoController(
              videoInfo: e,
              builder: () => VideoPlayerController.networkUrl(Uri.parse(e.url)),
            ),
          )
          .toList(),
      videoProvider: (int index, List<VPVideoController> list) async {
        return videoDataList
            .map(
              (e) => VPVideoController(
                videoInfo: e,
                builder: () =>
                    VideoPlayerController.networkUrl(Uri.parse(e.url)),
              ),
            )
            .toList();
      },
    );
    _videoListController.addListener(() {
      setState(() {});
    });
    tkController.addListener(
      () {
        if (tkController.value == TikTokPagePositon.middle) {
          _videoListController.currentPlayer.play();
        } else {
          _videoListController.currentPlayer.pause();
        }
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget? currentPage;

    double a = MediaQuery.of(context).size.aspectRatio;
    bool hasBottomPadding = a < 0.55;

    // 组合
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            // 左侧组件（默认自动生成返回按钮）
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text("第一集"),
      ),
      body: Stack(
        // index: currentPage == null ? 0 : 1,
        children: <Widget>[
          PageView.builder(
            key: Key('video'),
            physics: QuickerScrollPhysics(),
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _videoListController.videoCount,
            itemBuilder: (context, i) {
              // 拼一个视频组件出来
              bool isF = SafeMap(favoriteMap)[i].boolean;
              var player = _videoListController.playerOfIndex(i)!;
              var data = player.videoInfo!;
              // 右侧按钮列
              Widget buttons = TikTokButtonColumn(
                isFavorite: isF,
                onAvatar: () {
                  tkController.animateToPage(TikTokPagePositon.right);
                },
                onFavorite: () {
                  setState(() {
                    favoriteMap[i] = !isF;
                  });
                  // showAboutDialog(context: context);
                },
                onComment: () {
                  CustomBottomSheet.showModalBottomSheet(
                    backgroundColor: Colors.white.withOpacity(0),
                    context: context,
                    builder: (BuildContext context) =>
                        TikTokCommentBottomSheet(),
                  );
                },
                onShare: () {},
              );
              return TikTokVideoPage(
                // 手势播放与自然播放都会产生暂停按钮状态变化，待处理
                hidePauseIcon: !player.showPauseIcon.value,
                aspectRatio: 9 / 16.0,
                key: Key(data.url + '$i'),
                tag: data.url,
                bottomPadding: hasBottomPadding ? 16.0 : 16.0,
                userInfoWidget: VideoUserInfo(
                  desc: data.desc,
                  bottomPadding: hasBottomPadding ? 16.0 : 50.0,
                ),
                onSingleTap: () async {
                  if (player.controller.value.isPlaying) {
                    await player.pause();
                  } else {
                    await player.play();
                  }
                  setState(() {});
                },
                onAddFavorite: () {
                  setState(() {
                    favoriteMap[i] = true;
                  });
                },
                rightButtonColumn: buttons,
                video: Center(
                  child: AspectRatio(
                    aspectRatio: player.controller.value.aspectRatio,
                    child: VideoPlayer(player.controller),
                  ),
                ),
              );
            },
          ),
          currentPage ?? Container(),
        ],
      ),
    );
  }
}
