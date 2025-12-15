import 'package:flutter/material.dart';
import '../../utils/library_refresh_notifier.dart';
import '../controllers/library_controller.dart';
import '../models/album.dart';
import '../models/song.dart';
import '../screens/Detail_Album_Screen.dart';
import '../screens/Detail_Artist_Screen.dart';
import '../../utils/user_utils.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final LibraryController controller = LibraryController();
  bool loading = true;
  int tabIndex = 0;
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndData();

    LibraryRefreshNotifier.refresh.addListener(() async {
      if (LibraryRefreshNotifier.refresh.value) {
        await _reloadLibrary();
        LibraryRefreshNotifier.clear();
      }
    });
  }

  @override
  void dispose() {
    LibraryRefreshNotifier.refresh.removeListener(() {});
    super.dispose();
  }

  Future<void> _loadUserIdAndData() async {
    userId = await UserUtils.getUserId();
    if (userId != null) {
      await loadData();
    } else {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> loadData() async {
    if (userId == null) return;
    await controller.loadLibrary(userId!);
    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> _reloadLibrary() async {
    if (userId == null) return;
    if (mounted) {
      setState(() => loading = true);
    }
    await controller.loadLibrary(userId!);
    if (mounted) {
      setState(() => loading = false);
    }
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

  Widget _tabButton({required String label, required int index}) {
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
      if (controller.songs.isNotEmpty) const SizedBox(height: 12),
      if (controller.artists.isNotEmpty)
        _librarySectionTile(
          icon: Icons.person,
          title: "Artists",
          count: controller.artists.length,
          onTap: () => setState(() => tabIndex = 2),
        ),
      if (controller.artists.isNotEmpty) const SizedBox(height: 12),
      if (controller.albums.isNotEmpty)
        _librarySectionTile(
          icon: Icons.album,
          title: "Albums",
          count: controller.albums.length,
          onTap: () => setState(() => tabIndex = 3),
        ),
      if (controller.albums.isNotEmpty) const SizedBox(height: 12),
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
          ? const Text("No liked songs yet",
          style: TextStyle(color: Colors.white70))
          : Text("${controller.songs.length} songs",
          style: const TextStyle(color: Colors.white70)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white70),
      onTap: () {
        setState(() => tabIndex = 1);
      },
    );
  }

  Widget _librarySectionTile({
    required IconData icon,
    required String title,
    required int count,
    required VoidCallback onTap,
  }) {
    final Color iconColor = icon == Icons.person ? Colors.blue : Colors.green;

    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style:
        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        "$count ${title.toLowerCase()}",
        style: const TextStyle(color: Colors.white70),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white70),
      onTap: onTap,
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
      subtitle:
      const Text("Updated recently", style: TextStyle(color: Colors.white70)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white70),
      onTap: () {
        setState(() => tabIndex = 4);
      },
    );
  }

  List<Widget> _buildPlaylists() {
    return [
      const Text("Playlists",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 16),
      ...controller.playlists.map((playlist) {
        return ListTile(
          leading: const Icon(Icons.playlist_play, color: Colors.white),
          title: Text(playlist['name'] as String,
              style: const TextStyle(color: Colors.white)),
          subtitle: Text("${playlist['songCount']} bài",
              style: const TextStyle(color: Colors.white70)),
          trailing: const Icon(Icons.chevron_right, color: Colors.white70),
          onTap: () {
            setState(() => tabIndex = 0);
          },
        );
      }).toList(),
    ];
  }

  List<Widget> _buildArtists() {
    return [
      const Text(
          "Artists",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white
          )
      ),
      const SizedBox(height: 16),
      ...controller.artists.map((artist) {
        String imageUrl = artist.profileImage != null
            ? 'http://10.0.2.2:8080/uploads/${artist.profileImage}'
            : 'https://via.placeholder.com/50';

        return ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
          title: Text(artist.name, style: const TextStyle(color: Colors.white)),
          subtitle: const Text("Artist", style: TextStyle(color: Colors.white70)),
          trailing: const Icon(Icons.chevron_right, color: Colors.white70),
          onTap: () {
            if (userId == null) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ArtistDetailScreen(
                  artist: artist,
                  userId: userId!,
                ),
              ),
            ).then((_) async {
              await _reloadLibrary();  // reload sau khi pop
            });
          },
        );
      }).toList(),
    ];
  }


  List<Widget> _buildAlbums() {
    return [
      const Text(
          "Albums",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white
          )
      ),
      const SizedBox(height: 16),
      ...controller.albums.map((album) {
        String coverUrl = album.coverImage != null
            ? 'http://10.0.2.2:8080/uploads/${album.coverImage}'
            : 'https://via.placeholder.com/50';

        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(coverUrl, width: 50, height: 50),
          ),
          title: Text(album.title, style: const TextStyle(color: Colors.white)),
          subtitle: Text(
            "${album.artist.name} • ${album.releaseYear ?? ''}",
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: Text("${album.songCount} bài",
              style: const TextStyle(color: Colors.white70)),
          onTap: () {
            if (userId == null) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AlbumDetailScreen(
                  album: album,
                  userId: userId!,
                ),
              ),
            ).then((_) async {
              await _reloadLibrary();
            });
          },
        );
      }).toList(),
    ];
  }


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
          title:
          Text("Podcast $index", style: const TextStyle(color: Colors.white)),
          subtitle:
          const Text("Host Name", style: TextStyle(color: Colors.white70)),
          trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        );
      }),
    ];
  }
}
