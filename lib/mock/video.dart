import 'dart:io';

Socket? socket;
var videoList = [
  'test-video-10.MP4',
  'test-video-6.mp4',
  'test-video-9.MP4',
  'test-video-8.MP4',
  'test-video-7.MP4',
  'test-video-1.mp4',
  'test-video-2.mp4',
  'test-video-3.mp4',
  'test-video-4.mp4',
];

class UserVideo {
  final String url;
  final String image;
  final String? desc;

  UserVideo({
    required this.url,
    required this.image,
    this.desc,
  });

  static List<UserVideo> fetchVideo() {
    List<UserVideo> list = videoList
        .map((e) => UserVideo(
            image: '', url: 'https://static.ybhospital.net/$e', desc: '$e'))
        .toList();
    return list;
  }

  static List<UserVideo> fetchDetail() {
    List<UserVideo> list = [];
    String dramaId = "1054249334816202752";
    // dramaId = "1048137366459998208";
    // dramaId = "1049469131724251136";
    for (int i = 0; i < 1; i++) {
      var item = UserVideo(
          image: '',
          url: "/sdcard/test/$dramaId/${i + 1}_file_replace.m3u8",
          desc: 'test');
      list.add(item);
    }
    return list;
  }

  @override
  String toString() {
    return 'image:$image' '\nvideo:$url';
  }
}
