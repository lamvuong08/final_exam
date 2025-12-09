import 'package:flutter/material.dart';
import '../controllers/library_controller.dart';
import '../models/song.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final LibraryController controller = LibraryController();
  bool loading = true;
  int tabIndex = 0; // 0 = Default view (Liked + New Episodes), 1=Playlists, 2=Artists, 3=Albums, 4=Podcasts

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
              // ─── TABS ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _tabButton(label: "Playlists", index: 1),
                  _tabButton(label: "Artists", index: 2),
                  _tabButton(label: "Albums", index: 3),
                  _tabButton(label: "Podcasts", index: 4),
                ],
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

  // ─── DEFAULT VIEW: Liked Songs + New Episodes ───
  List<Widget> _buildDefaultView() {
    return [
      const Text(
        "Recently played",
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
      const SizedBox(height: 20),
      // Nếu cần thêm artist/album/podcast ở default view, có thể thêm dưới này
      // Nhưng theo yêu cầu, chỉ hiện 2 mục này khi chưa chọn tab
    ];
  }

  Widget _likedSongsTile() {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.purple[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.favorite, color: Colors.red),
      ),
      title: const Text(
        "Liked Songs",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: const Text(
        "Playlist • 5 songs",
        style: TextStyle(color: Colors.white70),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white70),
      onTap: () {
        setState(() => tabIndex = 1); // Chuyển sang tab Playlists
      },
    );
  }

  Widget _newEpisodesTile() {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.purple[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.notifications, color: Colors.white),
      ),
      title: const Text(
        "New Episodes",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: const Text(
        "Updated 2 days ago",
        style: TextStyle(color: Colors.white70),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white70),
      onTap: () {
        // Có thể mở màn hình mới hoặc chuyển tab khác
        // Hiện tại để trống, hoặc chuyển sang Podcasts nếu cần
      },
    );
  }

  // ─── PLAYLISTS ───
  List<Widget> _buildPlaylists() {
    return [
      const Text(
        "Playlists",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 16),
      ...controller.playlists.map((name) {
        return ListTile(
          leading: const Icon(Icons.playlist_play, color: Colors.white),
          title: Text(name, style: const TextStyle(color: Colors.white)),
          trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        );
      }).toList(),
    ];
  }

  // ─── ARTISTS ───
  List<Widget> _buildArtists() {
    return [
      const Text(
        "Artists",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 16),
      ...controller.artists.map((artistName) {
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage('https://via.placeholder.com/50'),
          ),
          title: Text(artistName, style: const TextStyle(color: Colors.white)),
          subtitle: const Text("Artist", style: TextStyle(color: Colors.white70)),
          trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        );
      }).toList(),
    ];
  }

  // ─── ALBUMS ───
  List<Widget> _buildAlbums() {
    return [
      const Text(
        "Albums",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 16),
      ...List.generate(5, (index) {
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.album, color: Colors.blue),
          ),
          title: Text("Album $index", style: const TextStyle(color: Colors.white)),
          subtitle: const Text("Artist Name", style: TextStyle(color: Colors.white70)),
          trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        );
      }),
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
              color: Colors.orange[100],
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