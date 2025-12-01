package com.appmusic.service;

import com.appmusic.model.LibraryResponse;
import com.appmusic.model.User;

public interface LibraryService {
    LibraryResponse getUserLibrary(User user);
}
