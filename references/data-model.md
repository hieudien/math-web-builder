# Mô hình dữ liệu

Nguồn sự thật là `assets/template/supabase/migrations/001_init.sql` (đã đối chiếu từng cột với cơ sở dữ liệu thật của bản gốc). Đây là bản tóm tắt để hiểu nhanh.

## Cách phân quyền
- Giáo viên đăng nhập qua Supabase Auth và chỉ ĐỌC được dữ liệu của mình (RLS, mọi chính sách là `select` theo `teacher_id`).
- Mọi thao tác ghi và mọi thao tác của học sinh đi qua máy chủ bằng khóa `service_role` (`lib/supabase/admin.ts`).
- Học sinh không có tài khoản: nhận diện bằng cookie ẩn danh `fm_anon` (uuid) và `student_code`.

## Bảng
| Bảng | Nội dung |
|---|---|
| `teacher_settings` | khóa Gemini đã mã hóa, model, nhiệt độ (mỗi giáo viên một dòng) |
| `problems` | đề bài; `content` là JSON đầy đủ của đề; `code` là mã đề (duy nhất trong cùng giáo viên khi chưa xóa); xóa mềm |
| `problem_versions` | bản cũ của đề, tự lưu bởi trigger mỗi lần `content` đổi |
| `public_links` | link cho học sinh; `problems_snapshot` là bản đề lúc tạo; `tag` ∈ pre/post/experiment/control; xóa mềm |
| `students` | học sinh (khóa `teacher_id` + `code`); xóa mềm |
| `chat_sessions` | mỗi lần học sinh làm một đề; `problem_snapshot` ghim bản đề lúc mở; `status` ∈ active/done/abandoned; `struggled`, `revealed`, `restarted` |
| `messages` | tin nhắn; `role` ∈ student/bot; `meta.kind` ∈ open, reply, wrong, hint, ask, off_topic, distress, blocked, done, stuck |
| `session_evals` | điểm cuối phiên: identify, plan, calculate, explain (0-3), total, final_correct, hint_count, errors, gaps, duration_s |
| `session_analysis` | nhận xét AI cho một phiên (lưu để xem lại) |
| `student_advice` | AI phân tích và đề xuất cải thiện cho một học sinh |
| `student_shares` | link phụ huynh (token); mỗi học sinh một link còn hiệu lực; thu hồi bằng `revoked_at` |
| `import_batches` | đợt nạp đề từ Word: bản nháp, xác nhận, lịch sử |
| `activity_logs` | nhật ký hoạt động, chỉ thêm (kể cả `ai_usage` đo token) |
| `error_logs` | nhật ký lỗi có mã tra cứu (`ref`); tự xóa sau 30 ngày |

## View và hàm (code gọi trực tiếp, đừng đổi tên)
- View (chạy với quyền người gọi): `overview_stats`, `error_counts`, `link_stats`, `tag_stats`, `student_stats`.
- Hàm: `next_seq(link)`, `bump_visit(link)`, `rename_problem(id, teacher, code)`, `sweep_abandoned()` (phiên không hoạt động quá 2 giờ thành "bỏ dở"), `link_summary(link)`, `link_problem_stats(link)`, `ai_usage_by_problem`, `ai_usage_by_session`.
- Trigger: `no_hard_delete` và `no_truncate` trên các bảng dữ liệu; `problems_keep_version`.

## Quy tắc xóa
Không xóa cứng. Xóa link, học sinh, đề chỉ đặt `deleted_at`; phiên, tin nhắn, điểm giữ nguyên. Học sinh vào lại cùng tên và lớp thì `deleted_at` về rỗng. Muốn xóa tài khoản giáo viên phải gỡ trigger trước (có chủ ý).

## Dạng của một đề (`problems.content`, định nghĩa ở `lib/schema/problem.ts`)
```
id            mã đề (vd "TC01")
title         tiêu đề
grade         lớp (1-12, mặc định 8)
topic         chủ đề
branch        "algebra" | "geometry" | "other" (tùy chọn)
skills        kỹ năng chính (mảng chữ)
reviewed      false khi AI vừa tạo, giáo viên chưa duyệt
answer_locked giáo viên đã xác nhận đáp án; chuẩn hóa không đổi nữa
statement     đề bài (nguồn duy nhất để AI tạo phần còn lại)
figure        {path, desc} hình vẽ (tùy chọn)
data          dữ kiện của đề
solution      đáp án chuẩn, vd {"x": 3} hoặc {"ket_luan": "vô nghiệm"}; đề nhiều ý dùng tiền tố a_x, b_m
solution_steps lời giải từng bước (học sinh KHÔNG thấy)
check_note    cảnh báo khi kiểm chéo lệch
common_errors sai lầm thường gặp
hints         đúng 3 mức {level 1-3, text}
```
