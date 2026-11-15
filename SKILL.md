---
name: math-web-builder
description: Dựng trọn một web app chatbot gia sư Toán gợi mở (MathStep AI) từ bộ khung đã kiểm thử, theo mô tả chức năng của người dùng. Giáo viên tạo đề và gửi link; học sinh chat để tự giải, bot không đưa đáp án; có chấm 4 tiêu chí, thống kê, link phụ huynh. Dùng khi người dùng gõ /math-web-builder hoặc nói "làm app gia sư Toán", "làm chatbot hướng dẫn học sinh giải toán", "dựng MathStep". Build a Vietnamese Socratic math-tutor web app (Next.js + Supabase + Gemini) from a tested template.
---

# math-web-builder

Skill này dựng một web app hoàn chỉnh "MathStep AI" cho người dùng không biết lập trình. Người dùng chỉ mô tả chức năng bằng tiếng Việt thường; bạn lo toàn bộ phần kỹ thuật.

## Nguyên tắc
1. **Bắt đầu từ bộ khung, không viết lại từ đầu.** `assets/template/` là một dự án chạy được, đã qua 212 test. Phần logic tinh chỉnh nhiều (kiểm phép tính, chặn lộ đáp án, chốt bài, chuẩn hóa đề, che thông tin cá nhân) nằm trong `lib/`. KHÔNG viết lại hay "đơn giản hóa" các file này. Chỉ sửa khi người dùng yêu cầu thay đổi hành vi đó.
2. **Mô tả của người dùng quyết định phạm vi.** So mô tả với `references/features.md`. Giữ những gì khớp, bỏ phần người dùng không muốn, thêm phần họ muốn thêm. Phần nào họ không nhắc thì giữ như bộ khung. Không tự thêm tính năng ngoài ý họ.
3. **Người dùng không biết kỹ thuật.** Nói tiếng Việt đơn giản, không dùng thuật ngữ khi không cần. Khi buộc phải nhắc công nghệ, giải thích một câu bằng ví dụ đời thường (xem `CONG-NGHE.md`). Chỉ hỏi người dùng những thứ chỉ họ mới có (khóa, tài khoản), hỏi gộp một lần và nói rõ lấy ở đâu (xem `HUONG-DAN.md`).
4. **Tự chạy thử thật trước khi báo xong.** Typecheck, lint và test không thay thế việc dùng thử trên trình duyệt thật.
5. **Bí mật:** không in mật khẩu hay khóa ra màn hình, không commit `.env`, không đưa khóa vào mã nguồn hay tin nhắn.

## Quy trình

### Bước 1. Chuẩn bị và đọc yêu cầu
- Thư mục làm việc hiện tại là nơi dựng app. Nếu có sẵn file khác thì hỏi trước khi ghi đè; thư mục rỗng thì làm luôn.
- Đọc mô tả chức năng của người dùng (thường gọi kèm skill). Nếu họ không mô tả gì, dùng `PROMPT-CHUC-NANG.md` (bản đầy đủ như app gốc).
- Đọc `references/features.md` (danh sách chức năng của bộ khung) và ghi nhanh chỗ nào người dùng muốn khác.

### Bước 2. Dựng khung
- Copy toàn bộ `assets/template/` vào thư mục làm việc (kể cả file ẩn như `.gitignore`).
- `npm install` rồi `npm test`: phải xanh toàn bộ trước khi làm tiếp. Nếu fail, sửa nguyên nhân (thường là phiên bản Node dưới 20).
- Đổi tên thương hiệu (tên app, logo chữ, màu chủ đạo, trang giới thiệu, Hướng dẫn, README) nếu người dùng muốn đặt tên khác. Tìm "MathStep" trong `app/`, `components/`, `lib/`, `README.md`.

### Bước 3. Môi trường và cơ sở dữ liệu
- Đọc `references/stack.md` để biết mỗi biến trong `.env` là gì và lấy ở đâu.
- Nếu chưa có `.env`: copy `.env.example`, điền những gì đã biết, hỏi người dùng phần còn thiếu (theo `HUONG-DAN.md`). `APP_SECRET` tự sinh một chuỗi ngẫu nhiên 48 ký tự, không hỏi.
- `npm run db:init -- --check` để kiểm tra kết nối, rồi `npm run db:init` để tạo bảng (chạy `supabase/migrations/001_init.sql`, an toàn chạy lại). Không `drop`/`truncate` gì. Tuyệt đối không in `supabase_password`.
- Cấu hình ở trang Supabase mà bạn không làm được qua code thì hướng dẫn người dùng (xem `references/stack.md`, mục "Việc phải làm tay").

