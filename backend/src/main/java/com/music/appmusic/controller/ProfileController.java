package com.music.appmusic.controller;

import com.music.appmusic.dto.ProfileResponse;
import com.music.appmusic.service.ProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.util.Map;

@RestController
@RequestMapping("/api/profile")
@RequiredArgsConstructor
@CrossOrigin("*")
public class ProfileController {

    private final ProfileService profileService;

    private static final String UPLOAD_DIR = "C:/uploads/";

    // ================= GET PROFILE =================
    @GetMapping("/{id}")
    public ProfileResponse getProfile(@PathVariable Long id) {
        return profileService.getProfile(id);
    }

    // ================= UPDATE PROFILE (JSON) =================
    @PutMapping("/update")
    public boolean updateProfile(@RequestBody Map<String, Object> body) {

        Long id = Long.valueOf(body.get("id").toString());

        String newName = body.get("username") != null
                ? body.get("username").toString()
                : null;

        String newImage = body.get("profileImage") != null
                ? body.get("profileImage").toString()
                : null;

        return profileService.updateProfile(id, newName, newImage);
    }

    // ================= UPDATE PROFILE (WITH IMAGE) =================
    @PostMapping(
            value = "/update-with-image",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    public boolean updateProfileWithImage(
            @RequestParam Long id,
            @RequestParam(required = false) String username,
            @RequestParam(required = false) MultipartFile image
    ) {

        String imageUrl = null;

        if (image != null && !image.isEmpty()) {

            if (!image.getContentType().startsWith("image/")) {
                throw new RuntimeException("File upload không phải ảnh");
            }

            File dir = new File(UPLOAD_DIR);
            if (!dir.exists()) dir.mkdirs();

            String original = image.getOriginalFilename();
            String ext = original.substring(original.lastIndexOf("."));
            String imageName = "user_" + id + "_" + System.currentTimeMillis() + ext;

            try {
                image.transferTo(new File(UPLOAD_DIR + imageName));
                imageUrl = imageName;
            } catch (Exception e) {
                throw new RuntimeException("Lỗi khi lưu ảnh");
            }
        }

        return profileService.updateProfile(id, username, imageUrl);
    }

    // ================= CHANGE PASSWORD =================
    @PutMapping("/change-password")
    public boolean changePassword(@RequestBody Map<String, Object> body) {

        Long id = Long.valueOf(body.get("id").toString());
        String oldPw = body.get("oldPw").toString();
        String newPw = body.get("newPw").toString();

        return profileService.changePassword(id, oldPw, newPw);
    }
}