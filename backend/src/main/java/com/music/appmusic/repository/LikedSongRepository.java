package com.music.appmusic.repository;

import com.music.appmusic.entity.LikedSong;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LikedSongRepository extends JpaRepository<LikedSong, Long> {
    List<LikedSong> findByUserId(Long userId);
}