### Bước 4. Điều chỉnh theo mô tả
- Đọc `references/chat-engine.md`, `references/problem-pipeline.md`, `references/security-privacy.md`, `references/ui-flow.md` TRƯỚC khi sửa phần liên quan. Chúng giải thích vì sao mã được viết như vậy; các quy tắc đó không được làm yếu đi (đặc biệt: bot không bao giờ lộ đáp án, không gửi tên và lớp học sinh cho AI, không xóa cứng dữ liệu).
- Nếu người dùng thêm tính năng cần bảng mới: thêm file `supabase/migrations/002_<tên>.sql` (đánh số tiếp, bật RLS, chỉ cho giáo viên đọc dữ liệu của mình) rồi `npm run db:init`. Không sửa `001_init.sql` đã chạy.
- Mỗi thay đổi hành vi phải có test (thêm vào `tests/`), `npm test` luôn xanh.

### Bước 5. Chạy thử thật (bắt buộc)
- Làm đúng `references/test-scenario.md`: khởi động dev server, thao tác trên trình duyệt thật như một giáo viên rồi như một học sinh, kiểm tra console và network không lỗi.
- Gặp lỗi thì tự sửa rồi chạy lại phần liên quan. Chỉ bỏ qua một bước khi thật sự không chạy được (ví dụ chưa có khóa Gemini hay email), và phải nói rõ bước nào chưa thử.
- Trước khi báo xong chạy `npm run build` (phải thành công).

### Bước 6. Bàn giao
Báo bằng tiếng Việt đơn giản, ngắn gọn:
- App làm được gì (so với mô tả của họ), và những gì khác mô tả.
- Đã thử những gì, kết quả.
- Cách mở app trên máy (`npm run dev`, mở `http://localhost:3000`).
- Cách đưa lên mạng cho học sinh dùng (Vercel, xem `HUONG-DAN.md`).
- Việc còn cần họ làm (nếu có).

## Điều KHÔNG làm
- Không tạo lại các thứ đã bỏ ở bản gốc: chế độ trắc nghiệm / từng bước / phiếu bài tập, khảo sát cuối bài, nhà cung cấp AI khác Gemini, chế độ "giải hộ học sinh", pg_cron.
- Không bắt học sinh tạo tài khoản.
- Không lưu IP hay thông tin trình duyệt của học sinh.
- Không gửi họ tên hoặc lớp của học sinh cho AI.
- Không xóa cứng dữ liệu (xóa mềm bằng `deleted_at`).
- Không đưa dữ liệu thật của người dùng (khóa, email, học sinh) vào skill, bộ khung hay tin nhắn.

## Tài liệu trong skill
| File | Dùng khi |
|---|---|
| `README.md` | giới thiệu skill, cách cài |
| `HUONG-DAN.md` | hướng dẫn người dùng chuẩn bị và dùng skill |
| `CONG-NGHE.md` | giải thích từng công nghệ bằng lời đời thường |
| `CAU-HOI-THUONG-GAP.md` | xử lý lỗi thường gặp |
| `MAU-PROMPT.md` | mẫu prompt mô tả chức năng |
| `PROMPT-CHUC-NANG.md` | bản mô tả chức năng đầy đủ như app gốc |
| `references/features.md` | danh sách chức năng của bộ khung |
| `references/stack.md` | công nghệ, biến môi trường, thiết lập |
| `references/data-model.md` | các bảng dữ liệu và dạng đề |
| `references/chat-engine.md` | quy tắc của gia sư AI |
| `references/problem-pipeline.md` | quy trình chuẩn hóa đề |
| `references/security-privacy.md` | bảo mật, riêng tư, xóa mềm |
| `references/ui-flow.md` | trang, đường dẫn, luồng màn hình |
| `references/test-scenario.md` | kịch bản chạy thử trước khi bàn giao |
| `assets/template/` | bộ khung dự án hoàn chỉnh |
