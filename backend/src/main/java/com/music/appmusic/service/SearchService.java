package com.music.appmusic.service;

import com.music.appmusic.entity.Album;
import com.music.appmusic.entity.Artist;
import com.music.appmusic.entity.Song;
import com.music.appmusic.repository.AlbumRepository;
import com.music.appmusic.repository.ArtistRepository;
import com.music.appmusic.repository.SongRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class SearchService {

    private final SongRepository songRepository;
    private final AlbumRepository albumRepository;
    private final ArtistRepository artistRepository;

    public Map<String, Object> search(String rawKeyword) {
        String keyword = rawKeyword == null ? "" : rawKeyword.trim();

        if (keyword.isEmpty()) {
            return Map.of(
                    "songs", Collections.emptyList(),
                    "albums", Collections.emptyList(),
                    "artists", Collections.emptyList()
            );
        }

        List<Song> songs = songRepository.searchByTitle(keyword);
        List<Album> albums = albumRepository.searchByTitle(keyword);
        List<Artist> artists = artistRepository.searchByName(keyword);

        Map<String, Object> response = new HashMap<>();
        response.put("songs", songs);
        response.put("albums", albums);
        response.put("artists", artists);

        return response;
    }
}

