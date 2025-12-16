package com.music.appmusic.controller;

import com.music.appmusic.dto.PlayHistoryRequest;
import com.music.appmusic.service.PlayHistoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/play-history")
@RequiredArgsConstructor
public class PlayHistoryController {

    private final PlayHistoryService playHistoryService;

    @PostMapping
    public ResponseEntity<?> recordPlay(@RequestBody PlayHistoryRequest request) {

        playHistoryService.recordPlay(
                request.getContentId(),
                request.getUserId(),
                request.getDuration()
        );

        return ResponseEntity.ok().build();
    }
}
