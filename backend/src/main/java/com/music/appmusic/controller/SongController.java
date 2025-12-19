package com.music.appmusic.controller;

import com.music.appmusic.dto.SongResponse;
import com.music.appmusic.service.SongService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/songs")
@CrossOrigin(origins = "*")
public class SongController {

    @Autowired
    private SongService songService;

    @GetMapping("/random")
    public ResponseEntity<List<SongResponse>> getRandomSongs(@RequestParam(defaultValue = "1") int count) {
        List<SongResponse> songs = songService.getRandomSongs(count);
        return ResponseEntity.ok(songs);
    }

    @GetMapping("/{id}")
    public ResponseEntity<SongResponse> getSongById(@PathVariable Long id) {
        SongResponse song = songService.getSongById(id);
        return ResponseEntity.ok(song);
    }

    @GetMapping("/album/{albumId}")
    public ResponseEntity<List<SongResponse>> getSongsByAlbum(@PathVariable Long albumId) {
        List<SongResponse> songs = songService.getSongsByAlbum(albumId);
        return ResponseEntity.ok(songs);
    }

    @GetMapping("/recently-played")
    public ResponseEntity<List<SongResponse>> getRecentlyPlayedSongs(@RequestParam Long userId) {
        List<SongResponse> songs = songService.getRecentlyPlayedSongs(userId);
        return ResponseEntity.ok(songs);
    }

    // --- Các endpoint cũ ---
    @GetMapping("/trending")
    public ResponseEntity<List<SongResponse>> getTrendingSongs() {
        List<SongResponse> songs = songService.getTrendingSongs();
        return ResponseEntity.ok(songs);
    }

    @GetMapping("/new-music-message")
    public ResponseEntity<String> getNewMusicMessage() {
        String message = songService.getNewMusicMessage();
        return ResponseEntity.ok(message);
    }

    @GetMapping("/artist/{artistId}")
    public ResponseEntity<List<SongResponse>> getSongsByArtist(@PathVariable Long artistId) {
        List<SongResponse> songs = songService.getSongsByArtistId(artistId);
        return ResponseEntity.ok(songs);
    }

    @GetMapping("/album/{albumId}/songs")
    public ResponseEntity<List<SongResponse>> getSongsInAlbum(@PathVariable Long albumId) {
        List<SongResponse> songs = songService.getSongsByAlbumId(albumId);
        return ResponseEntity.ok(songs);
    }

    @PostMapping("/user/{userId}/song/{songId}/like")
    public ResponseEntity<Void> likeSong(@PathVariable Long userId, @PathVariable Long songId) {
        songService.likeSong(userId, songId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/user/{userId}/song/{songId}/like")
    public ResponseEntity<Void> unlikeSong(@PathVariable Long userId, @PathVariable Long songId) {
        songService.unlikeSong(userId, songId);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/user/{userId}/song/{songId}/like/check")
    public ResponseEntity<Boolean> isSongLiked(@PathVariable Long userId, @PathVariable Long songId) {
        boolean isLiked = songService.isSongLiked(userId, songId);
        return ResponseEntity.ok(isLiked);
    }
}