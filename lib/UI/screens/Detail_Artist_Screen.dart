import 'package:flutter/material.dart';
import '../../api/song_service.dart';
import '../models/artist.dart';
import '../models/song.dart';
import '../screens/music_player_screen.dart';

class ArtistDetailScreen extends StatelessWidget {
  final Artist artist;

  const ArtistDetailScreen({super.key, required this.artist});

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
        title: const Text('Artist', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Ảnh nghệ sĩ
              AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: NetworkImage(
                        artist.profileImage != null
                            ? 'http://10.0.2.2:8080/uploads/${artist.profileImage}'
                            : 'https://via.placeholder.com/300?text=Artist',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Tên nghệ sĩ
              Text(
                artist.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              const Text(
                'Popular Songs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: FutureBuilder<List<Song>>(
                  future: SongService.fetchSongsByArtist(artist.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, color: Colors.red, size: 48),
                            const SizedBox(height: 10),
                            Text(
                              'Failed to load songs.\n${snapshot.error.toString()}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'This artist has no songs yet.',
                          style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else {
                      final songs = snapshot.data!;
                      return ListView.builder(
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          final song = songs[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: song.coverImage != null
                                ? Image.network(
                              'http://10.0.2.2:8080/uploads/${song.coverImage}',
                              width: 45,
                              height: 45,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const CircleAvatar(child: Icon(Icons.music_note, color: Colors.grey)),
                            )
                                : const CircleAvatar(child: Icon(Icons.music_note, color: Colors.grey)),
                            title: Text(
                              song.title,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              song.artist?.name ?? 'Unknown Artist',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
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