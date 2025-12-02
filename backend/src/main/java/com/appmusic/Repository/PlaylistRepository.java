package com.appmusic.Repository;

import com.appmusic.model.Playlist;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface PlaylistRepository extends JpaRepository<Playlist, Long> {

    @Query("SELECT p.name FROM Playlist p")
    List<String> findAllNames();
}