package com.music.appmusic.service;

import com.music.appmusic.entity.Content;
import com.music.appmusic.entity.PlayHistory;
import com.music.appmusic.entity.User;
import com.music.appmusic.repository.ContentRepository;
import com.music.appmusic.repository.PlayHistoryRepository;
import com.music.appmusic.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class PlayHistoryService {

    private final PlayHistoryRepository playHistoryRepository;
    private final ContentRepository contentRepository;
    private final UserRepository userRepository;

    @Transactional
    public void recordPlay(Long contentId, Long userId, Integer duration) {

        Content content = contentRepository.findById(contentId)
                .orElseThrow(() -> new RuntimeException("Content not found"));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Lưu lịch sử nghe
        PlayHistory playHistory = new PlayHistory();
        playHistory.setContent(content);
        playHistory.setUser(user);
        playHistory.setPlayDuration(duration);
        playHistory.setPlayProgress(100f);

        playHistoryRepository.save(playHistory);

        // Tăng play count
        content.setPlayCount(content.getPlayCount() + 1);
        contentRepository.save(content);
    }
}
