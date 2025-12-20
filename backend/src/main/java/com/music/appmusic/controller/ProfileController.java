package com.music.appmusic.controller;

import com.music.appmusic.dto.ProfileResponse;
import com.music.appmusic.service.ProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@RestController
@RequestMapping("/api/profile")
@RequiredArgsConstructor
@CrossOrigin("*")
public class ProfileController {

    private final ProfileService profileService;

    // ============ GET PROFILE ============
    @GetMapping("/{id}")
    public ProfileResponse getProfile(@PathVariable Long id) {
        return profileService.getProfile(id);
    }

    // ============ UPDATE PROFILE (JSON) ============
    @PutMapping("/update")
    public boolean updateProfile(@RequestBody Map<String, Object> body) {

        Long id = Long.valueOf(body.get("id").toString());
        String username = body.get("username") != null
                ? body.get("username").toString()
                : null;
        String image = body.get("profileImage") != null
                ? body.get("profileImage").toString()
                : null;

        return profileService.updateProfile(id, username, image);
    }

    // ============ UPDATE PROFILE (WITH IMAGE) ============
    @PostMapping(
            value = "/update-with-image",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    public boolean updateProfileWithImage(
            @RequestParam Long id,
            @RequestParam(required = false) String username,
            @RequestParam(required = false) MultipartFile image
    ) {
        return profileService.updateProfileWithImage(id, username, image);
    }

    // ============ CHANGE PASSWORD ============
    @PutMapping("/change-password")
    public boolean changePassword(@RequestBody Map<String, Object> body) {

        Long id = Long.valueOf(body.get("id").toString());
        String oldPw = body.get("oldPw").toString();
        String newPw = body.get("newPw").toString();

        return profileService.changePassword(id, oldPw, newPw);
    }
}