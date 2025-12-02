package com.music.appmusic.service;

import com.music.appmusic.dto.LibraryResponse;

public interface LibraryService {
    LibraryResponse getLibrary(Long userId);

    boolean removeFavoriteArtist(Long userId, Long artistId);
}