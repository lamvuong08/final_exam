package com.appmusic.controller;

import com.appmusic.Repository.UserRepository;
import com.appmusic.model.ProfileResponse;
import com.appmusic.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/profile")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ProfileController {

    private final UserRepository userRepository;

    // ===================== GET PROFILE =====================
    @GetMapping("/{id}")
    public ProfileResponse getProfile(@PathVariable Long id) {

        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));

        return ProfileResponse.builder()
                .id(user.getId())
                .userName(user.getUsername())
                .userEmail(user.getEmail())
                .fullName(user.getFullName())
                .avatarUrl(user.getAvatarUrl() == null || user.getAvatarUrl().isEmpty()
                        ? "https://cdn-icons-png.flaticon.com/512/3177/3177440.png"
                        : user.getAvatarUrl())
                .plan("Free plan")
                .followers(1200)
                .following(30)
                .build();
    }

    // ===================== UPDATE PROFILE =====================
    @PutMapping("/update")
    public String updateProfile(@RequestBody User req) {

        User user = userRepository.findById(req.getId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (req.getFullName() != null)
            user.setFullName(req.getFullName());

        if (req.getAvatarUrl() != null)
            user.setAvatarUrl(req.getAvatarUrl());

        userRepository.save(user);

        return "Profile updated";
    }

    // ===================== CHANGE PASSWORD =====================
    @PutMapping("/change-password")
    public String changePassword(
            @RequestParam Long id,
            @RequestParam String oldPw,
            @RequestParam String newPw) {

        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (!user.getPassword().equals(oldPw)) {
            return "Old password incorrect";
        }

        user.setPassword(newPw);
        userRepository.save(user);

        return "Password changed";
    }
}