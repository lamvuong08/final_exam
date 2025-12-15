import 'package:flutter/material.dart';
import '../../api/album_service.dart';
import '../../utils/library_refresh_notifier.dart';
import '../models/album.dart';
import '../models/song.dart';
import '../screens/music_player_screen.dart';

class AlbumDetailScreen extends StatefulWidget {
  final Album album;
  final int userId; // thêm userId

  const AlbumDetailScreen({
    super.key,
    required this.album,
    required this.userId,
  });

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  bool _isFollowing = false;
  bool _loadingFollow = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _checkIfFollowing();
  }

  /// ================= CHECK FOLLOW =================
  Future<void> _checkIfFollowing() async {
    try {
      final result = await AlbumService.isAlbumFollowed(
        widget.album.id,
        widget.userId,
      );

      if (!mounted) return;

      setState(() {
        _isFollowing = result;
      });
    } catch (e) {
      debugPrint('❌ CHECK ALBUM FOLLOW ERROR: $e');
    }
  }

  /// ================= TOGGLE FOLLOW =================
  Future<void> _toggleFollow() async {
    if (_loadingFollow) return;

    setState(() => _loadingFollow = true);

    try {
      if (_isFollowing) {
        await AlbumService.unfollowAlbum(widget.album.id, widget.userId);

        if (!mounted) return;

        setState(() {
          _isFollowing = false;
          _hasChanges = true;
        });

        LibraryRefreshNotifier.notify();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bỏ theo dõi album thành công')),
        );
      } else {
        await AlbumService.followAlbum(widget.album.id, widget.userId);

        if (!mounted) return;

        setState(() {
          _isFollowing = true;
          _hasChanges = true;
        });

        LibraryRefreshNotifier.notify();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã theo dõi album')),
        );
      }
    } catch (e) {
      debugPrint('❌ TOGGLE ALBUM FOLLOW ERROR: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra, vui lòng thử lại')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingFollow = false);
    }
  }

  /// ================= PLAY ALL =================
  Future<void> _playAllAlbum() async {
    try {
      final songs = await AlbumService.fetchSongsByAlbum(widget.album.id);

      if (!mounted) return;

      if (songs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Album trống')),
        );
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
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải bài hát')),
        );
      }
    }
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _hasChanges);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context, _hasChanges),
          ),
          title: Text(widget.album.title, style: const TextStyle(color: Colors.white)),
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
                        widget.album.coverImage != null
                            ? 'http://10.0.2.2:8080/uploads/${widget.album.coverImage}'
                            : 'https://via.placeholder.com/300?text=Album',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.album.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                [
                  widget.album.artist.name,
                  if (widget.album.releaseYear != null) '${widget.album.releaseYear}',
                  '${widget.album.songCount} bài',
                ].join(' • '),
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
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
                    icon: Icon(
                      _isFollowing ? Icons.check : Icons.add,
                      color: _isFollowing ? Colors.green : Colors.white,
                      size: 28,
                    ),
                    onPressed: _toggleFollow,
                    tooltip: _isFollowing ? 'Đã theo dõi' : 'Theo dõi album',
                  ),
                  const Spacer(),
                  FloatingActionButton.small(
                    backgroundColor: Colors.green,
                    onPressed: _playAllAlbum,
                    child: const Icon(Icons.play_arrow, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Songs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 400,
                child: FutureBuilder<List<Song>>(
                  future: AlbumService.fetchSongsByAlbum(widget.album.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('This album has no songs.', style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
                      );
                    }

                    final songs = snapshot.data!;
                    return ListView.builder(
                      itemCount: songs.length,
                      itemBuilder: (_, index) {
                        final song = songs[index];
                        return ListTile(
                          leading: Text('${index + 1}.', style: const TextStyle(color: Colors.white70)),
                          title: Text(song.title, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(song.artist?.name ?? 'Unknown Artist', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          trailing: const Icon(Icons.chevron_right, color: Colors.white70),
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
