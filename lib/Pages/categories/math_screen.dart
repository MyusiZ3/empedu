import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MathScreen extends StatefulWidget {
  const MathScreen({Key? key}) : super(key: key);

  @override
  _MathScreenState createState() => _MathScreenState();
}

class _MathScreenState extends State<MathScreen> {
  final List<Map<String, String>> videos = [
    {'id': 'NybHckSEQBI', 'title': 'Basic Algebra - Introduction'},
    {'id': 'oxhXz9_uyiM', 'title': 'Geometry - Introduction to Angles'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Math Lessons',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins-Bold',
            color: Color(0xFFF2C94C),
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
              Icons.arrow_back_ios,
              color: Color(0xFFF2C94C),
            ),
          ),
        ),
      ),
      body: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListView.builder(
          clipBehavior: Clip.hardEdge,
          padding: const EdgeInsets.all(16),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return _buildVideoCard(
              videoId: video['id']!,
              title: video['title']!,
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoCard({required String videoId, required String title}) {
    final YoutubePlayerController thumbnailController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        hideControls: true,
        mute: true,
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: YoutubePlayer(
              controller: thumbnailController,
              showVideoProgressIndicator: false,
              onReady: () {
                thumbnailController.pause();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF2C94C),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _playVideoFullScreen(videoId);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2C94C),
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

  void _playVideoFullScreen(String videoId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => YoutubePlayerFullScreenPage(videoId: videoId),
      ),
    );
  }
}

class YoutubePlayerFullScreenPage extends StatelessWidget {
  final String videoId;

  const YoutubePlayerFullScreenPage({Key? key, required this.videoId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final YoutubePlayerController controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );

    return Scaffold(
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: controller,
        ),
        builder: (context, player) {
          return player;
        },
      ),
    );
  }
}
