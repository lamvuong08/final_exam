package com.music.appmusic.dto;

import lombok.Builder;
import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class LibraryResponse {
    private List<SongDTO> likedSongs;
    private List<ArtistDTO> favoriteArtists;
    private List<PlaylistDTO> playlists;
}