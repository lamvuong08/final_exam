package com.music.appmusic.repository;

import com.music.appmusic.entity.Song;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SongRepository extends JpaRepository<Song, Long> {

    @Query("SELECT s FROM Song s ORDER BY s.playCount DESC LIMIT 5")
    List<Song> findTop5Trending();
}