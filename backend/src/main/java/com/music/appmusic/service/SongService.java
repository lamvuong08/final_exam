package com.music.appmusic.service;

import com.music.appmusic.dto.ArtistDTO;
import com.music.appmusic.dto.SongResponse;
import com.music.appmusic.entity.Song;
import com.music.appmusic.entity.User;
import com.music.appmusic.repository.SongRepository;
import com.music.appmusic.repository.UserRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class SongService {

    @Autowired
    private SongRepository songRepository;

    @Autowired
    private UserRepository userRepository;

    public List<SongResponse> getTrendingSongs() {
        return songRepository.findTop5Trending().stream()
                .map(song -> {
                    SongResponse response = new SongResponse();
                    response.setId(song.getId());
                    response.setTitle(song.getTitle());
                    response.setCoverImage(song.getCoverImage());
                    response.setPlayCount(song.getPlayCount());

                    // Map Artist → ArtistDTO
                    if (song.getArtist() != null) {
                        ArtistDTO artistDto = new ArtistDTO();
                        artistDto.setId(song.getArtist().getId());
                        artistDto.setName(song.getArtist().getName());
                        response.setArtist(artistDto);
                    }

                    return response;
                })
                .collect(Collectors.toList());
    }

    public String getNewMusicMessage() {
        return "Tính năng 'Nghe nhạc mới nhất' đang được phát triển. Vui lòng quay lại sau!";
    }

    public List<SongResponse> getSongsByArtistId(Long artistId) {
        return songRepository.findByArtistId(artistId).stream()
                .map(this::convertToSongResponse)
                .collect(Collectors.toList());
    }
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
                .playCount(song.getPlayCount())
                .artist(artistDTO)
                .build();
    }

    public boolean isSongLiked(Long userId, Long songId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return user.getLikedSongs().stream()
                .anyMatch(song -> song.getId().equals(songId));
    }

    @Transactional
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

    @Transactional
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
}