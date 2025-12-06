// com.music.appmusic.service.SongService.java
package com.music.appmusic.service;

import com.music.appmusic.dto.ArtistDTO;
import com.music.appmusic.dto.SongResponse;
import com.music.appmusic.entity.Song;
import com.music.appmusic.repository.SongRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class SongService {

    @Autowired
    private SongRepository songRepository;

    // ✅ Đổi kiểu trả về
    public List<SongResponse> getTrendingSongs() {
        return songRepository.findTop5Trending().stream()
                .map(song -> {
                    SongResponse response = new SongResponse();
                    response.setId(song.getId());
                    response.setTitle(song.getTitle());
                    response.setCoverImage(song.getCoverImage());
                    response.setPlayCount(song.getPlayCount());

                    // Map Artist → ArtistDTO
                    if (song.getArtist() != null) {
                        ArtistDTO artistDto = new ArtistDTO();
                        artistDto.setId(song.getArtist().getId());
                        artistDto.setName(song.getArtist().getName());
                        response.setArtist(artistDto);
                    }

                    return response;
                })
                .collect(Collectors.toList());
    }

    public String getNewMusicMessage() {
        return "Tính năng 'Nghe nhạc mới nhất' đang được phát triển. Vui lòng quay lại sau!";
    }
}