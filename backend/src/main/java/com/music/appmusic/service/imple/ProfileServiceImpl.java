package com.appmusic.service;

import com.appmusic.model.ProfileResponse;
import com.appmusic.model.User;
import org.springframework.stereotype.Service;

@Service
public class ProfileServiceImpl implements ProfileService {

    @Override
    public ProfileResponse getProfile(User user) {
        return ProfileResponse.builder()
                .userName(user.getFullName() != null ? user.getFullName() : user.getUsername())
                .userEmail(user.getEmail())
                .plan(user.getPlan() != null ? user.getPlan() : "Free plan")
                .build();
    }
}
