package com.appmusic.Repository;

import com.appmusic.model.Song;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SongRepository extends JpaRepository<Song, Long> {

    // lấy theo category: RECENT hoặc LIKED
    List<Song> findByCategory(String category);
}
