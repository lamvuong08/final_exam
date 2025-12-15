package com.music.appmusic.controller;

import com.music.appmusic.dto.SongResponse;
import com.music.appmusic.service.AlbumService;
import com.music.appmusic.service.SongService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class AlbumController {

    private final SongService songService; // song endpoints
    private final AlbumService albumService; // follow/check endpoints

    @GetMapping("/albums/{albumId}/songs")
    public ResponseEntity<List<SongResponse>> getSongsByAlbum(@PathVariable Long albumId) {
        try {
            List<SongResponse> songs = songService.getSongsByAlbumId(albumId);
            return ResponseEntity.ok(songs);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).build();
        }
    }

    @PostMapping("/user/{userId}/follow/album/{albumId}")
    public ResponseEntity<Void> followAlbum(@PathVariable Long userId, @PathVariable Long albumId) {
        albumService.followAlbum(userId, albumId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/user/{userId}/follow/album/{albumId}")
    public ResponseEntity<Void> unfollowAlbum(@PathVariable Long userId, @PathVariable Long albumId) {
        albumService.unfollowAlbum(userId, albumId);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/user/{userId}/follow/album/{albumId}/check")
    public ResponseEntity<Boolean> isAlbumFollowed(@PathVariable Long userId, @PathVariable Long albumId) {
        return ResponseEntity.ok(albumService.isAlbumFollowed(userId, albumId));
    }
}