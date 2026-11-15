# Bảo mật, riêng tư và an toàn cho học sinh

Đây là các cam kết của app. Không làm yếu chúng khi chỉnh sửa; nếu người dùng yêu cầu thay đổi, nói rõ hệ quả.

## Dữ liệu học sinh
- **Lưu:** họ tên và lớp học sinh tự nhập, nội dung hội thoại, điểm chấm.
- **Không lưu:** trường, địa chỉ IP, thông tin trình duyệt. IP chỉ dùng tạm trong bộ nhớ để giới hạn tốc độ, đã băm kèm ngày và `APP_SECRET`.
- **Tự che trước khi lưu và trước khi gửi AI** (`lib/pii.ts`): email, số điện thoại Việt Nam, dãy 9-12 chữ số, "tên em là ...", "lớp 8A1", "trường ...".
- **Tên và lớp học sinh KHÔNG bao giờ gửi cho AI** khi chat.
- Học sinh không lưu gì trong trình duyệt ngoài cookie ẩn danh `fm_anon` (httpOnly, 1 năm).
- Giáo viên chỉ thấy học sinh thuộc link của mình (RLS).

## Không xóa cứng
Xóa link, học sinh, đề chỉ đặt `deleted_at`. Trigger trong cơ sở dữ liệu chặn `DELETE` và `TRUNCATE` trên các bảng dữ liệu. Nhật ký lỗi tự dọn sau 30 ngày (hàm `sweep_abandoned`).

## Công khai có chủ ý
- Ảnh hình vẽ của đề (kho `figures`): ai có đường dẫn đều xem được.
- Trang kết quả phụ huynh `/p/[token]`: ai có link đều xem được; giáo viên thu hồi bất cứ lúc nào (`student_shares.revoked_at`).
Nói rõ điều này với giáo viên.

## Khóa và bí mật
- Khóa Gemini của giáo viên: mã hóa AES-256-GCM bằng `APP_SECRET` (`lib/crypto.ts`), không bao giờ trả về trình duyệt, chỉ báo "đã có khóa".
- `SUPABASE_SERVICE_ROLE_KEY` chỉ dùng phía máy chủ (`lib/supabase/admin.ts`); không để trong biến `NEXT_PUBLIC_*`.
- `.env` nằm trong `.gitignore`. Không in giá trị bí mật ra màn hình, không đưa vào commit.

## Chống lạm dụng
- Giới hạn tốc độ trong bộ nhớ (`lib/ratelimit.ts`): theo cookie ẩn danh, theo IP băm, theo số lần `start`, theo đăng ký (5 lần/giờ/IP). Chặn gửi dồn dưới 2 giây trong cùng phiên.
- Chặn đổi vai và lấy prompt (`INJECT`), chặn lộ đáp án (xem `chat-engine.md`).
- Link tắt hoặc hết hạn → học sinh thấy "Liên kết này đã đóng".
- Mỗi lỗi có mã tra cứu (`ref`) trong nhật ký lỗi; học sinh chỉ thấy câu xin lỗi dễ hiểu (`lib/errors.ts`).

## An toàn cho học sinh
Tin có dấu hiệu nguy cơ (tự hại, bị bắt nạt, bị bạo hành) không gọi AI: trả lời nhẹ nhàng khuyên nói với thầy cô hoặc người lớn tin cậy, ghi `student_distress` vào nhật ký để giáo viên biết.

## Khi đưa lên mạng
- Đặt `NEXT_PUBLIC_SITE_URL` đúng địa chỉ thật.
- Dữ liệu chỉ dùng cho mục đích sư phạm; nếu dùng cho nghiên cứu, người dùng nên có thông báo và sự đồng ý phù hợp với quy định nhà trường. Nhắc họ điều này khi bàn giao.
