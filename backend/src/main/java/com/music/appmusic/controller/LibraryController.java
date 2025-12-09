package com.music.appmusic.controller;

import com.music.appmusic.dto.*;
import com.music.appmusic.entity.Album;
import com.music.appmusic.entity.Artist;
import com.music.appmusic.service.AlbumService;
import com.music.appmusic.service.ArtistService;
import com.music.appmusic.service.LibraryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = {
        "http://localhost:8080",     // Web (nếu có)
        "http://10.0.2.2:8080"      // Android Emulator
})
public class LibraryController {

    @Autowired
    private LibraryService libraryService;
    @Autowired
    private AlbumService albumService;
    @Autowired
    private ArtistService artistService;

    // 1. Lấy tất cả nghệ sĩ
    @GetMapping("/artists")
    public ResponseEntity<List<ArtistDTO>> getAllArtists() {
        List<ArtistDTO> artists = libraryService.getAllArtists()
                .stream()
                .map(artist -> new ArtistDTO(
                        artist.getId(),
                        artist.getName(),
                        artist.getProfileImage()
                ))
                .collect(Collectors.toList());

        return ResponseEntity.ok(artists);
    }

    // 2. Lấy tất cả album
    @GetMapping("/albums")
    public ResponseEntity<List<AlbumDTO>> getAllAlbums() {
        List<AlbumDTO> albums = libraryService.getAllAlbums()
                .stream()
                .map(album -> {
                    Integer year = (album.getReleaseDate() != null)
                            ? album.getReleaseDate().getYear()
                            : null;
                    Integer count = (album.getSongs() != null)
                            ? album.getSongs().size()
                            : 0;

                    ArtistDTO artistDto = new ArtistDTO(
                            album.getArtist().getId(),
                            album.getArtist().getName(),
                            album.getArtist().getProfileImage()
                    );

                    return new AlbumDTO(
                            album.getId(),
                            album.getTitle(),
                            album.getCoverImage(),
                            year,
                            count,
                            artistDto
                    );
                })
                .collect(Collectors.toList());

        return ResponseEntity.ok(albums);
    }

    // 3. Lấy bài hát yêu thích của user
    @GetMapping("/user/{userId}/liked-songs")
    public ResponseEntity<List<SongDTO>> getLikedSongs(@PathVariable Long userId) {
        List<SongDTO> likedSongs = libraryService.getLikedSongsByUserId(userId)
                .stream()
                .map(song -> {
                    ArtistDTO artistDto = new ArtistDTO(
                            song.getArtist().getId(),
                            song.getArtist().getName(),
                            song.getArtist().getProfileImage()
                    );
                    return new SongDTO(
                            song.getId(),
                            song.getTitle(),
                            song.getCoverImage(),
                            artistDto
                    );
                })
                .collect(Collectors.toList());

        return ResponseEntity.ok(likedSongs);
    }

    @GetMapping("/user/{userId}/playlists")
    public ResponseEntity<List<Map<String, Object>>> getPlaylists(@PathVariable Long userId) {
        long likedSongCount = libraryService.countLikedSongs(userId);

        // Playlist "Liked Songs"
        Map<String, Object> likedPlaylist = Map.of(
                "id", "liked",
                "name", "Liked Songs",
                "isLiked", true,
                "songCount", likedSongCount
        );

        Map<String, Object> chillPlaylist = Map.of(
                "id", "chill123",
                "name", "Chill Vibes",
                "isLiked", false,
                "songCount", 24
        );

        return ResponseEntity.ok(List.of(likedPlaylist, chillPlaylist));
    }
    // 5. Lấy chi tiết album + bài hát
    @GetMapping("/albums/{id}")
    public ResponseEntity<Album> getAlbumDetail(@PathVariable Long id) {
        Album album = albumService.getAlbumWithSongs(id);
        if (album == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(album);
    }

    // 6. Lấy chi tiết artist + bài hát
    @GetMapping("/artists/{id}")
    public ResponseEntity<Artist> getArtistDetail(@PathVariable Long id) {
        Artist artist = artistService.getArtistWithSongs(id);
        if (artist == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(artist);
    }
}