package com.music.appmusic.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class SongDTO {
    private Long id;
    private String title;
    private String artist;
    private String thumbnail;
}