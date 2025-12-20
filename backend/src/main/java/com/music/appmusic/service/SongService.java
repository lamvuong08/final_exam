package com.music.appmusic.service;

import com.music.appmusic.dto.SongResponse;
import java.util.List;

public interface SongService {
    List<SongResponse> getTrendingSongs();
    String getNewMusicMessage();
    List<SongResponse> getSongsByArtistId(Long artistId);
    List<SongResponse> getSongsByAlbumId(Long albumId);
    boolean isSongLiked(Long userId, Long songId);
    void likeSong(Long userId, Long songId);
    void unlikeSong(Long userId, Long songId);
    SongResponse getSongById(Long songId);
    List<SongResponse> getRandomSongs(int count);
    List<SongResponse> getSongsByAlbum(Long albumId);
    List<SongResponse> getRecentlyPlayedSongs(Long userId);
}