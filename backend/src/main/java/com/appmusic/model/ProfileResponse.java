package com.appmusic.model;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProfileResponse {

    private Long id;
    private String userName;
    private String userEmail;
    private String fullName;
    private String avatarUrl;

    private String plan;      // Free / Premium (giả)
    private int followers;    // giả
    private int following;    // giả
}