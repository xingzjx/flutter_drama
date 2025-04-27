import 'package:flutter_tiktok/mock/video.dart';
import 'package:flutter_tiktok/style/physics.dart';
import 'package:flutter_tiktok/views/drama_video.dart';
import 'package:flutter_tiktok/views/drama_video_button_column.dart';
import 'package:flutter_tiktok/controller/video_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:safemap/safemap.dart';
import 'package:video_player/video_player.dart';

/// 单独修改了bottomSheet组件的高度
import 'package:visibility_detector/visibility_detector.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  PageController _pageController = PageController();

  VideoListController _videoListController = VideoListController();

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
    WidgetsBinding.instance.removeObserver(this);
    _videoListController.currentPlayer.pause();
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

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget? currentPage;
    double a = MediaQuery.of(context).size.aspectRatio;
    bool hasBottomPadding = a < 0.55;

    // 组合
    return VisibilityDetector(
        key: Key("home_page"),
        child: Stack(
          // index: currentPage == null ? 0 : 1,
          children: <Widget>[
            PageView.builder(
              key: Key('home'),
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
                Widget buttons = DramaButtonColumn(
                  isFavorite: isF,
                  onFavorite: () {
                    setState(() {
                      favoriteMap[i] = !isF;
                    });
                    // showAboutDialog(context: context);
                  },
                  onShare: () {},
                );
                // video
                Widget currentVideo = Center(
                  child: AspectRatio(
                    aspectRatio: player.controller.value.aspectRatio,
                    child: VideoPlayer(player.controller),
                  ),
                );

                currentVideo = DramaVideoPage(
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
                  video: currentVideo,
                );
                return currentVideo;
              },
            ),
            currentPage ?? Container(),
          ],
        ),
        onVisibilityChanged: (visibilityInfo) {
          var visiblePercentage = visibilityInfo.visibleFraction * 100;
          if (visiblePercentage == 100.0) {
            _videoListController.currentPlayer.play();
          } else {
            _videoListController.currentPlayer.pause();
          }
        });
  }
}
