package com.appmusic.model;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SongItemDto {
    private String title;
    private String artist;
}
