package com.music.appmusic.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserResponse {
    private long id;
    private String username;
    private String email;
    private String profileImage;

    public UserResponse(long id, String username, String email, String profileImage) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.profileImage = profileImage;
    }
}
