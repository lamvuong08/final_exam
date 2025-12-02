package com.music.appmusic.service.impl;

import com.music.appmusic.dto.ProfileResponse;
import com.music.appmusic.entity.User;
import com.music.appmusic.repository.UserRepository;
import com.music.appmusic.service.ProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ProfileServiceImpl implements ProfileService {

    private final UserRepository userRepo;

    @Override
    public ProfileResponse getProfile(Long userId) {

        User user = userRepo.findById(userId).orElseThrow();

        return ProfileResponse.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .profileImage(user.getProfileImage())
                .build();
    }

    @Override
    public boolean updateProfile(Long id, String newUsername, String newImage) {

        User user = userRepo.findById(id).orElseThrow();

        if (newUsername != null && !newUsername.isEmpty()) {
            user.setUsername(newUsername);
        }

        if (newImage != null && !newImage.isEmpty()) {
            user.setProfileImage(newImage);
        }

        userRepo.save(user);
        return true;
    }

    @Override
    public boolean changePassword(Long id, String oldPw, String newPw) {
        User user = userRepo.findById(id).orElseThrow();

        if (!user.getPassword().equals(oldPw)) {
            return false;
        }

        user.setPassword(newPw);
        userRepo.save(user);
        return true;
    }
}