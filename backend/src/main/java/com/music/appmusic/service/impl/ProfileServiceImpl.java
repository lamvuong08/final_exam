package com.music.appmusic.service.impl;

import com.music.appmusic.dto.ProfileResponse;
import com.music.appmusic.entity.User;
import com.music.appmusic.repository.UserRepository;
import com.music.appmusic.service.ProfileService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProfileServiceImpl implements ProfileService {

    private final UserRepository userRepo;
    private final BCryptPasswordEncoder passwordEncoder;

    private static final String UPLOAD_DIR = "C:/uploads/";

    @Override
    public ProfileResponse getProfile(Long userId) {

        User user = userRepo.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        String image = user.getProfileImage();
        if (image != null && !image.isBlank()) {
            image = "http://10.0.2.2:8080/uploads/" + image;
        }

        return ProfileResponse.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .profileImage(image)
                .build();
    }

    @Override
    public boolean updateProfile(Long id, String newUsername, String newImage) {

        User user = userRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));

        boolean updated = false;

        if (newUsername != null && !newUsername.isBlank()) {
            user.setUsername(newUsername);
            updated = true;
        }

        if (newImage != null && !newImage.isBlank()) {
            user.setProfileImage(newImage);
            updated = true;
        }

        if (updated) {
            userRepo.save(user);
        }

        return true;
    }

    @Override
    public boolean updateProfileWithImage(Long id, String username, MultipartFile image) {

        String imageName = null;

        if (image != null && !image.isEmpty()) {

            if (!image.getContentType().startsWith("image/")) {
                throw new RuntimeException("File upload không phải ảnh");
            }

            File dir = new File(UPLOAD_DIR);
            if (!dir.exists()) dir.mkdirs();

            String original = image.getOriginalFilename();
            String ext = original.substring(original.lastIndexOf("."));
            imageName = "user_" + id + "_" + System.currentTimeMillis() + ext;

            try {
                image.transferTo(new File(UPLOAD_DIR + imageName));
            } catch (Exception e) {
                throw new RuntimeException("Lỗi khi lưu ảnh");
            }
        }

        return updateProfile(id, username, imageName);
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