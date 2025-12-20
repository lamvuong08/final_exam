package com.music.appmusic.controller;

import com.music.appmusic.dto.AlbumDTO;
import com.music.appmusic.dto.ArtistDTO;
import com.music.appmusic.dto.SongDTO;
import com.music.appmusic.service.LibraryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = {
        "http://localhost:8080",
        "http://10.0.2.2:8080"
})
@RequiredArgsConstructor
public class LibraryController {

    private final LibraryService libraryService;

    @GetMapping("/user/{userId}/library/artists")
    public ResponseEntity<List<ArtistDTO>> getFollowedArtists(@PathVariable Long userId) {
        List<ArtistDTO> artists = libraryService.getFollowedArtists(userId);
        return ResponseEntity.ok(artists);
    }

    @GetMapping("/user/{userId}/library/albums")
    public ResponseEntity<List<AlbumDTO>> getFollowedAlbums(@PathVariable Long userId) {
        return ResponseEntity.ok(libraryService.getFollowedAlbums(userId));
    }

    @GetMapping("/user/{userId}/library/liked-songs")
    public ResponseEntity<List<SongDTO>> getLikedSongs(@PathVariable Long userId) {
        return ResponseEntity.ok(libraryService.getLikedSongs(userId));
    }

    @GetMapping("/user/{userId}/library/playlists")
    public ResponseEntity<List<Map<String, Object>>> getPlaylists(@PathVariable Long userId) {
        return ResponseEntity.ok(libraryService.getUserPlaylistsSummary(userId));
    }
}