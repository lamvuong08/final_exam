package com.appmusic.service;

import com.appmusic.model.ProfileResponse;
import com.appmusic.model.User;

public interface ProfileService {
    ProfileResponse getProfile(User user);
}
