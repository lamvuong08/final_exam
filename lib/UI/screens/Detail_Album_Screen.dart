import 'package:flutter/material.dart';
import '../../api/album_service.dart';
import '../models/album.dart';
import '../models/song.dart';
import '../screens/music_player_screen.dart';

class AlbumDetailScreen extends StatelessWidget {
  final Album album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(album.title, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Ảnh bìa
              AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: NetworkImage(
                        album.coverImage != null
                            ? 'http://10.0.2.2:8080/uploads/${album.coverImage}'
                            : 'https://via.placeholder.com/300?text=Album',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Tên album
              Text(
                album.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),

              // Thông tin
              Text(
                [
                  album.artist.name,
                  if (album.releaseYear != null) '${album.releaseYear}',
                  '${album.songCount} bài',
                ].where((e) => e.isNotEmpty).join(' • '),
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Nút Play toàn bộ (chạy bài đầu tiên sau khi load)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    backgroundColor: Colors.green,
                    onPressed: () async {
                      try {
                        final songs = await AlbumService.fetchSongsByAlbum(album.id);
                        if (songs.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MusicPlayerScreen(song: songs.first),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Không thể tải danh sách bài hát')),
                        );
                      }
                    },
                    child: const Icon(Icons.play_arrow, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tiêu đề
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Songs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 400,
                child: FutureBuilder<List<Song>>(
                  future: AlbumService.fetchSongsByAlbum(album.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, color: Colors.red, size: 48),
                            const SizedBox(height: 8),
                            Text(
                              'Load failed: ${snapshot.error.toString()}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'This album has no songs.',
                          style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                        ),
                      );
                    } else {
                      final songs = snapshot.data!;
                      return ListView.builder(
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          final song = songs[index];
                          return ListTile(
                            leading: Text(
                              '${index + 1}.',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            title: Text(
                              song.title,
                              style: const TextStyle(color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              song.artist?.name ?? 'Unknown Artist',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MusicPlayerScreen(song: song),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}