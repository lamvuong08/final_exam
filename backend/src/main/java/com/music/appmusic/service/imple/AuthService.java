package com.music.appmusic.service.imple;

import com.music.appmusic.dto.UserDTO;
import com.music.appmusic.dto.UserResponse;
import com.music.appmusic.entity.User;
import com.music.appmusic.repository.UserRepository;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.util.concurrent.ConcurrentHashMap;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder;
    private final JavaMailSender mailSender; // 👈 Thêm dependency này

    // Lưu trữ OTP tạm thời (trong production nên dùng Redis)
    private final ConcurrentHashMap<String, String> otpStore = new ConcurrentHashMap<>();

    // =============== ĐĂNG KÝ ===============
    public UserResponse register(UserDTO dto) {
        if (userRepository.existsByEmail(dto.getEmail())) {
            throw new RuntimeException("Email already exists");
        }
        if (userRepository.existsByUsername(dto.getUsername())) {
            throw new RuntimeException("Username already exists");
        }

        User user = new User();
        user.setUsername(dto.getUsername());
        user.setEmail(dto.getEmail());
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        user.setProfileImage(null);

        User saved = userRepository.save(user);

        return new UserResponse(
                saved.getId(),
                saved.getUsername(),
                saved.getEmail(),
                saved.getProfileImage()
        );
    }

    // =============== ĐĂNG NHẬP ===============
    public UserResponse login(String usernameOrEmail, String password) {
        User user = userRepository.findByEmail(usernameOrEmail);
        if (user == null) {
            user = userRepository.findByUsername(usernameOrEmail);
        }
        if (user == null) {
            throw new RuntimeException("Tài khoản không tồn tại");
        }
        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new RuntimeException("Mật khẩu không đúng");
        }

        return new UserResponse(
                user.getId(),
                user.getUsername(),
                user.getEmail(),
                user.getProfileImage()
        );
    }

    // =============== GỬI OTP ===============
    public String sendOtp(String email) {
        User user = userRepository.findByEmail(email);
        if (user == null) {
            throw new RuntimeException("Không tìm thấy tài khoản với email này.");
        }

        // Tạo OTP 6 chữ số
        String otp = String.valueOf(100000 + new SecureRandom().nextInt(900000));
        otpStore.put(email, otp);

        // Gửi email
        try {
            sendOtpEmail(email, otp);
        } catch (MessagingException e) {
            otpStore.remove(email); // rollback
            throw new RuntimeException("Không thể gửi email OTP. Vui lòng thử lại.");
        }

        return "Mã OTP đã được gửi đến email của bạn.";
    }

    // =============== XÁC THỰC OTP ===============
    public boolean verifyOtp(String email, String otp) {
        String storedOtp = otpStore.get(email);
        if (storedOtp == null || !storedOtp.equals(otp)) {
            return false;
        }
        otpStore.remove(email); // Xóa sau khi dùng
        return true;
    }

    // =============== GỬI EMAIL OTP (PRIVATE) ===============
    private void sendOtpEmail(String to, String otp) throws MessagingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true);

        helper.setTo(to);
        helper.setSubject("Mã OTP xác thực quên mật khẩu - AppMusic");
        helper.setText(
                "<h3>Xin chào,</h3>" +
                        "<p>Bạn đã yêu cầu đặt lại mật khẩu.</p>" +
                        "<p><b>Mã OTP của bạn là: " + otp + "</b></p>" +
                        "<p>Mã này có hiệu lực trong 5 phút.</p>" +
                        "<p>Nếu bạn không thực hiện thao tác này, vui lòng bỏ qua email.</p>" +
                        "<br><p>Trân trọng,<br>Đội ngũ AppMusic</p>",
                true // HTML
        );

        mailSender.send(message);
    }

    public void changePassword(String email, String newPassword) {
        User user = userRepository.findByEmail(email);
        if (user == null) {
            throw new RuntimeException("Không tìm thấy tài khoản với email này.");
        }

        // Mã hóa mật khẩu mới
        String encodedPassword = passwordEncoder.encode(newPassword);
        user.setPassword(encodedPassword);

        // Lưu vào DB
        userRepository.save(user);
    }
}