package com.music.appmusic.dto;

import lombok.Data;

import com.music.appmusic.entity.Artist;
@Data
public class SongResponse {
    private Long id;
    private String title;
    private String coverImage; // ← THÊM DÒNG NÀY
    private ArtistDTO artist;
    private Long playCount;
}
