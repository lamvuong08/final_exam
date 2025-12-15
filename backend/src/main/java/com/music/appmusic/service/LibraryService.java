package com.music.appmusic.service;

import com.music.appmusic.dto.AlbumDTO;
import com.music.appmusic.dto.ArtistDTO;
import com.music.appmusic.dto.SongDTO;
import com.music.appmusic.entity.Album;
import com.music.appmusic.entity.Artist;
import com.music.appmusic.entity.Song;
import com.music.appmusic.entity.User;
import com.music.appmusic.repository.SongRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class LibraryService {

    @PersistenceContext
    private EntityManager entityManager;

    private final SongRepository songRepository;

    public List<Map<String, Object>> getUserPlaylistsSummary(Long userId) {
        long likedSongCount = songRepository.countByLikedByUsers_Id(userId);

        Map<String, Object> likedPlaylist = Map.of(
                "id", "liked",
                "name", "Liked Songs",
                "isLiked", true,
                "songCount", likedSongCount
        );

        Map<String, Object> recentPlaylist = Map.of(
                "id", "recent",
                "name", "Recently Played",
                "isLiked", false,
                "songCount", 0
        );

        return List.of(likedPlaylist, recentPlaylist);
    }

    public List<ArtistDTO> getFollowedArtists(Long userId) {
        User user = loadUser(userId);
        return user.getFollowedArtists()
                .stream()
                .map(this::toArtistDTO)
                .collect(Collectors.toList());
    }

    public List<AlbumDTO> getFollowedAlbums(Long userId) {
        User user = loadUser(userId);
        return user.getFollowedAlbums()
                .stream()
                .map(this::toAlbumDTO)
                .collect(Collectors.toList());
    }

    public List<SongDTO> getLikedSongs(Long userId) {
        return songRepository.findByLikedByUsers_Id(userId)
                .stream()
                .map(this::toSongDTO)
                .collect(Collectors.toList());
    }

    private User loadUser(Long userId) {
        User user = entityManager.find(User.class, userId);
        if (user == null) {
            throw new RuntimeException("User not found");
        }
        user.getFollowedArtists().size();
        user.getFollowedAlbums().size();
        return user;
    }

    private ArtistDTO toArtistDTO(Artist artist) {
        return ArtistDTO.builder()
                .id(artist.getId())
                .name(artist.getName())
                .profileImage(artist.getProfileImage())
                .build();
    }

    private AlbumDTO toAlbumDTO(Album album) {
        Integer year = album.getReleaseDate() != null ? album.getReleaseDate().getYear() : null;
        int songCount = album.getSongs() != null ? album.getSongs().size() : 0;
        ArtistDTO artistDto = toArtistDTO(album.getArtist());

        return AlbumDTO.builder()
                .id(album.getId())
                .title(album.getTitle())
                .coverImage(album.getCoverImage())
                .releaseYear(year)
                .songCount(songCount)
                .artist(artistDto)
                .build();
    }

    private SongDTO toSongDTO(Song song) {
        return SongDTO.builder()
                .id(song.getId())
                .title(song.getTitle())
                .coverImage(song.getCoverImage())
                .artist(toArtistDTO(song.getArtist()))
                .build();
    }
}