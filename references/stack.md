# Công nghệ, môi trường và thiết lập

## Công nghệ (mỗi cái làm gì)
| Công nghệ | Vai trò |
|---|---|
| Next.js 15 (App Router, Turbopack) + React 19 + TypeScript | khung làm web: trang, đường dẫn API, giao diện |
| Tailwind CSS 4 | định dạng giao diện |
| Supabase (Postgres, Auth, Storage, RLS) | nơi chứa dữ liệu, tài khoản giáo viên, kho ảnh hình vẽ, phân quyền theo hàng |
| Google Gemini (`@google/genai`) | bộ não AI, dùng khóa của TỪNG giáo viên |
| zod | kiểm tra dữ liệu vào/ra |
| KaTeX | hiển thị công thức đẹp |
| MathLive | bàn phím gõ công thức |
| Recharts | biểu đồ thống kê |
| jszip | đọc tệp Word (.docx) |
| nodemailer | gửi email qua Gmail |
| vitest | test tự động |
| Vercel | nơi đưa app lên mạng |

Yêu cầu: Node.js 20 trở lên.

## Biến môi trường (`.env`)
| Biến | Là gì | Lấy ở đâu |
|---|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | địa chỉ project Supabase | Supabase > Project Settings > API > Project URL |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | khóa công khai | cùng trang, mục "anon public" (nếu có "publishable key" thì dùng khóa đó) |
| `SUPABASE_SERVICE_ROLE_KEY` | khóa quyền cao, CHỈ phía server | cùng trang, "service_role" / "secret key". Tuyệt đối không công khai |
| `supabase_url` | như trên, dùng để lấy mã project khi chạy SQL | cùng URL |
| `supabase_password` | mật khẩu Postgres để chạy SQL tạo bảng | mật khẩu đặt lúc tạo project (hoặc Project Settings > Database > Reset database password) |
| `APP_SECRET` | khóa gốc mã hóa khóa Gemini của giáo viên | tự sinh chuỗi ngẫu nhiên ≥ 32 ký tự. Đổi sau khi giáo viên đã nhập khóa thì họ phải nhập lại |
| `NEXT_PUBLIC_SITE_URL` | địa chỉ web của app (dùng trong link email) | chạy thử: `http://localhost:3000`; khi lên mạng: địa chỉ thật |
| `GMAIL_SMTP_USER` | Gmail dùng để gửi thư xác nhận | tài khoản Gmail của người dùng |
| `GMAIL_SMTP_APP_PASSWORD` | "Mật khẩu ứng dụng" của Gmail (16 ký tự) | Tài khoản Google > Bảo mật > Xác minh 2 bước (bật) > Mật khẩu ứng dụng |
| `NEXT_PUBLIC_ADMIN_CONTACT` | liên hệ hiện trong thông báo lỗi | tùy người dùng (email hoặc Zalo) |
| `GEMINI_KEY` | (tùy chọn) khóa Gemini để chạy thử/đánh giá khi phát triển | https://aistudio.google.com/apikey |
| `TRUSTED_PROXY_HOPS` | (tùy chọn) số proxy tin cậy phía trước app, mặc định 1 | thường không cần đổi |

`.env` đã nằm trong `.gitignore`. Biến `NEXT_PUBLIC_*` được gửi xuống trình duyệt nên chỉ chứa thông tin công khai.

## Khóa Gemini của giáo viên
Mỗi giáo viên tự dán khóa vào trang Cài đặt của app. Khóa được mã hóa AES-256-GCM bằng `APP_SECRET` (`lib/crypto.ts`) và không bao giờ trả về trình duyệt. Gói miễn phí có hạn mức theo ngày cho từng model; cả lớp dùng chung thì nên bật thanh toán cho project Google.

## Tạo cơ sở dữ liệu
```
npm run db:init -- --check   # kiểm tra kết nối
npm run db:init              # chạy supabase/migrations/*.sql theo thứ tự, ghi lại file đã chạy
```
Script thử kết nối trực tiếp rồi thử các máy chủ trung gian (pooler) theo vùng, vì kết nối trực tiếp của Supabase chỉ chạy trên IPv6. Mỗi file chạy trong một giao dịch (lỗi thì hoàn tác). Bảng `_applied_migrations` ghi file đã chạy để chạy lại không bị trùng.

## Việc phải làm tay trên trang Supabase (nếu cần)
- **Project mới:** tạo tại supabase.com, chọn vùng gần người dùng (Singapore cho Việt Nam). Lưu mật khẩu Postgres.
- **Email xác nhận:** KHÔNG cần cấu hình email của Supabase. App tự tạo link xác nhận và gửi bằng Gmail của người dùng (`app/api/auth/register`, `lib/mail.ts`).
- **Giới hạn Gmail:** Gmail miễn phí gửi tối đa khoảng 500 thư/ngày; đủ cho giáo viên đăng ký.
- **Kho ảnh `figures`:** `001_init.sql` tự tạo (công khai, tối đa 1 MB mỗi ảnh, png/jpeg/webp).

## Đưa lên mạng (Vercel)
1. Đưa mã lên GitHub (không kèm `.env`).
2. Vào vercel.com > Add New Project > chọn repo.
3. Khai báo các biến ở bảng trên (trừ `supabase_url`/`supabase_password`/`GEMINI_KEY`, không cần), đặt `NEXT_PUBLIC_SITE_URL` là địa chỉ thật của app.
4. Deploy. Bấm vào địa chỉ nhận được để thử đăng ký.
Lưu ý: giới hạn tốc độ (`lib/ratelimit.ts`) đếm trong bộ nhớ của từng máy chủ; đủ cho lớp học, muốn chặt hơn khi nhiều máy chủ thì chuyển sang Redis.

## Lệnh hữu ích
```
npm run dev       # chạy thử ở http://localhost:3000
npm test          # chạy 212 test
npm run build     # build bản chạy thật
npm run lint
npm run eval      # (tùy chọn) đo chất lượng AI trên vài đề, cần GEMINI_KEY, tốn lượt gọi
```
