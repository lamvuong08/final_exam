package com.music.appmusic.controller;

import com.music.appmusic.service.ArtistService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class ArtistController {

    private final ArtistService artistService;

    @PostMapping("/user/{userId}/follow/artist/{artistId}")
    public ResponseEntity<Void> followArtist(@PathVariable Long userId, @PathVariable Long artistId) {
        artistService.followArtist(userId, artistId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/user/{userId}/follow/artist/{artistId}")
    public ResponseEntity<Void> unfollowArtist(@PathVariable Long userId, @PathVariable Long artistId) {
        artistService.unfollowArtist(userId, artistId);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/user/{userId}/follow/artist/{artistId}/check")
    public ResponseEntity<Boolean> isArtistFollowed(@PathVariable Long userId, @PathVariable Long artistId) {
        return ResponseEntity.ok(artistService.isArtistFollowed(userId, artistId));
    }
}

