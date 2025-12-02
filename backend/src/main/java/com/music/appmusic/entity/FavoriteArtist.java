package com.music.appmusic.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "favorite_artists")
public class FavoriteArtist {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "artist_id")
    private Long artistId;
}