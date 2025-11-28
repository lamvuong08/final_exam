import 'package:flutter/material.dart';

import '../models/playlist.dart';
import '../models/artist.dart';
import '../controllers/library_controller.dart';


class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final LibraryController controller = LibraryController();

  bool showPlaylists = true;

  final TextEditingController _musicController = TextEditingController();

  @override
  void dispose() {
    _musicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITLE
              const Text(
                'Thư viện',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // FILTER BUTTONS (Danh sách phát / Nghệ sĩ)
              Row(
                children: [
                  _filterChip(
                    label: 'Danh sách phát',
                    selected: showPlaylists,
                    onTap: () {
                      setState(() {
                        showPlaylists = true;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _filterChip(
                    label: 'Nghệ sĩ',
                    selected: !showPlaylists,
                    onTap: () {
                      setState(() {
                        showPlaylists = false;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // LIST + CÁC NÚT THÊM
              Expanded(
                child: ListView(
                  children: [
                    if (showPlaylists) ..._buildPlaylistTiles() else ..._buildArtistTiles(),
                    const SizedBox(height: 16),
                    _buildAddButtonsSection(),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // TEXTFIELD THÊM NHẠC
              _buildAddMusicTextField(),
            ],
          ),
        ),
      ),
    );
  }

  // ================== WIDGET HELPERS ==================

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(24),
        ),
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

  List<Widget> _buildPlaylistTiles() {
    if (controller.playlists.isEmpty) {
      return [
        const Text(
          'Chưa có danh sách phát nào',
          style: TextStyle(color: Colors.white54),
        ),
      ];
    }

    return controller.playlists.map((p) {
      return ListTile(
        leading: const Icon(Icons.music_note, color: Colors.white),
        title: Text(
          p.name,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          '${p.songCount} bài hát',
          style: const TextStyle(color: Colors.white54),
        ),
      );
    }).toList();
  }

  List<Widget> _buildArtistTiles() {
    if (controller.artists.isEmpty) {
      return [
        const Text(
          'Chưa có nghệ sĩ nào',
          style: TextStyle(color: Colors.white54),
        ),
      ];
    }

    return controller.artists.map((artist) {
      return ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
            artist.image.isEmpty
                ? controller.defaultAvatar
                : artist.image,
          ),
        ),
        title: Text(
          artist.name,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: const Text(
          'Nghệ sĩ',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }).toList();
  }

  Widget _buildAddButtonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // THÊM NGHỆ SĨ
        _addItemTile(
          icon: Icons.add,
          label: 'Thêm nghệ sĩ',
          onTap: _onAddArtistPressed,
        ),
        const SizedBox(height: 8),

        // THÊM NHẠC (dùng cùng logic với TextField phía dưới)
        _addItemTile(
          icon: Icons.add,
          label: 'Thêm nhạc',
          onTap: _onAddMusicPressed,
        ),
      ],
    );
  }

  Widget _addItemTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }

  Widget _buildAddMusicTextField() {
    return TextField(
      controller: _musicController,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: 'Thêm nhạc',
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.grey.shade900,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onSubmitted: (_) => _onAddMusicPressed(),
    );
  }

  // ================== ACTIONS ==================

  void _onAddArtistPressed() {
    setState(() {
      controller.addArtist(
        ArtistModel.fromString('Nghệ sĩ mới'),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã thêm nghệ sĩ mới')),
    );
  }

  void _onAddMusicPressed() {
    final name = _musicController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên nhạc')),
      );
      return;
    }

    setState(() {
      controller.addPlaylist(
        PlaylistModel.fromString(name),
      );
    });

    _musicController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã thêm vào danh sách phát')),
    );
  }
}
