package com.music.appmusic.service;

import com.music.appmusic.entity.PlayHistory;
import com.music.appmusic.entity.Song;
import com.music.appmusic.entity.User;
import com.music.appmusic.repository.PlayHistoryRepository;
import com.music.appmusic.repository.SongRepository;
import com.music.appmusic.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class PlayHistoryService {

    private final PlayHistoryRepository playHistoryRepository;
    private final SongRepository songRepository;
    private final UserRepository userRepository;

    @Transactional
    public void recordPlay(Long contentId, Long userId, Integer duration) {

        Song song = songRepository.findById(contentId)
                .orElseThrow(() -> new RuntimeException("Song not found"));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        PlayHistory playHistory = new PlayHistory();
        playHistory.setSong(song);
        playHistory.setUser(user);
        playHistory.setPlayDuration(duration);
        playHistory.setPlayProgress(100f);
        playHistoryRepository.save(playHistory);
        song.setPlayCount(song.getPlayCount() + 1);
        songRepository.save(song);
    }
}