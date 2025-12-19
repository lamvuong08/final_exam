package com.music.appmusic.service.impl;

import com.music.appmusic.dto.ArtistDTO;
import com.music.appmusic.dto.SongResponse;
import com.music.appmusic.entity.Content;
import com.music.appmusic.entity.PlayHistory;
import com.music.appmusic.entity.Song;
import com.music.appmusic.entity.User;
import com.music.appmusic.repository.*;
import com.music.appmusic.service.SongService;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class SongServiceImpl implements SongService {

    @Autowired
    private SongRepository songRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PlayHistoryRepository playHistoryRepository;

    // --- Các phương thức cũ ---
    @Override
    public List<SongResponse> getTrendingSongs() {
        return songRepository.findTop5Trending().stream()
                .map(song -> convertToSongResponse(song))
                .collect(Collectors.toList());
    }

    @Override
    public String getNewMusicMessage() {
        return "Tính năng 'Nghe nhạc mới nhất' đang được phát triển. Vui lòng quay lại sau!";
    }

    @Override
    public List<SongResponse> getSongsByArtistId(Long artistId) {
        return songRepository.findByArtistId(artistId).stream()
                .map(this::convertToSongResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<SongResponse> getSongsByAlbumId(Long albumId) {
        return songRepository.findByAlbumId(albumId).stream()
                .map(this::convertToSongResponse)
                .collect(Collectors.toList());
    }

    private SongResponse convertToSongResponse(Song song) {
        ArtistDTO artistDTO = ArtistDTO.builder()
                .id(song.getArtist().getId())
                .name(song.getArtist().getName())
                .profileImage(song.getArtist().getProfileImage())
                .build();

        return SongResponse.builder()
                .id(song.getId())
                .title(song.getTitle())
                .coverImage(song.getCoverImage())
                .filePath(song.getFilePath())
                .lyrics(song.getLyrics())
                .playCount(song.getPlayCount())
                .artist(artistDTO)
                .build();
    }

    @Override
    public boolean isSongLiked(Long userId, Long songId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return user.getLikedSongs().stream()
                .anyMatch(song -> song.getId().equals(songId));
    }

    @Override
    public void likeSong(Long userId, Long songId) {
        Song song = songRepository.findById(songId)
                .orElseThrow(() -> new RuntimeException("Song not found"));
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (!user.getLikedSongs().contains(song)) {
            user.getLikedSongs().add(song);
            userRepository.save(user);
        }
    }

    @Override
    public void unlikeSong(Long userId, Long songId) {
        Song song = songRepository.findById(songId)
                .orElseThrow(() -> new RuntimeException("Song not found"));
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (user.getLikedSongs().contains(song)) {
            user.getLikedSongs().remove(song);
            userRepository.save(user);
        }
    }

    @Override
    public SongResponse getSongById(Long songId) {
        Song song = songRepository.findById(songId)
                .orElseThrow(() -> new RuntimeException("Song not found"));

        return convertToSongResponse(song);
    }

    // --- Các phương thức mới ---
    @Override
    public List<SongResponse> getRandomSongs(int count) {
        List<Song> allSongs = songRepository.findAll();
        Collections.shuffle(allSongs);
        if (allSongs.size() > count) {
            allSongs = allSongs.subList(0, count);
        }
        return allSongs.stream()
                .map(this::convertToSongResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<SongResponse> getSongsByAlbum(Long albumId) {
        return songRepository.findByAlbumId(albumId).stream()
                .map(this::convertToSongResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<SongResponse> getRecentlyPlayedSongs(Long userId) {
        return playHistoryRepository.findTop5ByUser_IdOrderByPlayedAtDesc(userId).stream()
                .map(history -> convertToSongResponse(history.getSong()))
                .collect(Collectors.toList());
    }
}
