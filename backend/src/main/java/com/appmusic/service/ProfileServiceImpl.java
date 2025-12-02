package com.appmusic.service;

import com.appmusic.model.ProfileResponse;
import com.appmusic.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ProfileServiceImpl implements ProfileService {

    @Override
    public ProfileResponse getProfile(User user) {
        return ProfileResponse.builder()
                .id(user.getId())
                .userName(user.getUsername())
                .userEmail(user.getEmail())
                .fullName(user.getFullName())
                .avatarUrl(user.getAvatarUrl())
                .plan("Free plan")
                .followers(1200)
                .following(30)
                .build();
    }
}