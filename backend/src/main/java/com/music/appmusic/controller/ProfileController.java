package com.appmusic.controller;

import com.appmusic.Repository.UserRepository;
import com.appmusic.model.ProfileResponse;
import com.appmusic.model.User;
import com.appmusic.service.ProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/profile")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ProfileController {

    private final ProfileService profileService;
    private final UserRepository userRepository;

    @GetMapping
    public ProfileResponse getProfile() {
        // tạm luôn lấy user id = 1
        User user = userRepository.findById(1L)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return profileService.getProfile(user);
    }
}
