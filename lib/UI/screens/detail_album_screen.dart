import 'package:flutter/material.dart';
import '../../api/album_service.dart';
import '../../utils/library_refresh_notifier.dart';
import '../models/album.dart';
import '../models/song.dart';
import '../screens/music_player_screen.dart';

class AlbumDetailScreen extends StatefulWidget {
  final Album album;
  final int userId;

  const AlbumDetailScreen({
    super.key,
    required this.album,
    required this.userId,
  });

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  bool isFollowing = false;
  bool loadingFollow = false;
  bool hasChanges = false;

  late final Future<List<Song>> songsFuture;

  @override
  void initState() {
    super.initState();
    songsFuture = AlbumService.fetchSongsByAlbum(widget.album.id);
    checkIfFollowing();
  }

  Future<void> checkIfFollowing() async {
    final result = await AlbumService.isAlbumFollowed(
      widget.album.id,
      widget.userId,
    );

    if (!mounted) return;
    setState(() => isFollowing = result);
  }

  Future<void> toggleFollow() async {
    if (loadingFollow) return;

    final ctx = context;

    setState(() => loadingFollow = true);

    try {
      if (isFollowing) {
        await AlbumService.unfollowAlbum(widget.album.id, widget.userId);

        if (mounted) {
          setState(() {
            isFollowing = false;
            hasChanges = true;
          });

          LibraryRefreshNotifier.notify();

          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Bỏ theo dõi album thành công')),
          );
        }
      } else {
        await AlbumService.followAlbum(widget.album.id, widget.userId);

        if (mounted) {
          setState(() {
            isFollowing = true;
            hasChanges = true;
          });

          LibraryRefreshNotifier.notify();

          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Đã theo dõi album')),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => loadingFollow = false);
      }
    }
  }

  void playAllAlbum(List<Song> songs) {
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
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.pop(context, hasChanges);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context, hasChanges),
          ),
          title: Text(widget.album.title, style: const TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: FutureBuilder<List<Song>>(
            future: songsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              final songs = snapshot.data ?? [];

              return LayoutBuilder(
                builder: (context, constraints) {
                  return isLandscape
                      ? Row(
                    children: [
                      SizedBox(
                        width: constraints.maxWidth * 0.4,
                        child: buildHeader(songs),
                      ),
                      Expanded(
                        child: buildSongList(songs),
                      ),
                    ],
                  )
                      : SingleChildScrollView(
                    child: Column(
                      children: [
                        buildHeader(songs),
                        buildSongList(songs),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildHeader(List<Song> songs) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                widget.album.coverImage != null
                    ? 'http://10.0.2.2:8080/uploads/${widget.album.coverImage}'
                    : 'https://via.placeholder.com/300',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.album.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
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
              loadingFollow
                  ? const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : IconButton(
                icon: Icon(
                  isFollowing ? Icons.check : Icons.add,
                  color: isFollowing ? Colors.green : Colors.white,
                  size: 28,
                ),
                onPressed: toggleFollow,
              ),
              const Spacer(),
              FloatingActionButton.small(
                backgroundColor: Colors.green,
                onPressed: () => playAllAlbum(songs),
                child: const Icon(Icons.play_arrow, color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSongList(List<Song> songs) {
    if (songs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'This album has no songs.',
            style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return ListTile(
          leading: Text(
            '${index + 1}.',
            style: const TextStyle(color: Colors.white70),
          ),
          title: Text(song.title, style: const TextStyle(color: Colors.white)),
          subtitle: Text(
            song.artist?.name ?? 'Unknown Artist',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
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
  }
}