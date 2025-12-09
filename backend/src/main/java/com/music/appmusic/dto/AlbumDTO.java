package com.music.appmusic.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AlbumDTO {
    private Long id;
    private String title;
    private String coverImage;
    private Integer releaseYear;
    private Integer songCount;
    private ArtistDTO artist;
}