import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/library_refresh_notifier.dart';
import '../../utils/user_utils.dart';
import '../controllers/library_controller.dart';
import 'detail_album_screen.dart';
import 'detail_artist_screen.dart';
import 'music_player_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool showLikedSongsAsPlaylist = false;
  bool loading = true;
  int tabIndex = 0;
  int? userId;

  late final VoidCallback refreshListener;

  @override
  void initState() {
    super.initState();
    loadUserIdAndData();

    refreshListener = () async {
      if (LibraryRefreshNotifier.refresh.value) {
        await reloadLibrary();
        LibraryRefreshNotifier.clear();
      }
    };

    LibraryRefreshNotifier.refresh.addListener(refreshListener);
  }

  @override
  void dispose() {
    LibraryRefreshNotifier.refresh.removeListener(refreshListener);
    super.dispose();
  }

  Future<void> loadUserIdAndData() async {
    final controller = Provider.of<LibraryController>(context, listen: false);
    final fetchedUserId = await UserUtils.getUserId();

    if (mounted && fetchedUserId != null) {
      userId = fetchedUserId;
      await controller.loadLibrary(userId!);
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> reloadLibrary() async {
    if (userId == null) return;

    if (mounted) {
      setState(() => loading = true);
    }

    final controller = Provider.of<LibraryController>(context, listen: false);
    await controller.loadLibrary(userId!);

    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<LibraryController>(context);

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
                    tabButton("All", 0),
                    const SizedBox(width: 8),
                    tabButton("Playlists", 1),
                    const SizedBox(width: 8),
                    tabButton("Artists", 2),
                    const SizedBox(width: 8),
                    tabButton("Albums", 3),
                    const SizedBox(width: 8),
                    tabButton("Podcasts", 4),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    if (tabIndex == 0) ...buildDefaultView(controller),
                    if (tabIndex == 1) ...buildPlaylists(controller),
                    if (tabIndex == 2) ...buildArtists(controller),
                    if (tabIndex == 3) ...buildAlbums(controller),
                    if (tabIndex == 4) ...buildPodcasts(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tabButton(String label, int index) {
    final selected = tabIndex == index;

    return GestureDetector(
      onTap: () => setState(() => tabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? Colors.green : Colors.grey.shade700,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  List<Widget> buildDefaultView(LibraryController controller) {
    return [
      const Text(
        "Your Library",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      const SizedBox(height: 16),
      likedSongsTile(controller),
      if (controller.artists.isNotEmpty) const SizedBox(height: 12),
      if (controller.artists.isNotEmpty)
        librarySectionTile(
          icon: Icons.person,
          title: "Artists",
          count: controller.artists.length,
          onTap: () => setState(() => tabIndex = 2),
        ),
      if (controller.albums.isNotEmpty) const SizedBox(height: 12),
      if (controller.albums.isNotEmpty)
        librarySectionTile(
          icon: Icons.album,
          title: "Albums",
          count: controller.albums.length,
          onTap: () => setState(() => tabIndex = 3),
        ),
      const SizedBox(height: 12),
      newEpisodesTile(),
    ];
  }

  Widget likedSongsTile(LibraryController controller) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.purple.withAlpha(77),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.favorite, color: Colors.red),
      ),
      title: const Text("Liked Songs",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(
        controller.likedSongs.isEmpty
            ? "No liked songs yet"
            : "${controller.likedSongs.length} songs",
        style: const TextStyle(color: Colors.white70),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white70),
      onTap: () {
        setState(() {
          tabIndex = 1;
          showLikedSongsAsPlaylist = true;
        });
      },
    );
  }

  Widget librarySectionTile({
    required IconData icon,
    required String title,
    required int count,
    required VoidCallback onTap,
  }) {
    final color = icon == Icons.person ? Colors.blue : Colors.green;

    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withAlpha(77),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text("$count ${title.toLowerCase()}",
          style: const TextStyle(color: Colors.white70)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white70),
      onTap: onTap,
    );
  }

  Widget newEpisodesTile() {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.green.withAlpha(77),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.notifications, color: Colors.green),
      ),
      title: const Text("New Episodes",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle:
      const Text("Updated recently", style: TextStyle(color: Colors.white70)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white70),
      onTap: () => setState(() => tabIndex = 4),
    );
  }

  List<Widget> buildPlaylists(LibraryController controller) {
    if (showLikedSongsAsPlaylist) {
      return [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => setState(() => showLikedSongsAsPlaylist = false),
            ),
            const Text(
              "Liked Songs",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...controller.likedSongs.map((song) {
          return ListTile(
            leading: const Icon(Icons.music_note, color: Colors.white),
            title: Text(song.title, style: const TextStyle(color: Colors.white)),
            subtitle: Text(song.artist?.name ?? "Nghệ sĩ ẩn danh",
                style: const TextStyle(color: Colors.white70)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MusicPlayerScreen(
                    initialSong: song,
                    playlist: controller.likedSongs,
                    startIndex: controller.likedSongs.indexOf(song),
                    userId: userId!,
                  ),
                ),
              );
            },
          );
        })
      ];
    }

    return [
      const Text("Playlists",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 16),
      ListTile(
        leading: const Icon(Icons.favorite, color: Colors.red),
        title: const Text("Liked Songs", style: TextStyle(color: Colors.white)),
        subtitle: Text("${controller.likedSongs.length} bài",
            style: const TextStyle(color: Colors.white70)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        onTap: () => setState(() => showLikedSongsAsPlaylist = true),
      ),
    ];
  }

  List<Widget> buildArtists(LibraryController controller) {
    return controller.artists.map((artist) {
      final imageUrl = artist.profileImage != null
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
              builder: (_) => ArtistDetailScreen(artist: artist, userId: userId!),
            ),
          );
        },
      );
    }).toList();
  }

  List<Widget> buildAlbums(LibraryController controller) {
    return controller.albums.map((album) {
      final coverUrl = album.coverImage != null
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
        trailing:
        Text("${album.songCount} bài", style: const TextStyle(color: Colors.white70)),
        onTap: () {
          if (userId == null) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AlbumDetailScreen(album: album, userId: userId!),
            ),
          );
        },
      );
    }).toList();
  }

  List<Widget> buildPodcasts() {
    return List.generate(4, (i) {
      return ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.orange.withAlpha(77),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.mic, color: Colors.orange),
        ),
        title: Text("Podcast $i", style: const TextStyle(color: Colors.white)),
        subtitle: const Text("Host Name", style: TextStyle(color: Colors.white70)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
      );
    });
  }
}