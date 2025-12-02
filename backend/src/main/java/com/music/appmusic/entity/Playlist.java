package com.music.appmusic.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "playlists")
public class Playlist {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // ⭐ Quan hệ playlist → user
    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    private String name;
}