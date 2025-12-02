package com.music.appmusic.repository;

import com.music.appmusic.entity.FavoriteArtist;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface FavoriteArtistRepository extends JpaRepository<FavoriteArtist, Long> {
    List<FavoriteArtist> findByUserId(Long userId);
}