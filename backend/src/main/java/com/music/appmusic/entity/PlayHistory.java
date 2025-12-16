package com.music.appmusic.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Entity
@Table(
        name = "play_history",
        indexes = {
                @Index(name = "idx_user_content", columnList = "user_id, content_id"),
                @Index(name = "idx_content_played_at", columnList = "content_id, played_at"),
                @Index(name = "idx_played_at", columnList = "played_at")
        }
)
public class PlayHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Người nghe
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // Nội dung được phát (song / podcast / audiobook)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "content_id", nullable = false)
    private Content content;

    // Thời điểm phát
    @Column(name = "played_at", nullable = false)
    private LocalDateTime playedAt;

    // Tổng số giây đã nghe
    @Column(name = "play_duration")
    private Integer playDuration;

    // % đã nghe (0 → 100)
    @Column(name = "play_progress")
    private Float playProgress;

    @PrePersist
    protected void onCreate() {
        this.playedAt = LocalDateTime.now();
    }
}
