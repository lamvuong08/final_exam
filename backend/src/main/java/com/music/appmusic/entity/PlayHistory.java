package com.music.appmusic.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Entity
@Table(
        name = "play_history",
        indexes = {
                @Index(name = "idx_user_song", columnList = "user_id, song_id"),
                @Index(name = "idx_song_played_at", columnList = "song_id, played_at"),
                @Index(name = "idx_played_at", columnList = "played_at")
        }
)
public class PlayHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "song_id", nullable = false)
    private Song song;

    @Column(name = "played_at", nullable = false)
    private LocalDateTime playedAt;

    @Column(name = "play_duration")
    private Integer playDuration;

    @Column(name = "play_progress")
    private Float playProgress;

    @PrePersist
    protected void onCreate() {
        this.playedAt = LocalDateTime.now();
    }
}