package com.music.appmusic.dto;

import lombok.Data;

@Data
public class PlayHistoryRequest {
    private Long contentId;
    private Long userId;
    private Integer duration;
}
