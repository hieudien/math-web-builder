# Câu hỏi thường gặp và cách xử lý

Cứ nhờ Claude: dán nguyên thông báo lỗi và nói "sửa giúp tôi". Dưới đây là những lỗi hay gặp và nguyên nhân.

## Cài đặt và chạy
**"Không kết nối được cơ sở dữ liệu"**
Kiểm tra `supabase_url` (địa chỉ project) và `supabase_password`. Đây là **mật khẩu Postgres** bạn đặt lúc tạo project, KHÔNG phải khóa API. Quên thì vào Supabase > Project Settings > Database > Reset database password.

**Máy báo cổng 3000 đang bận**
Đang có app khác (hoặc bản cũ của app này) chạy ở cổng đó. Tắt cửa sổ cũ, hoặc nhờ Claude đổi sang cổng khác.

**`npm` không chạy / "Node version"**
Cần Node.js bản 20 trở lên. Tải bản LTS ở nodejs.org rồi mở lại cửa sổ.

## Đăng ký và email
**Không nhận được email xác nhận**
Kiểm tra thư mục Spam. Kiểm tra `GMAIL_SMTP_USER` và `GMAIL_SMTP_APP_PASSWORD` (16 ký tự, là *Mật khẩu ứng dụng* chứ không phải mật khẩu Gmail; cần bật Xác minh 2 bước). Đăng ký quá 5 lần trong 1 giờ sẽ bị chặn tạm.

**Báo "Không gửi được email xác nhận"**
Thường do mật khẩu ứng dụng sai hoặc Gmail chặn đăng nhập. Tạo lại mật khẩu ứng dụng.

**Link trong email báo hỏng**
Link chỉ dùng một lần và có hạn. Bấm "Quên mật khẩu" hoặc đăng ký lại để nhận link mới. Kiểm tra `NEXT_PUBLIC_SITE_URL` đúng địa chỉ bạn đang dùng (khi chạy thử là `http://localhost:3000`).

## AI (Gemini)
**Học sinh thấy "Chatbot chưa sẵn sàng. Nhờ giáo viên kiểm tra cài đặt"**
Giáo viên chưa dán khóa Gemini hoặc khóa sai. Vào Cài đặt dán khóa.

**Báo hết lượt / quá tải / phản hồi chậm**
Gói miễn phí giới hạn số lần dùng mỗi ngày cho từng model. App tự đổi sang model khác khi một model quá tải. Nếu cả lớp dùng đồng loạt, bật thanh toán cho project Google (aistudio.google.com).

**Khóa báo không hợp lệ**
Chép lại khóa (bắt đầu `AIza`), không có khoảng trắng thừa. Nếu đổi `APP_SECRET` sau khi đã nhập khóa thì phải nhập lại khóa.

**AI viết đáp án sai ở đề mới**
Đề do AI tạo luôn ở trạng thái "chưa duyệt". Hãy tự kiểm tra đáp án rồi mới tick xác nhận. Nút "Chuẩn hóa đề" bắt AI giải nhiều lần và chỉ nhận khi các lần ra giống nhau; nếu không thống nhất, app báo lỗi thay vì đoán bừa. Khi đó hãy nhập đáp án đúng bằng tay rồi chuẩn hóa lại.

## Đề và link
**Không tạo được link cho một đề**
Đề phải được duyệt (tick xác nhận đáp án) và có lời giải chi tiết. Bấm "Chuẩn hóa đề" để AI viết lời giải chi tiết, rồi duyệt.

**Học sinh thấy "Liên kết này đã đóng"**
Link đang tắt, đã hết hạn hoặc đã xóa. Vào trang Liên kết để bật lại hoặc tạo link mới.

**"Bài này chưa sẵn sàng"**
Đề thiếu cả đáp án lẫn lời giải. Hoàn thiện đề rồi tạo link mới (link cũ giữ bản đề lúc tạo).

**Sửa đề rồi mà link cũ vẫn hiện đề cũ**
Đúng chủ ý: mỗi link giữ bản ghim của đề lúc tạo để kết quả không bị lẫn. Tạo link mới để dùng bản đề mới.

**Công thức hiện chữ lạ như `\frac{1}{2}`**
Công thức phải đặt trong dấu `$...$`. Dùng nút Công thức (bàn phím toán) để gõ cho đúng.

## Học sinh
**Học sinh gõ tên mà hệ thống tưởng hai người khác nhau**
App coi "cùng họ tên + cùng lớp" là một em (so sánh không phân biệt dấu và hoa thường). Nhắc các em gõ đúng một kiểu.

**Học sinh bị báo "gửi nhanh quá"**
Mỗi tin cách nhau tối thiểu 2 giây; ngoài ra có giới hạn số tin mỗi phút. Chờ một chút rồi gửi lại.

**Bot không thừa nhận bài đã xong**
Bot chỉ kết thúc bài khi học sinh nêu **đáp án cuối** và có **cách làm** (phép tính hoặc suy luận), không có phép sai. Nếu em chỉ viết một con số, bot mời viết cách làm.

**Bot nói câu cố định "Mình dừng ở đây để không nói trước kết quả"**
Rào chặn lộ đáp án đã cắt một câu sắp nói ra kết quả. Đây là hoạt động bình thường, em chỉ cần viết tiếp.

## Dữ liệu
**Tôi xóa nhầm một link/học sinh**
Không mất dữ liệu: xóa chỉ là ẩn. Học sinh vào lại cùng tên và lớp thì hiện lại. Nhờ Claude khôi phục link bằng cách bỏ dấu xóa trong cơ sở dữ liệu.

**Tôi muốn xóa hẳn dữ liệu một học sinh**
App chặn xóa cứng có chủ ý để bảo vệ số liệu. Nhờ Claude hướng dẫn, và cân nhắc kỹ vì không thể hoàn tác.

**Chi phí / hạn mức Supabase**
Gói Free có hạn mức dung lượng; project không dùng lâu có thể bị tạm dừng. Vào Supabase để "Restore" nếu bị tạm dừng.

## Khi nhờ Claude sửa
Hãy nói: (1) bạn đã làm gì, (2) thấy gì trên màn hình (dán nguyên chữ báo lỗi), (3) bạn mong muốn điều gì. Nếu lỗi liên quan học sinh, nhắc mã lỗi hiện trên màn hình (dạng `ref`), Claude tra được trong nhật ký lỗi ở Cài đặt.
