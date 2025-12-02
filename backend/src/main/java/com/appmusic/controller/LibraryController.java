package com.appmusic.controller;

import com.appmusic.Repository.UserRepository;
import com.appmusic.model.LibraryResponse;
import com.appmusic.model.User;
import com.appmusic.service.LibraryService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/library")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class LibraryController {

    private final LibraryService libraryService;
    private final UserRepository userRepository;

    @GetMapping("/{id}")
    public LibraryResponse getUserLibrary(@PathVariable Long id) {

        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));

        return libraryService.getUserLibrary(user);
    }
}