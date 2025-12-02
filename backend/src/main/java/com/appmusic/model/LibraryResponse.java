package com.appmusic.model;

import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LibraryResponse {
    private List<SongItemDto> recentSongs;
    private List<SongItemDto> likedSongs;
    private List<String> playlists;
}
