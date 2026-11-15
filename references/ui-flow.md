# Trang, đường dẫn và luồng màn hình

## Trang công khai
| Đường dẫn | Là gì |
|---|---|
| `/` | trang giới thiệu (landing) |
| `/login`, `/register`, `/forgot`, `/reset` | đăng nhập, đăng ký, quên và đặt lại mật khẩu |
| `/auth/confirm` | nhận link trong email (xác nhận đăng ký, đặt lại mật khẩu) |
| `/c/[slug]` | trang làm bài của học sinh |
| `/p/[token]` | kết quả cho phụ huynh (chỉ đọc) |

## Khu giáo viên (`/dashboard`, chưa đăng nhập thì chuyển về `/login?next=`, kiểm ở `middleware.ts`)
| Đường dẫn | Là gì |
|---|---|
| `/dashboard` | tổng quan |
| `/dashboard/problems` | danh sách đề (lọc, tìm); mở xem nhanh bằng panel `@panel` |
| `/dashboard/problems/new`, `/[id]`, `/[id]/edit` | tạo, xem, sửa đề |
| `/dashboard/problems/bulk`, `/imports` | tạo hàng loạt từ Word, lịch sử các đợt |
| `/dashboard/links` | tạo và quản lý link |
| `/dashboard/stats` | thống kê theo link, theo đề |
| `/dashboard/students`, `/[code]` | danh sách và hồ sơ học sinh |
| `/dashboard/settings` | cài đặt (khóa AI, nhật ký, công cụ hàng loạt) |
| `/dashboard/guide` | hướng dẫn sử dụng cho giáo viên |

## API (`app/api/*`)
`auth/{register,login,logout,forgot,reset}`, `chat`, `chat-log`, `client-error`, `errors`, `links`, `logs`, `p/[token]/log`, `problems` (kèm các module trong thư mục), `settings`, `students`.

## Luồng của giáo viên
Đăng ký → xác nhận email → đăng nhập → Cài đặt: dán khóa Gemini → Đề bài (đã có 10 đề mẫu) → mở đề, tick xác nhận đáp án (hoặc "Chuẩn hóa đề") → Liên kết: chọn đề, tạo link → gửi link cho học sinh → Thống kê và Học sinh để xem kết quả → (tùy chọn) tạo link phụ huynh.

## Luồng của học sinh (`/c/[slug]`)
Nhập họ tên + lớp → chọn đề → (nếu có bài dở: Làm tiếp / Làm lại mới) → màn chat: lời chào, đề ghim phía trên, ô Bài làm và khay Hỏi bài, nút Công thức, nút Gợi ý → bot nhận xét dần dần → khi đủ đáp án và cách làm thì bài kết thúc, chấm điểm chạy ngầm.

## Giao diện chung
Tiếng Việt, dùng được trên điện thoại (học sinh thường dùng điện thoại), có trạng thái đang tải (skeleton, thanh tiến trình), trang lỗi thân thiện (`error.tsx`, `global-error.tsx`, `not-found.tsx`), thông báo nổi (toast). Thành phần dùng chung ở `components/ui.tsx`; công thức ở `MathText.tsx`, `MathTextArea.tsx`, `FormulaDialog.tsx`, `FormulaButton.tsx` (font MathLive ở `public/mathlive-fonts/`).
