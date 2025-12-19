package com.music.appmusic.service;

import com.music.appmusic.entity.Song;
import com.music.appmusic.repository.SongRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@Service
public class LyricsService {

    @Value("${lyrics.base-path}")
    private String basePath;

    private final SongRepository songRepository;

    public LyricsService(SongRepository songRepository) {
        this.songRepository = songRepository;
    }

    public String getLyricsBySongId(Long songId) {
        Song song = songRepository.findById(songId)
                .orElseThrow(() -> new RuntimeException("Song not found"));

        String fileName = song.getLyrics(); // anti_hero.lrc

        if (fileName == null || fileName.isBlank()) {
            return null;
        }

        Path path = Paths.get(basePath, fileName);

        try {
            return Files.readString(path);
        } catch (IOException e) {
            throw new RuntimeException("Cannot read lyrics file: " + path, e);
        }
    }
}