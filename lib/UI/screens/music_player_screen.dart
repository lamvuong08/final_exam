import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../api/song_service.dart';
import '../../utils/library_refresh_notifier.dart';
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
  late AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  int _currentIndex = 0;
  bool _isLiked = false;
  bool _loadingLike = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startIndex;
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) setState(() => _position = position);
    });
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) setState(() => _duration = duration);
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      _playNext();
    });
    _playCurrentSong();
    _loadLikeStatus();
  }

  Song get _currentSong => widget.playlist != null
      ? widget.playlist![_currentIndex]
      : widget.initialSong;

  Future<void> _loadLikeStatus() async {
    try {
      final liked = await SongService.isSongLiked(_currentSong.id, widget.userId);
      if (!mounted) return;
      setState(() => _isLiked = liked);
    } catch (e) {
      debugPrint('❌ Load like status error: $e');
    }
  }

  Future<void> _toggleLike() async {
    if (_loadingLike) return;
    setState(() => _loadingLike = true);
    try {
      if (_isLiked) {
        await SongService.unlikeSong(_currentSong.id, widget.userId);
      } else {
        await SongService.likeSong(_currentSong.id, widget.userId);
      }
      if (!mounted) return;
      setState(() => _isLiked = !_isLiked);

      LibraryRefreshNotifier.notify();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLiked ? 'Đã thêm vào yêu thích' : 'Đã bỏ yêu thích'),
        ),
      );
    } catch (e) {
      debugPrint('❌ Toggle like error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra, vui lòng thử lại')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingLike = false);
    }
  }

  Future<void> _playCurrentSong() async {
    final song = _currentSong;
    try {
      final songUrl = 'http://10.0.2.2:8080/api/music/stream/${song.id}';
      await _audioPlayer.play(UrlSource(songUrl));
      if (mounted) {
        setState(() {
          _isPlaying = true;
          _position = Duration.zero;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể phát: ${song.title}')),
        );
      }
    }
  }

  Future<void> _playNext() async {
    if (widget.playlist == null || widget.playlist!.isEmpty) return;
    final nextIndex = (_currentIndex + 1) % widget.playlist!.length;
    setState(() => _currentIndex = nextIndex);
    await _playCurrentSong();
    await _loadLikeStatus();
  }

  Future<void> _playPrevious() async {
    if (widget.playlist == null || widget.playlist!.isEmpty) return;
    if (_position.inSeconds > 3) {
      await _audioPlayer.seek(Duration.zero);
    } else {
      final prevIndex = (_currentIndex - 1) >= 0
          ? (_currentIndex - 1)
          : widget.playlist!.length - 1;
      setState(() => _currentIndex = prevIndex);
      await _playCurrentSong();
      await _loadLikeStatus();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = _currentSong;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Now Playing', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _loadingLike
                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                : Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.red : Colors.white70,
            ),
            onPressed: _toggleLike,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: currentSong.coverImage?.isNotEmpty == true
                        ? null
                        : Colors.grey[800],
                    borderRadius: BorderRadius.circular(15),
                    image: currentSong.coverImage?.isNotEmpty == true
                        ? DecorationImage(
                      image: NetworkImage(
                        'http://10.0.2.2:8080/uploads/${currentSong.coverImage}',
                      ),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                currentSong.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                currentSong.artist?.name ?? 'Nghệ sĩ ẩn danh',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: _loadingLike
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.red : Colors.white70,
                    ),
                    onPressed: _toggleLike,
                    splashRadius: 20,
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.queue_music_outlined, color: Colors.white),
                    onPressed: () {
                      if (widget.playlist != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đang phát ${widget.playlist!.length} bài'),
                          ),
                        );
                      }
                    },
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(_formatDuration(_position), style: const TextStyle(color: Colors.white70)),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white30,
                        thumbColor: Colors.white,
                        overlayColor: Colors.white.withAlpha(51),
                      ),
                      child: Slider(
                        value: _position.inSeconds.toDouble(),
                        min: 0,
                        max: _duration.inSeconds.toDouble(),
                        onChanged: (value) async {
                          final newPosition = Duration(seconds: value.toInt());
                          await _audioPlayer.seek(newPosition);
                        },
                      ),
                    ),
                  ),
                  Text(_formatDuration(_duration), style: const TextStyle(color: Colors.white70)),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.white, size: 40),
                    onPressed: _playPrevious,
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: Icon(
                      _isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: Colors.white,
                      size: 60,
                    ),
                    onPressed: () async {
                      if (_isPlaying) {
                        await _audioPlayer.pause();
                        setState(() => _isPlaying = false);
                      } else {
                        await _audioPlayer.resume();
                        setState(() => _isPlaying = true);
                      }
                    },
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white, size: 40),
                    onPressed: _playNext,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lyrics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currentSong.lyrics ?? 'No lyrics available.',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
