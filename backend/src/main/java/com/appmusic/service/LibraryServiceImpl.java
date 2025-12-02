package com.appmusic.service;

import com.appmusic.Repository.PlaylistRepository;
import com.appmusic.Repository.SongRepository;
import com.appmusic.model.LibraryResponse;
import com.appmusic.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class LibraryServiceImpl implements LibraryService {

    private final SongRepository songRepository;
    private final PlaylistRepository playlistRepository;

    @Override
    public LibraryResponse getUserLibrary(User user) {

        return LibraryResponse.builder()
                .recentSongs(songRepository.findRecentSongs())
                .likedSongs(songRepository.findLikedSongs())
                .playlists(playlistRepository.findAllNames())
                .build();
    }
}