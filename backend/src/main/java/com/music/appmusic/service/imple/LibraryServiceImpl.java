package com.appmusic.service;

import com.appmusic.Repository.PlaylistRepository;
import com.appmusic.Repository.SongRepository;
import com.appmusic.model.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LibraryServiceImpl implements LibraryService {

    private final SongRepository songRepository;
    private final PlaylistRepository playlistRepository;

    @Override
    public LibraryResponse getUserLibrary(User user) {

        // lấy recent từ bảng songs, category = 'RECENT'
        List<SongItemDto> recentSongs = songRepository.findByCategory("RECENT")
                .stream()
                .map(s -> SongItemDto.builder()
                        .title(s.getTitle())
                        .artist(s.getArtist())
                        .build())
                .toList();

        // liked từ bảng songs, category = 'LIKED'
        List<SongItemDto> likedSongs = songRepository.findByCategory("LIKED")
                .stream()
                .map(s -> SongItemDto.builder()
                        .title(s.getTitle())
                        .artist(s.getArtist())
                        .build())
                .toList();

        // playlists: chỉ lấy tên
        List<String> playlists = playlistRepository.findAll()
                .stream()
                .map(Playlist::getName)
                .toList();

        return LibraryResponse.builder()
                .recentSongs(recentSongs)
                .likedSongs(likedSongs)
                .playlists(playlists)
                .build();
    }
}
