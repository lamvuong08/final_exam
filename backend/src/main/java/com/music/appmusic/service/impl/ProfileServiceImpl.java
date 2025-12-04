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

        if (newUsername != null && !newUsername.isBlank()) {
            user.setUsername(newUsername);
        }

        if (newImage != null && !newImage.isBlank()) {
            user.setProfileImage(newImage);
        }

        userRepo.save(user);
        return true;
    }

    @Override
    public boolean changePassword(Long id, String oldPw, String newPw) {

        User user = userRepo.findById(id).orElseThrow();

        // ✔️ So sánh mật khẩu oldPw với BCrypt trong DB
        if (!passwordEncoder.matches(oldPw, user.getPassword())) {
            log.warn("SAI MẬT KHẨU CŨ!");
            return false;
        }

        // ✔️ Mã hóa mật khẩu mới
        user.setPassword(passwordEncoder.encode(newPw));
        userRepo.save(user);

        return true;
    }
}