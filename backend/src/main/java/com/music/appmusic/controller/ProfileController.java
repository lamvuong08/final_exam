package com.music.appmusic.controller;

import com.music.appmusic.dto.ProfileResponse;
import com.music.appmusic.service.ProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/profile")
@RequiredArgsConstructor
@CrossOrigin("*")
public class ProfileController {

    private final ProfileService profileService;

    @GetMapping("/{id}")
    public ProfileResponse getProfile(@PathVariable Long id) {
        return profileService.getProfile(id);
    }

    @PutMapping("/update")
    public boolean update(
            @RequestParam Long id,
            @RequestParam(required = false) String profileName,
            @RequestParam(required = false) String avatarUrl
    ) {
        return profileService.updateProfile(id, profileName, avatarUrl);
    }

    @PutMapping("/change-password")
    public boolean changePw(
            @RequestParam Long id,
            @RequestParam String oldPw,
            @RequestParam String newPw
    ) {
        return profileService.changePassword(id, oldPw, newPw);
    }
}