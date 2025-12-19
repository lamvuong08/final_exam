package com.music.appmusic.repository;

import com.music.appmusic.entity.PlayHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PlayHistoryRepository extends JpaRepository<PlayHistory, Long> {
    List<PlayHistory> findTop5ByUser_IdOrderByPlayedAtDesc(Long userId);
}