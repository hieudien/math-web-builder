# Công nghệ nào dùng để làm gì?

Bạn không cần hiểu sâu những thứ này. Bảng dưới giúp bạn biết "cái tên đó là gì" khi Claude nhắc tới.

## Ví dụ đời thường: app giống một trường học
| Trong trường học | Trong app | Công nghệ |
|---|---|---|
| Tòa nhà, lớp học, bảng, bàn ghế | trang web mà giáo viên và học sinh nhìn thấy | **Next.js** (cùng React, Tailwind) |
| Phòng lưu trữ hồ sơ, sổ điểm | nơi lưu đề, tài khoản, bài làm, điểm | **Supabase** |
| Giáo viên trợ giảng thông minh | gia sư AI nhận xét bài | **Google Gemini** |
| Bảo vệ cổng, kiểm tra thẻ | đăng nhập, phân quyền, ai xem được gì | **Supabase Auth** + quy tắc RLS |
| Bưu tá | gửi thư xác nhận đăng ký | **Gmail** (qua nodemailer) |
| Mặt tiền trường ra đường lớn | đưa app lên mạng cho mọi người vào | **Vercel** |

## Giải thích từng cái
- **Next.js:** cái dùng để *làm web*. Nó vừa tạo các trang bạn thấy (đăng nhập, danh sách đề, màn chat), vừa chạy phần "phía sau" xử lý yêu cầu. Đi kèm **React** (dựng giao diện) và **TypeScript** (ngôn ngữ lập trình, giúp phát hiện lỗi sớm).
- **Tailwind CSS:** bộ công cụ làm đẹp giao diện (màu, khoảng cách, chữ), dùng được cả trên điện thoại.
- **Supabase:** *nơi chứa dữ liệu*, giống một tủ hồ sơ có khóa trên mạng. Gồm: cơ sở dữ liệu (Postgres), hệ thống tài khoản giáo viên (Auth), và kho ảnh (Storage, chứa hình vẽ của đề hình học).
  - **RLS (bảo mật theo hàng):** quy tắc "giáo viên nào chỉ thấy dữ liệu của giáo viên đó".
  - **Khóa `service_role`:** chìa khóa vạn năng phía máy chủ. Tuyệt đối không công khai.
- **Google Gemini:** *bộ não AI*. Đọc bài làm của học sinh và viết nhận xét; đọc ảnh đề; giải và viết lời giải. App dùng **khóa của từng giáo viên**, nên chi phí do giáo viên đó chịu.
- **KaTeX:** cái giúp *công thức toán hiện đẹp* như sách (phân số, căn, mũ) thay vì chữ lộn xộn.
- **MathLive:** *bàn phím gõ công thức* trên màn hình, để học sinh và giáo viên không phải biết cách viết mã công thức.
- **Recharts:** vẽ các *biểu đồ* ở trang thống kê.
- **jszip:** giúp đọc *file Word (.docx)* để tách nhiều đề cùng lúc.
- **nodemailer + Gmail:** cách app *gửi email* (xác nhận đăng ký, đặt lại mật khẩu) bằng Gmail của bạn.
- **zod:** người kiểm tra thông tin vào, bảo đảm dữ liệu đúng khuôn trước khi lưu.
- **vitest:** bộ *kiểm tra tự động*. 212 bài test đảm bảo các phần quan trọng (bắt phép tính sai, không lộ đáp án...) không hỏng khi sửa app.
- **Vercel:** dịch vụ *đưa app lên mạng*. Bạn đưa mã lên, Vercel cho một địa chỉ web thật.
- **GitHub:** nơi cất mã nguồn trên mạng để Vercel lấy về.
- **Node.js / npm:** phần mềm chạy app trên máy bạn và công cụ tải các thư viện cần thiết.

## Một số từ hay gặp
| Từ | Nghĩa dễ hiểu |
|---|---|
| **file `.env`** | tờ giấy ghi các "chìa khóa" của app (khóa Supabase, khóa Gmail...). Không đưa ai, không đăng lên mạng |
| **khóa API (API key)** | chìa khóa để dùng một dịch vụ (ví dụ Gemini). Giống mật khẩu |
| **migration / SQL** | lệnh tạo các "ngăn tủ" (bảng) trong kho dữ liệu |
| **dev server / `npm run dev`** | chạy thử app trên máy bạn, chỉ bạn thấy |
| **build / deploy** | đóng gói app / đưa lên mạng |
| **token (của AI)** | đơn vị đo lượng chữ AI đọc và viết, dùng để tính tiền |
| **streaming** | bot trả lời hiện chữ chạy dần như đang gõ, thay vì chờ xong mới hiện |
| **xóa mềm** | "xóa" chỉ là ẩn đi, dữ liệu vẫn nằm trong kho |
| **snapshot (bản ghim)** | bản chụp đề tại thời điểm tạo link hoặc học sinh mở bài, để sửa đề sau này không làm đổi bài cũ |
| **link công khai** | ai có đường link đều vào được, không cần tài khoản |

## Chi phí
- **Miễn phí:** Node.js, Supabase gói Free, Vercel gói Hobby, GitHub, Gmail, khóa Gemini gói miễn phí (có hạn mức).
- **Có thể tốn tiền:** Gemini khi cả lớp dùng nhiều và bạn bật thanh toán (thường rất nhỏ cho lớp học). Supabase gói Free có hạn mức dung lượng và sẽ tạm dừng project nếu không dùng lâu; dùng thật nhiều thì cân nhắc gói trả phí.
