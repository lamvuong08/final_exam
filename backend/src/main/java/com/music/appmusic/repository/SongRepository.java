package com.music.appmusic.repository;

import com.music.appmusic.entity.Song;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SongRepository extends JpaRepository<Song, Long> {

    @Query("SELECT s FROM Song s ORDER BY s.playCount DESC LIMIT 5")
    List<Song> findTop5Trending();

    List<Song> findByLikedByUsers_Id(Long userId);
    Long countByLikedByUsers_Id(Long userId);

    List<Song> findByArtistId(Long artistId);

    List<Song> findByAlbumId(Long albumId);

    @Query("SELECT s FROM Song s WHERE LOWER(s.title) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<Song> searchByTitle(@Param("keyword") String keyword);

    @Query("SELECT CASE WHEN COUNT(u) > 0 THEN true ELSE false END " +
            "FROM Song s JOIN s.likedByUsers u " +
            "WHERE s.id = :songId AND u.id = :userId")
    boolean isLikedByUser(Long songId, Long userId);
}