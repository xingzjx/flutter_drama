import 'package:flutter_tiktok/mock/video.dart';
import 'package:flutter_tiktok/style/physics.dart';
import 'package:flutter_tiktok/views/drama_video.dart';
import 'package:flutter_tiktok/views/drama_video_button_column.dart';
import 'package:flutter_tiktok/controller/video_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:safemap/safemap.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<VideoPage> with WidgetsBindingObserver {
  PageController _pageController = PageController();

  VideoListController _videoListController = VideoListController();

  /// 记录点赞
  Map<int, bool> favoriteMap = {};

  List<UserVideo> videoDataList = [];

  late DateTime _initializedTime;
  late DateTime _firstFrameRenderedTime;

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
    videoDataList = UserVideo.fetchDetail();
    WidgetsBinding.instance.addObserver(this);
    _videoListController.init(
      pageController: _pageController,
      initialList: videoDataList
          .map(
            (e) => VPVideoController(
              videoInfo: e,
              builder: () => VideoPlayerController.networkUrl(
                Uri.parse(e.url),
                formatHint: VideoFormat.hls,
              ),
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

    _initializedTime = DateTime.now();

    _videoListController.currentPlayer.controller.addListener((){
      if(_videoListController.currentPlayer.controller.value.isPlaying) {
        _firstFrameRenderedTime = DateTime.now();
        // 计算并打印首帧渲染时间
        Duration firstFrameDuration = _firstFrameRenderedTime.difference(_initializedTime);
        debugPrint('首帧渲染时间: ${firstFrameDuration.inMilliseconds} 毫秒');
        _videoListController.currentPlayer.controller.removeListener(() {});
      }
    });

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
              return DramaVideoPage(
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
