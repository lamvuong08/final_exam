package com.music.appmusic.controller;

import com.music.appmusic.dto.SongResponse;
import com.music.appmusic.service.SongService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/albums")
@CrossOrigin(origins = "*")
public class AlbumController {

    @Autowired
    private SongService songService; // ← DÙNG SongService, không phải AlbumService

    @GetMapping("/{albumId}/songs")
    public ResponseEntity<List<SongResponse>> getSongsByAlbum(@PathVariable Long albumId) {
        try {
            List<SongResponse> songs = songService.getSongsByAlbumId(albumId);
            return ResponseEntity.ok(songs);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).build();
        }
    }
}