package com.music.appmusic.service;

import com.music.appmusic.entity.Song;
import com.music.appmusic.entity.Artist;
import com.music.appmusic.entity.Album;
import com.music.appmusic.repository.SongRepository;
import com.music.appmusic.repository.ArtistRepository;
import com.music.appmusic.repository.AlbumRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class LibraryService {

    @Autowired
    private SongRepository songRepository;

    @Autowired
    private ArtistRepository artistRepository;

    @Autowired
    private AlbumRepository albumRepository;

    public List<Artist> getAllArtists() {
        return artistRepository.findAll();
    }

    public List<Album> getAllAlbums() {
        return albumRepository.findAll();
    }

    public List<Song> getLikedSongsByUserId(Long userId) {
        return songRepository.findByLikedByUsers_Id(userId);
    }

    public long countLikedSongs(Long userId) {
        return songRepository.countByLikedByUsers_Id(userId);
    }
}