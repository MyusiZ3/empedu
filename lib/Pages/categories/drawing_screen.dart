import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({Key? key}) : super(key: key);

  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  final List<Map<String, String>> videos = [
    {'id': '2DVbargQCaY', 'title': 'Sketching Anatomy - Part 1'},
    {'id': 'oQm8Df4UYNw', 'title': 'Body Anatomy - Part 2'},
    {'id': '7nNbG3jP7lM', 'title': 'Advanced Perspective - Part 3'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Drawing Lessons',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins-Bold',
            color: Color(0xff7b88ff),
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.arrow_back_ios, // Ikon `<` modern
              color: Color(0xff7b88ff),
            ),
          ),
        ),
      ),
      body: ClipRRect(
        // Membatasi konten agar tidak keluar dari batasan ListView
        borderRadius: BorderRadius.circular(12), // Tambahkan radius opsional
        child: ListView.builder(
          clipBehavior:
              Clip.hardEdge, // Membatasi konten agar tetap di dalam batas
          padding: const EdgeInsets.all(16),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return _buildVideoCard(
                videoId: video['id']!, title: video['title']!);
          },
        ),
      ),
    );
  }

  // Widget untuk Kartu Video
  Widget _buildVideoCard({
    required String videoId,
    required String title,
  }) {
    final YoutubePlayerController thumbnailController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        hideControls: true, // Sembunyikan kontrol video
        mute: true, // Tanpa suara untuk thumbnail
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail Video
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: YoutubePlayer(
              controller: thumbnailController,
              showVideoProgressIndicator: false,
              onReady: () {
                thumbnailController.pause(); // Pastikan video tidak diputar
              },
            ),
          ),
          // Judul dan Tombol Play
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Judul Video
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff7b88ff),
                    ),
                  ),
                ),
                // Tombol Play
                GestureDetector(
                  onTap: () {
                    _playVideoFullScreen(videoId);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xff7b88ff),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk Memutar Video dalam Mode Full-Screen
  void _playVideoFullScreen(String videoId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => YoutubePlayerFullScreenPage(videoId: videoId),
      ),
    );
  }
}

// Halaman Full-Screen untuk Memutar Video
class YoutubePlayerFullScreenPage extends StatelessWidget {
  final String videoId;

  const YoutubePlayerFullScreenPage({Key? key, required this.videoId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final YoutubePlayerController controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true, // Mulai otomatis
        mute: false, // Suara dinyalakan
      ),
    );

    return Scaffold(
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: controller,
          onReady: () {
            print('Video Full-Screen Ready');
          },
        ),
        builder: (context, player) {
          return player; // Tampilkan video player full-screen
        },
      ),
    );
  }
}
