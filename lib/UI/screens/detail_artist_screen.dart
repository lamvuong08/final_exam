import 'package:flutter/material.dart';
import '../../api/song_service.dart';
import '../../api/artist_service.dart';
import '../../utils/library_refresh_notifier.dart';
import '../models/artist.dart';
import '../models/song.dart';
import '../screens/music_player_screen.dart';

class ArtistDetailScreen extends StatefulWidget {
  final Artist artist;
  final int userId;

  const ArtistDetailScreen({
    super.key,
    required this.artist,
    required this.userId,
  });

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  bool isFollowing = false;
  bool loadingFollow = false;
  bool hasChanges = false;

  late final Future<List<Song>> songsFuture;

  @override
  void initState() {
    super.initState();
    songsFuture = SongService.fetchSongsByArtist(widget.artist.id);
    checkIfFollowing();
  }

  Future<void> checkIfFollowing() async {
    final result = await ArtistService.isArtistFollowed(
      widget.artist.id,
      widget.userId,
    );

    if (!mounted) return;
    setState(() => isFollowing = result);
  }

  Future<void> toggleFollow() async {
    if (loadingFollow) return;

    final messenger = ScaffoldMessenger.of(context);

    setState(() => loadingFollow = true);

    try {
      if (isFollowing) {
        await ArtistService.unfollowArtist(widget.artist.id, widget.userId);
        if (!mounted) return;

        setState(() {
          isFollowing = false;
          hasChanges = true;
        });

        LibraryRefreshNotifier.notify();
        messenger.showSnackBar(
          const SnackBar(content: Text('Bỏ theo dõi thành công')),
        );
      } else {
        await ArtistService.followArtist(widget.artist.id, widget.userId);
        if (!mounted) return;

        setState(() {
          isFollowing = true;
          hasChanges = true;
        });

        LibraryRefreshNotifier.notify();
        messenger.showSnackBar(
          const SnackBar(content: Text('Đã theo dõi nghệ sĩ')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loadingFollow = false);
      }
    }
  }

  void playAllArtist(List<Song> songs) {
    if (songs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nghệ sĩ chưa có bài hát')),
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
          title: Text(widget.artist.name, style: const TextStyle(color: Colors.white)),
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
                        ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: songs.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final song = songs[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(song.title, style: const TextStyle(color: Colors.white)),
                              subtitle: Text(
                                song.artist?.name ?? 'Unknown Artist',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
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
                        ),
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.artist.profileImage != null
                      ? 'http://10.0.2.2:8080/uploads/${widget.artist.profileImage}'
                      : 'https://via.placeholder.com/300',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.artist.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
                  onPressed: () => playAllArtist(songs),
                  child: const Icon(Icons.play_arrow, color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSongList(List<Song> songs) {
    if (songs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'This artist has no songs yet.',
            style: TextStyle(
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(song.title, style: const TextStyle(color: Colors.white)),
          subtitle: Text(
            song.artist?.name ?? 'Unknown Artist',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
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