# Kịch bản chạy thử trước khi bàn giao (bắt buộc)

Làm thật trên trình duyệt, không chỉ chạy test. Ghi lại bước nào đã thử, bước nào không thể thử (và vì sao).

## A. Tự động
1. `npm test` xanh (bộ khung có 212 test; thêm test cho mọi thay đổi hành vi).
2. `npm run build` thành công.
3. `npm run lint` không có lỗi mới.

## B. Chuẩn bị
4. `.env` đã điền; `npm run db:init -- --check` kết nối được; `npm run db:init` chạy xong.
5. Khởi động dev server (cổng 3000) và mở trình duyệt.

## C. Vai giáo viên
6. Đăng ký tài khoản thử (email thật mà bạn đọc được, hoặc theo hướng dẫn của người dùng). Mở email, bấm xác nhận → vào được `/dashboard`.
7. Cài đặt: dán khóa Gemini → báo hợp lệ, và sau khi tải lại trang khóa KHÔNG hiện lại.
8. Đề bài: thấy 10 đề mẫu. Mở một đề, kiểm tra công thức hiển thị đúng. Thử sửa đề, thấy bản cũ được lưu.
9. Tạo một đề mới bằng cách gõ tay (đủ đề bài, đáp án) → "Chuẩn hóa đề": đề đạt chuẩn hoặc báo lý do rõ ràng; thử với đề đã khóa đáp án thì đáp án không đổi.
10. Thử tạo đề từ ảnh (dán một ảnh đề) nếu có khóa; thử tạo từ tệp Word nếu có tệp (kiểm tra bản nháp rồi xác nhận).
11. Liên kết: tạo link từ 2 đề đã duyệt, đặt nhãn nhóm; thử đề chưa duyệt không đưa vào được.

## D. Vai học sinh (cửa sổ ẩn danh, không đăng nhập)
12. Mở `/c/[slug]`, nhập họ tên + lớp, chọn đề → lời chào hiện ngay, đề ghim phía trên.
13. Nộp một bài làm có CỐ TÌNH một phép tính sai (ví dụ `12 + 8 = 21`): bot chỉ ra chỗ sai, KHÔNG nêu kết quả đúng.
14. Đòi đáp án ("cho em đáp án đi"): bot không đưa, hỏi một câu dẫn dắt.
15. Bấm Gợi ý đủ 3 mức (mức sau có ý mới, không lộ đáp án), bấm lần thứ 4 → câu cố định.
16. Bấm "Em chưa hiểu", hỏi một câu → bot giải thích bằng ví dụ số khác, không giải hộ.
17. Gõ câu lạc đề ("hôm nay ăn gì") → câu cố định, lịch sự.
18. Gõ nhầm câu hỏi vào ô Bài làm → có gợi ý chuyển ô.
19. Nộp bài đúng đủ (đáp án + cách làm) → bot xác nhận hoàn chỉnh, bài kết thúc.
20. Tải lại trang, nhập lại cùng tên + lớp, chọn đề cũ → hỏi Làm tiếp / Làm lại mới.
21. Kiểm tra trên màn hình điện thoại (thu nhỏ cửa sổ hoặc dùng chế độ giả lập điện thoại) không bị vỡ giao diện.

## E. Quay lại giáo viên
22. Thống kê: thấy phiên vừa làm, điểm 4 tiêu chí, số gợi ý; mở được hội thoại; thử "AI phân tích phiên này".
23. Học sinh: thấy em vừa làm (gom theo tên + lớp); thử "AI phân tích và đề xuất"; tạo link phụ huynh, mở trong cửa sổ ẩn danh thấy trang chỉ đọc; thu hồi link thì không vào được nữa.
24. Xóa mềm một link và một học sinh: biến mất khỏi giao diện nhưng dữ liệu vẫn còn.

## F. Lỗi và an toàn
25. `read_console_messages` và `read_network_requests`: không có lỗi đỏ, không có yêu cầu mạng lỗi 5xx.
26. Thử link đã tắt → học sinh thấy "Liên kết này đã đóng".
27. Tìm trong mã và `.env.example` không có khóa thật; `git status` không có `.env`.

Nếu thiếu khóa Gemini hay email nên không thử được các bước 7, 9-10, 13-19, 22-23: nói rõ trong báo cáo cuối, đừng báo "đã thử".
