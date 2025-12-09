import 'package:flutter/material.dart';
import '../controllers/library_controller.dart';
import '../models/album.dart';
import '../models/song.dart';
import '../screens/Detail_Album_Screen.dart';
import '../screens/Detail_Artist_Screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final LibraryController controller = LibraryController();
  bool loading = true;
  int tabIndex = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await controller.loadLibrary(1);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── TABS NGANG (cuộn được nếu cần) ───
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _tabButton(label: "All", index: 0),
                    const SizedBox(width: 8),
                    _tabButton(label: "Playlists", index: 1),
                    const SizedBox(width: 8),
                    _tabButton(label: "Artists", index: 2),
                    const SizedBox(width: 8),
                    _tabButton(label: "Albums", index: 3),
                    const SizedBox(width: 8),
                    _tabButton(label: "Podcasts", index: 4),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ─── NỘI DUNG THEO TAB ───
              Expanded(
                child: ListView(
                  children: [
                    if (tabIndex == 0) ..._buildDefaultView(),
                    if (tabIndex == 1) ..._buildPlaylists(),
                    if (tabIndex == 2) ..._buildArtists(),
                    if (tabIndex == 3) ..._buildAlbums(),
                    if (tabIndex == 4) ..._buildPodcasts(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabButton({
    required String label,
    required int index,
  }) {
    return GestureDetector(
      onTap: () => setState(() => tabIndex = index),
      child: Container(
        decoration: BoxDecoration(
          color: tabIndex == index ? Colors.white : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: tabIndex == index ? Colors.green : Colors.grey.shade700,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            color: tabIndex == index ? Colors.black : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ─── MÀN HÌNH MẶC ĐỊNH: All ───
  List<Widget> _buildDefaultView() {
    return [
      const Text(
        "Your Library",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 16),
      _likedSongsTile(),
      const SizedBox(height: 12),
      _newEpisodesTile(),
    ];
  }

  Widget _likedSongsTile() {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.favorite, color: Colors.red),
      ),
      title: const Text(
        "Liked Songs",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: controller.songs.isEmpty
          ? const Text("No liked songs yet", style: TextStyle(color: Colors.white70))
          : Text("${controller.songs.length} songs", style: const TextStyle(color: Colors.white70)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white70),
      onTap: () {
        setState(() => tabIndex = 1);
      },
    );
  }

  Widget _newEpisodesTile() {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.notifications, color: Colors.green),
      ),
      title: const Text(
        "New Episodes",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: const Text("Updated recently", style: TextStyle(color: Colors.white70)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white70),
      onTap: () {
        setState(() => tabIndex = 4);
      },
    );
  }

  // ─── PLAYLISTS ───
  List<Widget> _buildPlaylists() {
    return [
      const Text("Playlists", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 16),
      ...controller.playlists.map((playlist) {
        return ListTile(
          leading: const Icon(Icons.playlist_play, color: Colors.white),
          title: Text(playlist['name'] as String, style: const TextStyle(color: Colors.white)),
          subtitle: Text("${playlist['songCount']} bài", style: const TextStyle(color: Colors.white70)),
          trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        );
      }).toList(),
    ];
  }

  // ─── ARTISTS ───
  List<Widget> _buildArtists() {
    return [
      const Text("Artists", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 16),
      ...controller.artists.map((artist) {
        String imageUrl = artist.profileImage != null
            ? 'http://10.0.2.2:8080/uploads/${artist.profileImage}'
            : 'https://via.placeholder.com/50';
        return ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
          title: Text(artist.name, style: const TextStyle(color: Colors.white)),
          subtitle: const Text("Artist", style: const TextStyle(color: Colors.white70)),
          trailing: const Icon(Icons.chevron_right, color: Colors.white70),
          onTap: () async {
            try {
              final fullArtist = await controller.fetchArtistDetail(artist.id);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => ArtistDetailScreen(artist: fullArtist)),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lỗi tải nghệ sĩ: $e')),
              );
            }
          },
        );
      }).toList(),
    ];
  }

  // ─── ALBUMS ───
  List<Widget> _buildAlbums() {
    return [
      const Text("Albums", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 16),
      ...controller.albums.map((album) {
        String coverUrl = album.coverImage != null
            ? 'http://10.0.2.2:8080/uploads/${album.coverImage}'
            : 'https://via.placeholder.com/50';
        return ListTile(
          leading: SizedBox(
            width: 50,
            height: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.album, color: Colors.grey);
                },
              ),
            ),
          ),
          title: Text(album.title, style: const TextStyle(color: Colors.white)),
          subtitle: Text(
            "${album.artist.name} • ${album.releaseYear ?? ''}",
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: Text("${album.songCount} bài", style: const TextStyle(color: Colors.white70)),
          onTap: () async {
            try {
              final fullAlbum = await controller.fetchAlbumDetail(album.id);

              // Tạo bản sao an toàn nếu songs bị null
              final safeAlbum = Album(
                id: fullAlbum.id,
                title: fullAlbum.title,
                coverImage: fullAlbum.coverImage,
                releaseYear: fullAlbum.releaseYear,
                songCount: fullAlbum.songs?.length ?? 0,
                artist: fullAlbum.artist,
                songs: fullAlbum.songs ?? [],
              );

              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => AlbumDetailScreen(album: safeAlbum)),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lỗi tải album: $e')),
              );
            }
          },
        );
      }).toList(),
    ];
  }

  // ─── PODCASTS ───
  List<Widget> _buildPodcasts() {
    return [
      const Text(
        "Podcasts",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 16),
      ...List.generate(4, (index) {
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.mic, color: Colors.orange),
          ),
          title: Text("Podcast $index", style: const TextStyle(color: Colors.white)),
          subtitle: const Text("Host Name", style: TextStyle(color: Colors.white70)),
          trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        );
      }),
    ];
  }
}