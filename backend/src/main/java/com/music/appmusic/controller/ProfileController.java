package com.music.appmusic.controller;

import com.music.appmusic.dto.ProfileResponse;
import com.music.appmusic.service.ProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

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

    // -------------------- UPDATE PROFILE (JSON) --------------------
    @PutMapping("/update")
    public boolean updateProfile(@RequestBody Map<String, Object> body) {

        Long id = Long.valueOf(body.get("id").toString());

        String newName = body.get("username") != null
                ? body.get("username").toString()
                : null;

        String newImage = body.get("profileImage") != null
                ? body.get("profileImage").toString()
                : null;

        return profileService.updateProfile(id, newName, newImage);
    }

    // -------------------- CHANGE PASSWORD (JSON) --------------------
    @PutMapping("/change-password")
    public boolean changePassword(@RequestBody Map<String, Object> body) {

        Long id = Long.valueOf(body.get("id").toString());
        String oldPw = body.get("oldPw").toString();
        String newPw = body.get("newPw").toString();

        return profileService.changePassword(id, oldPw, newPw);
    }
}