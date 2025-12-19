import 'package:flutter/material.dart';
import '../../api/song_service.dart';
import '../../api/artist_service.dart';
import '../../utils/library_refresh_notifier.dart';
import '../models/artist.dart';
import '../models/song.dart';
import '../screens/music_player_screen.dart';

class ArtistDetailScreen extends StatefulWidget {
  final Artist artist;
  final int userId; // thêm userId

  const ArtistDetailScreen({
    super.key,
    required this.artist,
    required this.userId,
  });

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  bool _isFollowing = false;
  bool _loadingFollow = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _checkIfFollowing();
  }

  Future<void> _checkIfFollowing() async {
    try {
      final result = await ArtistService.isArtistFollowed(widget.artist.id, widget.userId);

      if (!mounted) return;

      setState(() => _isFollowing = result);
    } catch (e) {
      debugPrint('❌ CHECK FOLLOW ERROR: $e');
    }
  }

  Future<void> _toggleFollow() async {
    if (_loadingFollow) return;

    setState(() => _loadingFollow = true);

    try {
      if (_isFollowing) {
        await ArtistService.unfollowArtist(widget.artist.id, widget.userId);

        if (!mounted) return;

        setState(() {
          _isFollowing = false;
          _hasChanges = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bỏ theo dõi thành công')));
      } else {
        await ArtistService.followArtist(widget.artist.id, widget.userId);

        if (!mounted) return;

        setState(() {
          _isFollowing = true;
          _hasChanges = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã theo dõi nghệ sĩ')));
      }

      LibraryRefreshNotifier.notify();
    } catch (e) {
      debugPrint('❌ TOGGLE FOLLOW ERROR: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Có lỗi xảy ra, vui lòng thử lại')));
      }
    } finally {
      if (mounted) setState(() => _loadingFollow = false);
    }
  }

  Future<void> _playAllArtist() async {
    try {
      final songs = await SongService.fetchSongsByArtist(widget.artist.id);

      if (!mounted) return;

      if (songs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nghệ sĩ chưa có bài hát')));
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MusicPlayerScreen(
            initialSong: songs.first,
            playlist: songs,
            startIndex: 0,
            userId: widget.userId,
            // ✅ Không cần truyền libraryController nữa
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể tải bài hát')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        Navigator.pop(context, _hasChanges);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context, _hasChanges),
          ),
          title: Text(widget.artist.name, style: const TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        widget.artist.profileImage != null
                            ? 'http://10.0.2.2:8080/uploads/${widget.artist.profileImage}'
                            : 'https://via.placeholder.com/300?text=Artist  ',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(widget.artist.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              Row(
                children: [
                  _loadingFollow
                      ? const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : IconButton(
                    icon: Icon(_isFollowing ? Icons.check : Icons.add,
                        color: _isFollowing ? Colors.green : Colors.white, size: 28),
                    onPressed: _toggleFollow,
                  ),
                  const Spacer(),
                  FloatingActionButton.small(
                    backgroundColor: Colors.green,
                    onPressed: _playAllArtist,
                    child: const Icon(Icons.play_arrow, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text('Popular Songs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: FutureBuilder<List<Song>>(
                  future: SongService.fetchSongsByArtist(widget.artist.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('This artist has no songs yet.',
                            style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
                      );
                    }

                    final songs = snapshot.data!;
                    return ListView.builder(
                      itemCount: songs.length,
                      itemBuilder: (_, index) {
                        final song = songs[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(song.title, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(song.artist?.name ?? 'Unknown Artist',
                              style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MusicPlayerScreen(
                                  initialSong: song,
                                  playlist: songs,
                                  startIndex: index,
                                  userId: widget.userId,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
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