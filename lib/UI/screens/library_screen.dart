import 'package:flutter/material.dart';

import '../controllers/library_controller.dart';
import '../models/playlist.dart';
import '../models/artist.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final LibraryController controller = LibraryController(); // tự tạo controller

  bool showPlaylists = true;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await controller.loadLibrary(1);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: loading
            ? const Center(
          child: CircularProgressIndicator(color: Colors.white),
        )
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

              // FILTER
              Row(
                children: [
                  _filterChip(
                    label: "Danh sách phát",
                    selected: showPlaylists,
                    onTap: () => setState(() => showPlaylists = true),
                  ),
                  const SizedBox(width: 10),
                  _filterChip(
                    label: "Nghệ sĩ",
                    selected: !showPlaylists,
                    onTap: () => setState(() => showPlaylists = false),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Expanded(
                child: ListView(
                  children: [
                    if (showPlaylists)
                      ..._buildPlaylistTiles(controller.playlists)
                    else
                      ..._buildArtistTiles(controller.artists),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────── UI COMPONENTS ─────────────────────────────────────────

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

  List<Widget> _buildPlaylistTiles(List<PlaylistModel> playlists) {
    if (playlists.isEmpty) {
      return const [
        Text("Chưa có playlist",
            style: TextStyle(color: Colors.white54, fontSize: 16))
      ];
    }

    return playlists.map((p) {
      return ListTile(
        leading: const Icon(Icons.library_music, color: Colors.white),
        title: Text(
          p.name,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }).toList();
  }

  List<Widget> _buildArtistTiles(List<ArtistModel> artists) {
    if (artists.isEmpty) {
      return const [
        Text("Chưa có nghệ sĩ yêu thích",
            style: TextStyle(color: Colors.white54, fontSize: 16))
      ];
    }

    return artists.map((a) {
      return ListTile(
        leading: CircleAvatar(backgroundImage: NetworkImage(a.avatarUrl)),
        title: Text(
          a.name,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }).toList();
  }
}