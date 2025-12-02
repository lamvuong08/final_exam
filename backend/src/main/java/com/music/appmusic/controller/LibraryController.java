package com.music.appmusic.controller;

import com.music.appmusic.dto.LibraryResponse;
import com.music.appmusic.service.LibraryService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/library")
@RequiredArgsConstructor
@CrossOrigin("*")
public class LibraryController {

    private final LibraryService libraryService;

    @GetMapping("/{userId}")
    public LibraryResponse getLibrary(@PathVariable Long userId) {
        return libraryService.getLibrary(userId);
    }
}