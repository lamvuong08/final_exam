package com.music.appmusic.service.impl;

import com.music.appmusic.dto.ProfileResponse;
import com.music.appmusic.entity.User;
import com.music.appmusic.repository.UserRepository;
import com.music.appmusic.service.ProfileService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProfileServiceImpl implements ProfileService {

    private final UserRepository userRepo;
    private final BCryptPasswordEncoder passwordEncoder;

    @Override
    public ProfileResponse getProfile(Long userId) {
        log.info("===== GET PROFILE =====");
        log.info("UserID requested: {}", userId);

        User user = userRepo.findById(userId).orElseThrow(() -> {
            log.warn("User with ID {} not found", userId);
            return new RuntimeException("User not found");
        });

        String image = user.getProfileImage();
        log.info("Raw profileImage from DB: {}", image);

        if (image != null && !image.isBlank()) {
            image = "http://10.0.2.2:8080/uploads/" + image;
            log.info("Full URL profileImage: {}", image);
        } else {
            log.info("User has no profileImage");
        }

        ProfileResponse response = ProfileResponse.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .profileImage(image)
                .build();

        log.info("ProfileResponse prepared: {}", response);
        log.info("=======================");
        return response;
    }

    @Override
    public boolean updateProfile(Long id, String newUsername, String newImage) {

        User user = userRepo.findById(id).orElseThrow(() -> {
            return new RuntimeException("User not found");
        });

        boolean updated = false;

        if (newUsername != null && !newUsername.isBlank()) {
            user.setUsername(newUsername);
            updated = true;
        } else {
            log.info("Username not changed");
        }

        if (newImage != null && !newImage.isBlank()) {
            user.setProfileImage(newImage);
            updated = true;
        } else {
            log.info("ProfileImage not changed");
        }

        if (updated) {
            userRepo.save(user);
            log.info("User updated successfully");
        } else {
            log.info("Nothing to update");
        }
        return true;
    }

    @Override
    public boolean changePassword(Long id, String oldPw, String newPw) {

        User user = userRepo.findById(id).orElseThrow(() -> {
            return new RuntimeException("User not found");
        });

        if (!passwordEncoder.matches(oldPw, user.getPassword())) {
            return false;
        }

        user.setPassword(passwordEncoder.encode(newPw));
        userRepo.save(user);
        return true;
    }
}