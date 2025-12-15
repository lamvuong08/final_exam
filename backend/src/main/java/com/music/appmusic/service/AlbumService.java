package com.music.appmusic.service;

import com.music.appmusic.entity.Album;
import com.music.appmusic.entity.User;
import com.music.appmusic.repository.AlbumRepository;
import com.music.appmusic.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AlbumService {

    private final AlbumRepository albumRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public Album getAlbumWithSongs(Long id) {
        Album album = albumRepository.findById(id).orElse(null);
        if (album != null) {
            album.getArtist(); // force load artist
            if (album.getSongs() != null) {
                album.getSongs().size(); // force load songs
            }
        }
        return album;
    }

    @Transactional
    public void followAlbum(Long userId, Long albumId) {
        User user = getUserOrThrow(userId);
        Album album = getAlbumOrThrow(albumId);
        user.getFollowedAlbums().add(album);
        userRepository.saveAndFlush(user);
    }

    @Transactional
    public void unfollowAlbum(Long userId, Long albumId) {
        User user = getUserOrThrow(userId);
        Album album = getAlbumOrThrow(albumId);
        user.getFollowedAlbums().remove(album);
        userRepository.saveAndFlush(user);
    }

    @Transactional(readOnly = true)
    public boolean isAlbumFollowed(Long userId, Long albumId) {
        User user = getUserOrThrow(userId);
        Album album = getAlbumOrThrow(albumId);
        return user.getFollowedAlbums().contains(album);
    }

    private User getUserOrThrow(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    private Album getAlbumOrThrow(Long albumId) {
        return albumRepository.findById(albumId)
                .orElseThrow(() -> new RuntimeException("Album not found"));
    }
}