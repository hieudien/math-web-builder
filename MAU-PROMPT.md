# Mẫu prompt mô tả chức năng

Luôn bắt đầu bằng `/math-web-builder`. Bạn chỉ cần nói **app làm gì cho ai**, không cần nói công nghệ.

## Mẫu 1. Giống app gốc (ngắn nhất)
```
/math-web-builder Làm app đầy đủ như bản mô tả trong file PROMPT-CHUC-NANG.md của skill. Tên app: "Toán Cô Lan".
```

## Mẫu 2. Chỉ phần cốt lõi (nhanh nhất để thử)
```
/math-web-builder Tôi là giáo viên Toán lớp 8. Tôi muốn một app để:
- Tôi đăng nhập, tạo đề bài (gõ tay hoặc dán ảnh đề), gửi một đường link cho cả lớp.
- Học sinh mở link, nhập tên và lớp, rồi chat với gia sư AI để tự giải bài. Gia sư không bao giờ nói đáp án, chỉ chỉ chỗ sai và gợi ý dần (3 mức).
- Tôi xem được điểm từng em và những em đang gặp khó.
Bỏ phần: tạo đề từ file Word, link cho phụ huynh, phân tích bằng AI. Tên app: "Gia sư Toán 8".
```

## Mẫu 3. Đổi giao diện và thương hiệu
```
/math-web-builder Làm app như PROMPT-CHUC-NANG.md nhưng: tên "Toán Vui", màu chủ đạo cam, giọng bot thật thân thiện như một người anh (xưng "anh", gọi học sinh là "em"), lời chào đầu bài ngắn gọn có biểu tượng cảm xúc.
```

## Mẫu 4. Thêm tính năng
```
/math-web-builder Làm app như PROMPT-CHUC-NANG.md, thêm: cuối mỗi tuần app tự tổng hợp danh sách 5 em cần quan tâm nhất (điểm thấp hoặc xin nhiều gợi ý) hiện ngay trang Tổng quan của giáo viên, kèm lý do ngắn.
```

## Mẫu 5. Dùng cho một lớp/khối khác
```
/math-web-builder Làm app như PROMPT-CHUC-NANG.md nhưng cho học sinh lớp 10 và 11: chủ đề theo chương trình mới của hai lớp này, và cho phép dùng kiến thức đến hết lớp 11 (có hàm số mũ, logarit, vectơ).
```

## Mẫu 6. Chỉ muốn thử nhanh trên máy (chưa đưa lên mạng)
```
/math-web-builder Làm app như PROMPT-CHUC-NANG.md. Tôi chỉ muốn chạy thử trên máy tôi trước, chưa đưa lên mạng. Hướng dẫn tôi từng bước chuẩn bị khóa và tài khoản cần thiết.
```

## Mẹo viết mô tả tốt
- **Nói ai làm gì, thấy gì:** "học sinh bấm nút Gợi ý thì thấy..." tốt hơn "có chức năng gợi ý".
- **Nói rõ cái KHÔNG muốn.** Phần nào bạn không nhắc thì Claude giữ như app gốc.
- **Nói số cụ thể** khi quan trọng: "3 mức gợi ý", "lớp tối đa 10 ký tự", "link hết hạn sau 30 ngày".
- **Đừng sợ dài.** Một mô tả đầy đủ ngay từ đầu cho kết quả tốt hơn nhiều so với nhắn từng chút một.
- **Sau khi có app**, muốn đổi gì cứ mở lại Claude Code trong thư mục app và mô tả, không cần gõ lại `/math-web-builder` (trừ khi muốn dựng lại từ đầu).

## Những điều app KHÔNG làm được (đừng yêu cầu)
- Gia sư không "giải hộ" học sinh: đây là nguyên tắc cốt lõi của app.
- Không bắt học sinh có tài khoản (học sinh vào bằng link).
- Không dùng AI khác ngoài Google Gemini (đổi nhà cung cấp là việc lớn, cần yêu cầu riêng).
- Không tự bảo đảm 100% đáp án AI đúng: vì vậy giáo viên luôn là người xác nhận đáp án.
