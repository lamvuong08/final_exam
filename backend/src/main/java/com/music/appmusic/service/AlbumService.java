package com.music.appmusic.service;

import com.music.appmusic.entity.Album;
import com.music.appmusic.repository.AlbumRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AlbumService {

    @Autowired
    private AlbumRepository albumRepository;

    @Transactional(readOnly = true)
    public Album getAlbumWithSongs(Long id) {
        // JpaRepository.findById() không fetch songs/artist eager → cần custom query
        // Nhưng bạn chưa có custom repo → tạm thời dùng cách an toàn sau:
        Album album = albumRepository.findById(id).orElse(null);
        if (album != null) {
            // Ép buộc lazy load bằng cách truy cập
            album.getArtist(); // force load artist
            if (album.getSongs() != null) {
                album.getSongs().size(); // force load songs
            }
        }
        return album;
    }
}