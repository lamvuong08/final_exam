import 'package:flutter/material.dart';
import '../controllers/library_controller.dart';
import '../models/song.dart'; // chỉ import Song

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
    await controller.loadLibrary(1); // mock dữ liệu
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
              const Text(
                "Thư viện",
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // ─── FILTER TABS ───
              Row(
                children: [
                  _filterChip(
                    label: "Danh sách phát",
                    selected: tabIndex == 0,
                    onTap: () => setState(() => tabIndex = 0),
                  ),
                  const SizedBox(width: 10),
                  _filterChip(
                    label: "Bài hát",
                    selected: tabIndex == 1,
                    onTap: () => setState(() => tabIndex = 1),
                  ),
                  const SizedBox(width: 10),
                  _filterChip(
                    label: "Ca sĩ",
                    selected: tabIndex == 2,
                    onTap: () => setState(() => tabIndex = 2),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ─── NỘI DUNG THEO TAB ───
              Expanded(
                child: ListView(
                  children: [
                    if (tabIndex == 0) ..._buildPlaylistTiles(),
                    if (tabIndex == 1) ..._buildSongTiles(controller.songs),
                    if (tabIndex == 2) ..._buildArtistTiles(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ─── MOCK: Playlist ───
  List<Widget> _buildPlaylistTiles() {
    return controller.playlists.map((name) {
      return ListTile(
        leading: const Icon(Icons.playlist_play, color: Colors.white),
        title: Text(name, style: const TextStyle(color: Colors.white)),
      );
    }).toList();
  }

  // ─── HIỂN THỊ BÀI HÁT ───
  List<Widget> _buildSongTiles(List<Song> songs) {
    if (songs.isEmpty) {
      return const [
        Text(
          "Chưa có bài hát yêu thích",
          style: TextStyle(color: Colors.white54, fontSize: 16),
        )
      ];
    }

    return songs.map((song) {
      // Xây dựng URL ảnh từ coverImage
      String imageUrl = song.coverImage != null
          ? 'http://10.0.2.2:8080/uploads/${song.coverImage}'
          : 'https://via.placeholder.com/50';

      return ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
          onBackgroundImageError: (error, stackTrace) {
            // Fallback nếu ảnh lỗi
          },
        ),
        title: Text(
          song.title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        subtitle: Text(
          song.artist?.name ?? 'Nghệ sĩ ẩn danh',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      );
    }).toList();
  }

  // ─── MOCK: Ca sĩ ───
  List<Widget> _buildArtistTiles() {
    return controller.artists.map((name) {
      return ListTile(
        leading: const CircleAvatar(
          backgroundImage: NetworkImage('https://via.placeholder.com/50'),
        ),
        title: Text(name, style: const TextStyle(color: Colors.white)),
      );
    }).toList();
  }
}