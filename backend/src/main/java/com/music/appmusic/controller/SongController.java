package com.music.appmusic.controller;

import com.music.appmusic.dto.SongResponse;
import com.music.appmusic.service.SongService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class SongController {

    @Autowired
    private SongService songService;

    @GetMapping("/songs/artist/{artistId}")
    public ResponseEntity<List<SongResponse>> getSongsByArtist(@PathVariable Long artistId) {
        try {
            List<SongResponse> songs = songService.getSongsByArtistId(artistId);
            return ResponseEntity.ok(songs);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).build();
        }
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
        return ResponseEntity.ok(songService.isSongLiked(userId, songId));
    }
}
