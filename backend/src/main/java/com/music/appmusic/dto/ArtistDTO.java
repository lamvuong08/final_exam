package com.music.appmusic.dto;

import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ArtistDTO {
    private Long id;
    private String name;
    private String avatarUrl;
}