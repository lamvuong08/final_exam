import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/song.dart';
import '../screens/music_player_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId; // Bắt buộc
  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Song> _trendingSongs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrendingSongs();
  }

  Future<void> _loadTrendingSongs() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/music/trending'),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Song> songs = data.map((e) => Song.fromJson(e)).toList();
        if (!mounted) return;
        setState(() {
          _trendingSongs = songs;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load trending songs');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải bài hát: $e')),
        );
      }
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleNewMusicPressed() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/music/new-music'),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.body)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải nhạc mới')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể kết nối backend')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurple, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(
                        Icons.music_note,
                        size: 150,
                        color: Colors.deepPurple.withAlpha(51),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Nghe nhạc mới nhất',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Top Hit 2024 đang chờ bạn!',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _handleNewMusicPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('Nghe ngay'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Trending Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Thịnh hành',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Xem tất cả',
                        style: TextStyle(color: Colors.white70)),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _trendingSongs.length,
                itemBuilder: (context, index) {
                  final song = _trendingSongs[index];
                  return _buildSongItem(song, index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSongItem(Song song, int index) {
    String imageUrl = 'http://10.0.2.2:8080/uploads/${song.coverImage ?? ''}';

    Widget imageWidget = song.coverImage != null && song.coverImage!.isNotEmpty
        ? Image.network(
      imageUrl,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.music_note, color: Colors.white),
        );
      },
    )
        : Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.music_note, color: Colors.white),
    );

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MusicPlayerScreen(
              initialSong: song,
              playlist: _trendingSongs,
              startIndex: index,
              userId: widget.userId,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageWidget,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist?.name ?? 'Nghệ sĩ ẩn danh',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white70),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
