import 'package:flutter/material.dart';

import '../controllers/library_controller.dart';
import '../models/playlist.dart';
import '../models/artist.dart';
import '../models/song.dart';

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

                // ─────────────── FILTER ───────────────
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

                Expanded(
                    child: ListView(
                        children: [
                        if (tabIndex == 0)
                    ..._buildPlaylistTiles(controller.playlists)

                else if (tabIndex == 1)
                    ..._buildSongTiles(controller.song)else
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

  // ───────────────────────────────────────── FILTER CHIP ─────────────────────────────────────────

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

  // ───────────────────────────────────────── PLAYLIST UI ─────────────────────────────────────────

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

  // ───────────────────────────────────────── SONG UI ─────────────────────────────────────────

  List<Widget> _buildSongTiles(List<SongModel> songs) {
    if (songs.isEmpty) {
      return const [
        Text("Chưa có bài hát yêu thích",
            style: TextStyle(color: Colors.white54, fontSize: 16))
      ];
    }

    return songs.map((s) {
      return ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(s.thumbnail),
        ),
        title: Text(
          s.title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        subtitle: Text(
          s.artist,
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }).toList();
  }// ───────────────────────────────────────── ARTIST UI ─────────────────────────────────────────

  List<Widget> _buildArtistTiles(List<ArtistModel> artists) {
    if (artists.isEmpty) {
      return const [
        Text("Chưa có ca sĩ yêu thích",
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