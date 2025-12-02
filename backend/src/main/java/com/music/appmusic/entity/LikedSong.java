package com.music.appmusic.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "liked_songs")
public class LikedSong {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "song_id")
    private Long songId;
}