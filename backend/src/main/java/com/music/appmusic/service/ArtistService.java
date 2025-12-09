package com.music.appmusic.service;

import com.music.appmusic.entity.Artist;
import com.music.appmusic.repository.ArtistRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ArtistService {

    @Autowired
    private ArtistRepository artistRepository;

    @Transactional(readOnly = true)
    public Artist getArtistWithSongs(Long id) {
        Artist artist = artistRepository.findById(id).orElse(null);
        if (artist != null) {
            // Force load songs if exists
            if (artist.getSongs() != null) {
                artist.getSongs().size();
            }
        }
        return artist;
    }
}