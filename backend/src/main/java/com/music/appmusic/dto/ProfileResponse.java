package com.music.appmusic.dto;

import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
@Data

public class ProfileResponse {
    private Long id;
    private String username;
    private String email;
    private String profileImage;
}