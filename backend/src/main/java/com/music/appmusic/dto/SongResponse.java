package com.music.appmusic.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import com.music.appmusic.entity.Artist;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SongResponse {
    private Long id;
    private String title;
    private String coverImage; // ← THÊM DÒNG NÀY
    private String lyrics;
    private String filePath;
    private ArtistDTO artist;
    private Long playCount;
}
