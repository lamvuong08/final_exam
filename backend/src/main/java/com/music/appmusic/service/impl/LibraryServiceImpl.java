package com.music.appmusic.service.impl;

import com.music.appmusic.dto.ArtistDTO;
import com.music.appmusic.dto.PlaylistDTO;
import com.music.appmusic.dto.SongDTO;
import com.music.appmusic.dto.LibraryResponse;
import com.music.appmusic.entity.User;
import com.music.appmusic.repository.UserRepository;
import com.music.appmusic.service.LibraryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class LibraryServiceImpl implements LibraryService {

    private final UserRepository userRepo;

    @Override
    public LibraryResponse getLibrary(Long userId) {
        User user = userRepo.findById(userId).orElseThrow();

        return LibraryResponse.builder()
                .likedSongs(
                        user.getLikedSongs().stream()
                                .map(song -> SongDTO.builder()
                                        .id(song.getId())
                                        .title(song.getTitle())
                                        .artist(song.getArtist())
                                        .thumbnail(song.getThumbnail())
                                        .build())
                                .collect(Collectors.toList())
                )
                .favoriteArtists(
                        user.getFavoriteArtists().stream()
                                .map(a -> new ArtistDTO(a.getId(), a.getName(), a.getAvatarUrl()))
                                .collect(Collectors.toList())
                )
                .playlists(
                        user.getPlaylists().stream()
                                .map(p -> new PlaylistDTO(p.getId(), p.getName()))
                                .collect(Collectors.toList())
                )
                .build();
    }

    @Override
    public boolean removeFavoriteArtist(Long userId, Long artistId) {
        User user = userRepo.findById(userId).orElseThrow();
        user.getFavoriteArtists().removeIf(a -> a.getId().equals(artistId));
        userRepo.save(user);
        return true;
    }
}