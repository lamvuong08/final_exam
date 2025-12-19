import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/song.dart';
import '../screens/music_player_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
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
    try {
      final res = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/music/trending'),
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          _trendingSongs = data.map((e) => Song.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi tải danh sách bài hát')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.white),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBanner(),
            const SizedBox(height: 30),

            // ====== THỊNH HÀNH ======
            const Text(
              'Thịnh hành',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),

            ListView.builder(
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
    );
  }

  // ====== BANNER ======
  Widget _buildBanner() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.music_note,
              size: 140,
              color: Colors.white.withAlpha(40),
            ),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Nghe nhạc mới nhất\nTop Hit 2024',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ====== ITEM BÀI HÁT ======
  Widget _buildSongItem(Song song, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            'http://10.0.2.2:8080/uploads/${song.coverImage ?? ''}',
            width: 55,
            height: 55,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 55,
              height: 55,
              color: Colors.deepPurple.withAlpha(40),
              child: const Icon(Icons.music_note, color: Colors.white),
            ),
          ),
        ),
        title: Text(
          song.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.artist?.name ?? 'Nghệ sĩ ẩn danh',
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: const Icon(Icons.more_vert, color: Colors.white54),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MusicPlayerScreen(
                initialSong: song,
                playlist: _trendingSongs,
                startIndex: index,
                userId: widget.userId,
              ),
            ),
          );
        },
      ),
    );
  }
}