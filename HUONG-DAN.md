# Hướng dẫn sử dụng skill math-web-builder

Dành cho người không biết lập trình. Làm lần lượt từ trên xuống.

## Phần 1. Chuẩn bị (khoảng 15 phút, đều miễn phí)

### 1.1. Cài Node.js (một lần)
Tải bản **LTS** tại nodejs.org, cài như phần mềm bình thường. Đây là phần mềm giúp chạy app trên máy bạn. Nếu không chắc đã cài chưa, bạn cứ nhờ Claude: "kiểm tra máy tôi đã cài Node.js chưa".

### 1.2. Tạo "kho dữ liệu" Supabase
Supabase là nơi lưu đề, tài khoản giáo viên, bài làm của học sinh.
1. Vào **supabase.com**, đăng ký (có thể dùng tài khoản Google/GitHub).
2. Bấm **New project**, đặt tên, chọn vùng **Singapore** (gần Việt Nam), **đặt một mật khẩu cho cơ sở dữ liệu và ghi lại** (bạn sẽ cần nó; đây là mật khẩu quan trọng, đừng đưa ai).
3. Chờ vài phút cho project tạo xong.
4. Vào **Project Settings > API** và chép lại 3 thứ: **Project URL**, khóa **anon / publishable**, khóa **service_role / secret**.

### 1.3. Chuẩn bị Gmail để gửi thư xác nhận
App gửi email cho giáo viên khi đăng ký hoặc quên mật khẩu, bằng Gmail của bạn.
1. Dùng một Gmail (nên tạo Gmail riêng cho app).
2. Bật **Xác minh 2 bước**: myaccount.google.com > Bảo mật.
3. Cùng trang đó, tìm **Mật khẩu ứng dụng**, tạo một cái (đặt tên tùy ý). Google cho bạn 16 ký tự: chép lại. Đây KHÔNG phải mật khẩu Gmail của bạn.

### 1.4. Khóa Gemini (cho phần AI)
Mỗi giáo viên dùng khóa của riêng mình, nhập trong trang Cài đặt của app. Với bạn (người dựng app) chỉ cần khóa để chạy thử:
1. Vào **aistudio.google.com/apikey**, đăng nhập Google.
2. Bấm **Create API key**, chọn hoặc tạo một project.
3. Chép khóa (bắt đầu bằng `AIza...`).
Gói miễn phí có giới hạn số lần dùng mỗi ngày; khi cả lớp dùng thật nên bật thanh toán cho project Google (chi phí rất nhỏ cho lớp học).

### 1.5. Cách báo thông tin cho Claude
Claude sẽ hỏi bạn các thứ trên **một lần**. Cách an toàn: tạo file tên `.env` trong thư mục dự án (Claude sẽ tạo sẵn file mẫu `.env.example`), điền giá trị vào đó rồi bảo Claude "tôi đã điền .env". Đừng dán khóa lên diễn đàn hay gửi cho người khác.

## Phần 2. Dùng skill

1. Tạo một **thư mục trống** (ví dụ `Desktop/app-gia-su-toan`) và mở nó trong Claude Code.
2. Gõ `/math-web-builder`, rồi dán mô tả chức năng bạn muốn (xem `MAU-PROMPT.md`). Muốn giống app gốc: dùng nội dung file `PROMPT-CHUC-NANG.md`.
3. Claude sẽ tự: dựng app, tạo cơ sở dữ liệu, chạy thử như một giáo viên và một học sinh thật, sửa lỗi, rồi báo cáo bằng tiếng Việt. Việc này có thể mất vài chục phút; bạn chỉ cần trả lời khi Claude hỏi.
4. Khi xong, Claude chỉ bạn cách mở app (thường là gõ `npm run dev` rồi mở `http://localhost:3000`).

## Phần 3. Thử app
1. Mở app, **đăng ký** một tài khoản giáo viên bằng email của bạn, mở hộp thư bấm xác nhận.
2. Vào **Cài đặt**, dán khóa Gemini. Trang Đề bài đã có sẵn 10 đề mẫu.
3. Mở một đề, tick **xác nhận đáp án đúng** (khi bạn đã tự kiểm tra), lưu.
4. Vào **Liên kết**, chọn đề, tạo link, sao chép.
5. Mở link đó bằng **cửa sổ ẩn danh** để đóng vai học sinh: nhập tên, lớp, làm thử bài.
6. Quay lại **Thống kê** và **Học sinh** xem kết quả.

## Phần 4. Đưa app lên mạng để học sinh dùng
Chạy trên máy bạn chỉ để thử; học sinh ở nhà không vào được. Muốn dùng thật, đưa app lên **Vercel** (miễn phí cho lớp học nhỏ). Cách dễ nhất: bảo Claude "giúp tôi đưa app lên mạng bằng Vercel" và làm theo từng bước. Claude sẽ cần bạn:
1. Có tài khoản **GitHub** và **Vercel** (đăng ký miễn phí bằng Google).
2. Đồng ý đưa mã lên GitHub (file `.env` sẽ KHÔNG bị đưa lên).
3. Điền các thông tin trong `.env` vào mục Environment Variables của Vercel, và đặt `NEXT_PUBLIC_SITE_URL` là địa chỉ thật mà Vercel cấp (ví dụ `https://ten-app.vercel.app`).
Xong, bạn có một địa chỉ web thật để đăng ký giáo viên và gửi link cho học sinh.

## Phần 5. Dùng hằng ngày
- Giáo viên tạo đề → duyệt → tạo link → gửi lớp.
- Muốn thêm đề từ file Word hoặc ảnh: trang Đề bài có nút tạo đề hàng loạt và đọc ảnh.
- Muốn đổi cách app hoạt động (đổi tên, thêm tính năng...): mở lại Claude Code trong thư mục app và mô tả điều bạn muốn.

## Lưu ý an toàn
- **Không đưa file `.env` cho ai** và không đăng lên mạng; nó chứa chìa khóa vào dữ liệu của bạn.
- Dữ liệu học sinh (tên, lớp, bài làm) là thông tin nhạy cảm. App không lưu IP hay tên trường, tự che số điện thoại/email trong tin nhắn và không gửi tên học sinh cho AI. Dù vậy hãy thông báo cho phụ huynh và nhà trường khi dùng thật.
- Link xem kết quả cho phụ huynh là công khai với bất kỳ ai có link; bạn thu hồi được bất cứ lúc nào.
- App không bao giờ xóa thật dữ liệu: xóa chỉ là ẩn đi.
