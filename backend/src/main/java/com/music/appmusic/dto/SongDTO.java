package com.music.appmusic.dto;

import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class SongDTO {
    private Long id;
    private String title;
    private String coverImage;
    private ArtistDTO artist;
}