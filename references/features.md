# Chức năng của bộ khung (đối chiếu với mô tả của người dùng)

Bộ khung `assets/template/` đã làm sẵn toàn bộ danh sách dưới đây. Khi người dùng mô tả chức năng, đánh dấu: GIỮ / BỎ / THAY ĐỔI / THÊM MỚI.

## Giáo viên (có tài khoản)
- **Đăng ký, đăng nhập, quên và đặt lại mật khẩu.** Email xác nhận và đặt lại mật khẩu gửi bằng Gmail. Đăng ký xong tự nạp 10 đề mẫu.
- **Cài đặt:** nhập khóa Gemini (mã hóa, không hiện lại), chọn model (có tự đổi model khi quá tải), nhật ký hoạt động, nhật ký lỗi, "Xác nhận đáp án hàng loạt", "Kiểm tra đề", "Chuẩn hóa tất cả đề".
- **Đề bài:** danh sách có tìm kiếm không dấu và lọc theo nhánh (Đại số / Hình học / Khác), lớp, chủ đề (gợi ý theo chương trình GDPT 2018 lớp 6-9); xem nhanh bằng panel; tạo/sửa đề (bàn phím MathLive, xem trước KaTeX).
- **Bốn cách tạo đề:** gõ tay; chụp hoặc dán ảnh (AI đọc ảnh; đề hình học thì AI khoanh khung hình vẽ, giáo viên chỉnh lại, ảnh lưu kho công khai `figures`, đề chỉ giữ đường dẫn và mô tả bằng chữ); tải tệp Word nhiều đề (bản nháp, xác nhận mới lưu, có lịch sử các đợt); nạp 10 đề mẫu.
- **Duyệt đề:** đề do AI tạo mang cờ `reviewed=false`; giáo viên mở đề, tick xác nhận đáp án đúng (khóa đáp án) rồi lưu mới đưa vào link được.
- **Chuẩn hóa đề** (từng đề và hàng loạt): AI làm lại đáp án (bỏ phiếu), lời giải từng bước, 3 gợi ý, kỹ năng, sai lầm thường gặp. Xem `problem-pipeline.md`.
- **Liên kết công khai:** tạo từ một hoặc nhiều đề; bật/tắt; hạn dùng; nhãn nhóm (trước / sau / thực nghiệm / đối chứng); sao chép; xóa mềm.
- **Thống kê:** theo liên kết (số phiên, tỉ lệ xong, điểm TB 4 tiêu chí thang 10, gợi ý, thời gian, so sánh nhóm, đọc hội thoại, "AI phân tích phiên này"), theo đề, theo học sinh, bước hay vướng.
- **Học sinh:** gom theo tên và lớp, điểm TB, kỹ năng cần củng cố, lỗi hay mắc, bài đã làm (kể cả bỏ dở), "AI phân tích và đề xuất cải thiện", link phụ huynh chỉ đọc `/p/[token]` (thu hồi được), xóa mềm.
- **Trang Tổng quan, Hướng dẫn sử dụng, trang giới thiệu (landing), trang báo lỗi thân thiện.**

## Học sinh (không tài khoản)
- Vào bằng link, nhập họ tên và lớp (tối đa 10 ký tự), không lưu trong trình duyệt.
- Làm tiếp bài dở hoặc làm lại mới.
- Chat nộp bài tự do: một bước, nhiều bước hoặc cả bài; bot nhận xét đúng phần vừa nộp, trả lời chạy dần.
- Hai ô: "Bài làm" (xanh) và "Hỏi bài" (vàng, nút "Em chưa hiểu"), nhắc chuyển ô khi gõ nhầm.
- Nút Công thức (MathLive), hiển thị KaTeX. Nút Gợi ý 3 mức.
- Chấm 4 tiêu chí cuối bài chạy ngầm.

## Đã bỏ khỏi bản gốc (đừng tạo lại)
Chế độ trắc nghiệm, từng bước, phiếu bài tập (worksheet); khảo sát cuối bài (cột `survey_likert` còn trong DB nhưng giao diện không dùng); nhà cung cấp AI khác Gemini; chế độ "giải hộ"; pg_cron.

## Gợi ý cách thay đổi thường gặp
| Người dùng muốn | Làm ở đâu |
|---|---|
| Đổi tên app, màu, logo chữ | `components/Brand.tsx`, `app/globals.css`, `app/page.tsx`, `app/layout.tsx`, `app/dashboard/guide/page.tsx`, `README.md` |
| Dạy môn khác hoặc lớp khác | `lib/taxonomy.ts` (chủ đề), `lib/grade.ts` (giới hạn kiến thức theo lớp), các prompt trong `lib/fill.ts`, `lib/solve.ts`, `lib/chat/free.ts`, `lib/chat/prompt.ts`; kiểm tra phần chữ "Toán" trong giao diện |
| Đổi lời chào, câu cố định của bot | `lib/chat/goals.ts`, `lib/chat/canned.ts` |
| Đổi số lần gợi ý | `MAX_HINT` trong `lib/chat/free.ts` và schema `hints` trong `lib/schema/problem.ts` |
| Đổi giới hạn tốc độ | `app/api/chat/route.ts` (các lệnh `limited(...)`) |
| Đổi model AI | `lib/models.ts` (danh sách, model đầu tiên là model chính) |
| Bỏ link phụ huynh | xóa nút chia sẻ ở trang học sinh, route `app/p`, `app/api/p`, `lib/share.ts` |
