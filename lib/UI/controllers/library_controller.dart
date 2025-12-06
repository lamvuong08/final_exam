// lib/controllers/library_controller.dart
import '../models/song.dart'; // chỉ cần Song

class LibraryController {
  // Dùng đúng kiểu Song (không có Model)
  List<Song> songs = [];
  List<String> playlists = ['Playlist 1', 'Playlist 2']; // mock đơn giản
  List<String> artists = ['Ca sĩ A', 'Ca sĩ B'];        // mock đơn giản

  Future<void> loadLibrary(int userId) async {
    // Tạm thời mock dữ liệu bài hát
    await Future.delayed(const Duration(milliseconds: 300));

    songs = [

    ];
  }
}