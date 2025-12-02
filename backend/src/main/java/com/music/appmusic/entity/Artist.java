package com.music.appmusic.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "artists")
public class Artist {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    @Column(name = "avatar_url")
    private String avatarUrl;
}