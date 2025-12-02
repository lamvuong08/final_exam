package com.appmusic.Repository;

import com.appmusic.model.Song;
import com.appmusic.model.SongItemDto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface SongRepository extends JpaRepository<Song, Long> {

    // Lấy bài hát RECENT
    @Query("""
            SELECT new com.appmusic.model.SongItemDto(s.title, s.artist)
            FROM Song s
            WHERE s.category = 'RECENT'
            """)
    List<SongItemDto> findRecentSongs();

    // Lấy bài hát LIKED
    @Query("""
            SELECT new com.appmusic.model.SongItemDto(s.title, s.artist)
            FROM Song s
            WHERE s.category = 'LIKED'
            """)
    List<SongItemDto> findLikedSongs();
}