package com.music.appmusic.service;

import com.music.appmusic.entity.Artist;
import com.music.appmusic.entity.User;
import com.music.appmusic.repository.ArtistRepository;
import com.music.appmusic.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ArtistService {

    private final ArtistRepository artistRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public Artist getArtistWithSongs(Long id) {
        Artist artist = artistRepository.findById(id).orElse(null);
        if (artist != null && artist.getSongs() != null) {
            artist.getSongs().size(); // force load songs
        }
        return artist;
    }

    @Transactional
    public void followArtist(Long userId, Long artistId) {
        User user = getUserOrThrow(userId);
        Artist artist = getArtistOrThrow(artistId);
        user.getFollowedArtists().add(artist);
        userRepository.saveAndFlush(user);
    }

    @Transactional
    public void unfollowArtist(Long userId, Long artistId) {
        User user = getUserOrThrow(userId);
        Artist artist = getArtistOrThrow(artistId);
        user.getFollowedArtists().remove(artist);
        userRepository.saveAndFlush(user);
    }

    @Transactional(readOnly = true)
    public boolean isArtistFollowed(Long userId, Long artistId) {
        User user = getUserOrThrow(userId);
        Artist artist = getArtistOrThrow(artistId);
        return user.getFollowedArtists().contains(artist);
    }

    private User getUserOrThrow(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    private Artist getArtistOrThrow(Long artistId) {
        return artistRepository.findById(artistId)
                .orElseThrow(() -> new RuntimeException("Artist not found"));
    }
}