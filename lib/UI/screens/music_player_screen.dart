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
  static const String baseUrl = 'http://10.0.2.2:8080';

  late final AudioPlayer _player;

  Song? _song;
  bool _loadingSong = true;
  String? _lyrics;


  bool _isPlaying = false;
  bool _isLiked = false;
  bool _loadingLike = false;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  int _currentIndex = 0;

  Song get _baseSong => _queue[_currentIndex];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startIndex;
    _player = AudioPlayer();
    _setupListeners();
    _loadSongDetail();
  }

  List<Song> get _queue {
    if (widget.playlist != null && widget.playlist!.isNotEmpty) {
      return widget.playlist!;
    }
    return [widget.initialSong];
  }


  void _showQueue() {
    final queue = _queue;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: ListView.builder(
            itemCount: queue.length,
            itemBuilder: (context, index) {
              final song = queue[index];
              final isPlaying = index == _currentIndex;

              return ListTile(
                leading: Icon(
                  isPlaying ? Icons.equalizer : Icons.music_note,
                  color: isPlaying ? Colors.greenAccent : Colors.white70,
                ),
                title: Text(
                  song.title ?? '',
                  style: TextStyle(
                    color: isPlaying ? Colors.greenAccent : Colors.white,
                    fontWeight:
                    isPlaying ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  song.artist?.name ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _playFromQueue(index);
                },
              );
            },
          ),
        );
      },
    );
  }


  void _playFromQueue(int index) {
    if (index < 0 || index >= widget.playlist!.length) return;

    setState(() {
      _currentIndex = index;
      _song = null;
      _loadingSong = true;
      _isLiked = false;
      _duration = Duration.zero;
      _position = Duration.zero;
    });

    _loadSongDetail();
  }

  String _cleanLyrics(String raw) {
    return raw
        .replaceAll(RegExp(r'\[\d{2}:\d{2}\.\d{2}\]'), '')
        .replaceAll(RegExp(r'\[[a-zA-Z]+:.*?\]'), '')
        .replaceAll(RegExp(r'\n{2,}'), '\n')
        .trim();
  }





  void _setupListeners() {
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });

    _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });

    _player.onPlayerComplete.listen((_) => _playNext());
  }

  Future<void> _loadSongDetail() async {
    try {
      final song = await SongService.getSongById(_baseSong.id);
      if (!mounted) return;

      setState(() {
        _song = song;
        _loadingSong = false;
        _duration = Duration.zero;
        _position = Duration.zero;
      });

      await _loadLikeStatus();
      await _playSong();
    } catch (e) {
      debugPrint('❌ Load song error: $e');
      if (mounted) setState(() => _loadingSong = false);
    }
  }

  Future<void> _playSong() async {
    if (_song?.filePath == null || _song!.filePath!.isEmpty) return;

    final url = '$baseUrl/uploads/${_song!.filePath}';
    await _player.stop();
    await _player.play(UrlSource(url));
  }

  Future<void> _playNext() async {
    final queue = _queue;
    if (queue.isEmpty) return;

    _currentIndex = (_currentIndex + 1) % queue.length;
    _reloadSong();
  }

  Future<void> _playPrevious() async {
    final queue = _queue;
    if (queue.isEmpty) return;

    if (_position.inSeconds > 3) {
      await _player.seek(Duration.zero);
    } else {
      _currentIndex =
          (_currentIndex - 1 + queue.length) % queue.length;
      _reloadSong();
    }
  }


  void _reloadSong() {
    setState(() {
      _song = null;
      _loadingSong = true;
      _isLiked = false;
    });
    _loadSongDetail();
  }

  Future<void> _loadLikeStatus() async {
    if (_song == null) return;
    try {
      final liked = await SongService.isSongLiked(
        _song!.id,
        widget.userId,
      );
      if (mounted) setState(() => _isLiked = liked);
    } catch (e) {
      debugPrint('❌ Load like status error: $e');
    }
  }

  Future<void> _toggleLike() async {
    if (_loadingLike || _song == null) return;

    setState(() => _loadingLike = true);

    final libraryController =
    Provider.of<LibraryController>(context, listen: false);

    try {
      if (_isLiked) {
        await libraryController.unlikeSong(widget.userId, _song!.id);
      } else {
        await libraryController.likeSong(widget.userId, _song!);
      }

      if (!mounted) return;

      setState(() => _isLiked = !_isLiked);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isLiked ? 'Đã thêm vào yêu thích' : 'Đã bỏ yêu thích',
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Toggle like error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingLike = false);
    }
  }


  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingSong) {
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
        title: Text(_song?.title ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music),
            onPressed: _showQueue,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                '$baseUrl/uploads/${_song?.coverImage ?? ''}',
                width: 280,
                height: 280,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 280,
                  height: 280,
                  color: Colors.deepPurple.withAlpha(40),
                  child: const Icon(Icons.music_note, size: 80, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _song?.title ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _song?.artist?.name ?? '',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            Slider(
              value: _position.inSeconds.toDouble(),
              max: _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1,
              onChanged: (v) => _player.seek(Duration(seconds: v.toInt())),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(_position), style: const TextStyle(color: Colors.white70)),
                Text(_fmt(_duration), style: const TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, size: 36),
                  color: Colors.white,
                  onPressed: _playPrevious,
                ),
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    size: 72,
                  ),
                  color: Colors.white,
                  onPressed: () async {
                    _isPlaying ? await _player.pause() : await _player.resume();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 36),
                  color: Colors.white,
                  onPressed: _playNext,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: _loadingLike
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.white,
                  ),
                  onPressed: _toggleLike,
                ),
                TextButton(
                  onPressed: _showLyrics,
                  child: const Text(
                    'Lyrics',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLyrics() async {
    if (_lyrics == null) {
      await _loadLyrics();
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Text(
            _lyrics != null && _lyrics!.isNotEmpty
                ? _cleanLyrics(_lyrics!)
                : 'Chưa có lời bài hát',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }


  Future<void> _loadLyrics() async {
    if (_song == null) return;

    try {
      final raw = await SongService.getLyricsBySongId(_song!.id);

      if (!mounted) return;

      setState(() {
        _lyrics = raw;
      });
    } catch (e) {
      debugPrint('❌ Load lyrics error: $e');
      _lyrics = null;
    }
  }



}