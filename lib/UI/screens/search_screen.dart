// lib/UI/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:async/async.dart';
import '../../utils/user_utils.dart';

import '../models/album.dart';
import '../models/artist.dart';
import '../models/song.dart';
import 'Detail_Album_Screen.dart';
import 'Detail_Artist_Screen.dart';
import 'music_player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _searchResults;
  int? _userId;

  CancelableOperation<void>? _searchOperation;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final uid = await UserUtils.getUserId();
    if (!mounted) return;
    setState(() => _userId = uid);
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _searchOperation?.cancel();

    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty || trimmedQuery.length < 2) {
      setState(() {
        _searchResults = null;
        _isLoading = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _searchOperation =
          CancelableOperation.fromFuture(_performSearch(trimmedQuery));
    });
  }

  Future<void> _performSearch(String query) async {
    if (_searchController.text.trim() != query) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/search?q=$query'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>?;
        if (data != null && _searchController.text.trim() == query) {
          setState(() => _searchResults = data);
        }
      } else {
        throw Exception('Lỗi API: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tìm kiếm: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchOperation?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const SizedBox(),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Nghệ sĩ, bài hát, hoặc podcast',
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white70),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _searchController.text.trim().isEmpty
                  ? _buildDefaultCategories()
                  : _isLoading
                  ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
                  : _searchResults != null
                  ? _buildSearchResults(_searchResults!)
                  : const Center(
                child: Text(
                  'Đang tìm kiếm...',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(Map<String, dynamic> results) {
    final songs = (results['songs'] as List?) ?? [];
    final albums = (results['albums'] as List?) ?? [];
    final artists = (results['artists'] as List?) ?? [];

    if (songs.isEmpty && albums.isEmpty && artists.isEmpty) {
      return Center(
        child: Text(
          'Không tìm thấy kết quả cho "${_searchController.text.trim()}"',
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView(
      children: [
        if (artists.isNotEmpty) ...[
          _sectionTitle('Nghệ sĩ'),
          ...artists.map((item) {
            if (item is! Map<String, dynamic>) return const SizedBox();
            final artist = Artist.fromJson(item);
            return ListTile(
              leading: const Icon(Icons.person, color: Colors.grey),
              title: Text(artist.name, style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArtistDetailScreen(artist: artist),
                  ),
                );
              },
            );
          }),
        ],
        if (albums.isNotEmpty) ...[
          _sectionTitle('Album'),
          ...albums.map((item) {
            if (item is! Map<String, dynamic>) return const SizedBox();
            final album = Album.fromJson(item);
            return ListTile(
              leading: const Icon(Icons.album, color: Colors.grey),
              title: Text(album.title, style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AlbumDetailScreen(album: album),
                  ),
                );
              },
            );
          }),
        ],
        if (songs.isNotEmpty) ...[
          _sectionTitle('Bài hát'),
          ...songs.map((item) {
            if (item is! Map<String, dynamic>) return const SizedBox();
            final song = Song.fromJsonBrief(item);
            return ListTile(
              leading: const Icon(Icons.music_note, color: Colors.grey),
              title: Text(song.title, style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MusicPlayerScreen(
                      initialSong: song,
                      playlist: null,
                      startIndex: 0,
                      userId: _userId ?? -1,
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDefaultCategories() {
    final categories = [
      {'name': 'Pop', 'color': Colors.redAccent},
      {'name': 'Rock', 'color': Colors.blueAccent},
      {'name': 'Hip-Hop', 'color': Colors.orangeAccent},
      {'name': 'EDM', 'color': Colors.greenAccent},
      {'name': 'Acoustic', 'color': Colors.brown},
      {'name': 'Indie', 'color': Colors.teal},
      {'name': 'Cổ điển', 'color': Colors.indigo},
      {'name': 'R&B', 'color': Colors.pinkAccent},
    ];

    return GridView.builder(
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 16 / 9,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemBuilder: (_, i) {
        final c = categories[i];
        return Container(
          decoration: BoxDecoration(
            color: (c['color'] as Color).withAlpha(200),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              c['name'] as String,
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
