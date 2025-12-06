// com.music.appmusic.controller.MusicController.java
package com.music.appmusic.controller;

import com.music.appmusic.dto.SongResponse; // ← THAY ĐỔI IMPORT
import com.music.appmusic.service.SongService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/music")
@CrossOrigin(origins = "*")
public class MusicController {

    @Autowired
    private SongService songService;

    @GetMapping("/trending")
    public ResponseEntity<List<SongResponse>> getTrendingSongs() { // ← ĐỔI KIỂU
        return ResponseEntity.ok(songService.getTrendingSongs());
    }

    @GetMapping("/new-music")
    public ResponseEntity<String> getNewMusicMessage() {
        return ResponseEntity.ok(songService.getNewMusicMessage());
    }
}