import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../../api/song_service.dart';
import '../controllers/library_controller.dart';
import '../models/song.dart';

class MusicPlayerScreen extends StatefulWidget {
  final Song initialSong;
  final List<Song>? playlist;
  final int startIndex;
  final int userId;

  const MusicPlayerScreen({
    super.key,
    required this.initialSong,
    this.playlist,
    this.startIndex = 0,
    required this.userId,
  });

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  static const baseUrl = 'http://10.0.2.2:8080';

  late final AudioPlayer player;

  Song? song;
  bool loadingSong = true;
  String? lyrics;

  bool isPlaying = false;
  bool isLiked = false;
  bool loadingLike = false;

  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  int currentIndex = 0;

  List<Song> get queue =>
      widget.playlist != null && widget.playlist!.isNotEmpty
          ? widget.playlist!
          : [widget.initialSong];

  Song get baseSong => queue[currentIndex];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.startIndex;
    player = AudioPlayer();
    setupListeners();
    loadSongDetail();
  }

  void setupListeners() {
    player.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() => duration = d);
    });

    player.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() => position = p);
    });

    player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => isPlaying = state == PlayerState.playing);
    });

    player.onPlayerComplete.listen((_) => playNext());
  }

  /// Ẩn timestamp + metadata trong lyrics
  String cleanLyrics(String raw) {
    return raw
        .replaceAll(RegExp(r'\[\d{2}:\d{2}\.\d{2}\]'), '')
        .replaceAll(RegExp(r'\[[a-zA-Z]+:.*?\]'), '')
        .replaceAll(RegExp(r'\n{2,}'), '\n')
        .trim();
  }

  Future<void> loadSongDetail() async {
    try {
      final result = await SongService.getSongById(baseSong.id);
      if (!mounted) return;

      setState(() {
        song = result;
        loadingSong = false;
        duration = Duration.zero;
        position = Duration.zero;
        lyrics = null;
      });

      await loadLikeStatus();
      await playSong();
    } catch (_) {
      if (!mounted) return;
      setState(() => loadingSong = false);
    }
  }

  Future<void> playSong() async {
    if (song?.filePath == null || song!.filePath!.isEmpty) return;
    await player.stop();
    await player.play(UrlSource('$baseUrl/uploads/${song!.filePath}'));
  }

  void reloadSong() {
    setState(() {
      song = null;
      loadingSong = true;
      isLiked = false;
      lyrics = null;
    });
    loadSongDetail();
  }

  void playNext() {
    if (queue.isEmpty) return;
    currentIndex = (currentIndex + 1) % queue.length;
    reloadSong();
  }

  Future<void> playPrevious() async {
    if (queue.isEmpty) return;

    if (position.inSeconds > 3) {
      await player.seek(Duration.zero);
    } else {
      currentIndex = (currentIndex - 1 + queue.length) % queue.length;
      reloadSong();
    }
  }

  Future<void> loadLikeStatus() async {
    if (song == null) return;
    final liked = await SongService.isSongLiked(song!.id, widget.userId);
    if (!mounted) return;
    setState(() => isLiked = liked);
  }

  Future<void> toggleLike() async {
    if (loadingLike || song == null) return;

    setState(() => loadingLike = true);
    final lib = Provider.of<LibraryController>(context, listen: false);

    try {
      isLiked
          ? await lib.unlikeSong(widget.userId, song!.id)
          : await lib.likeSong(widget.userId, song!);

      if (!mounted) return;
      setState(() => isLiked = !isLiked);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isLiked ? 'Đã thêm vào yêu thích' : 'Đã bỏ yêu thích')),
      );
    } finally {
      if (mounted) setState(() => loadingLike = false);
    }
  }

  String fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loadingSong) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(song?.title ?? ''),
        actions: [
          IconButton(icon: const Icon(Icons.queue_music), onPressed: showQueue),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  '$baseUrl/uploads/${song?.coverImage ?? ''}',
                  width: 260,
                  height: 260,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 260,
                    height: 260,
                    color: Colors.deepPurple.withAlpha(40),
                    child: const Icon(Icons.music_note, size: 80, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                song?.title ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(song?.artist?.name ?? '', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 20),

              Slider(
                value: position.inSeconds.clamp(0, duration.inSeconds).toDouble(),
                max: duration.inSeconds > 0 ? duration.inSeconds.toDouble() : 1,
                onChanged: (v) => player.seek(Duration(seconds: v.toInt())),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(fmt(position), style: const TextStyle(color: Colors.white70)),
                  Text(fmt(duration), style: const TextStyle(color: Colors.white70)),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(icon: const Icon(Icons.skip_previous, size: 36), color: Colors.white, onPressed: playPrevious),
                  IconButton(
                    icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 72),
                    color: Colors.white,
                    onPressed: () async => isPlaying ? player.pause() : player.resume(),
                  ),
                  IconButton(icon: const Icon(Icons.skip_next, size: 36), color: Colors.white, onPressed: playNext),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: loadingLike
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.white),
                    onPressed: toggleLike,
                  ),
                  TextButton(
                    onPressed: showLyrics,
                    child: const Text('Lyrics', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showQueue() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView.builder(
        itemCount: queue.length,
        itemBuilder: (_, i) {
          final s = queue[i];
          final active = i == currentIndex;
          return ListTile(
            leading: Icon(active ? Icons.equalizer : Icons.music_note, color: active ? Colors.greenAccent : Colors.white70),
            title: Text(s.title, style: TextStyle(color: active ? Colors.greenAccent : Colors.white,),),
            subtitle: Text(s.artist?.name ?? '', style: const TextStyle(color: Colors.white70)),
            onTap: () {
              Navigator.pop(context);
              currentIndex = i;
              reloadSong();
            },
          );
        },
      ),
    );
  }

  void showLyrics() async {
    lyrics ??= await SongService.getLyricsBySongId(song!.id);

    if (!mounted) return;

    final displayLyrics = lyrics != null && lyrics!.isNotEmpty
        ? cleanLyrics(lyrics!)
        : 'Chưa có lời bài hát';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            controller: controller,
            child: Text(
              displayLyrics,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.6),
            ),
          ),
        ),
      ),
    );
  }
}