package com.music.appmusic.service;

import com.music.appmusic.dto.ProfileResponse;
import org.springframework.web.multipart.MultipartFile;

public interface ProfileService {
    ProfileResponse getProfile(Long userId);
    boolean updateProfile(Long id, String username, String imageName);
    boolean updateProfileWithImage(Long id, String username, MultipartFile image);
    boolean changePassword(Long id, String oldPw, String newPw);
}
