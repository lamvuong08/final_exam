package com.music.appmusic.service;

import com.music.appmusic.dto.ProfileResponse;

public interface ProfileService {
    ProfileResponse getProfile(Long userId);
    boolean updateProfile(Long id, String username, String imageName);
    boolean changePassword(Long id, String oldPw, String newPw);
}
