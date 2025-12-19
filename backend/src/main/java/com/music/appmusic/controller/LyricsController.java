package com.music.appmusic.controller;

import com.music.appmusic.service.LyricsService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/lyrics")
public class LyricsController {

    private final LyricsService lyricsService;

    public LyricsController(LyricsService lyricsService) {
        this.lyricsService = lyricsService;
    }

    @GetMapping("/{songId}")
    public ResponseEntity<?> getLyrics(@PathVariable Long songId) {
        String lyrics = lyricsService.getLyricsBySongId(songId);

        if (lyrics == null || lyrics.isBlank()) {
            return ResponseEntity.noContent().build();
        }

        return ResponseEntity.ok(
                Map.of("lyrics", lyrics)
        );
    }
}
