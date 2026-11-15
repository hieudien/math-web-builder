# math-web-builder

Skill cho Claude Code: **dựng trọn một web app chatbot gia sư Toán** chỉ bằng cách mô tả chức năng bằng tiếng Việt thường. Bạn không cần biết lập trình.

App làm ra gồm:
- **Giáo viên** tạo đề (gõ tay, chụp ảnh, tải file Word), gửi link cho học sinh, xem điểm mạnh yếu từng em.
- **Học sinh** mở link, chỉ nhập họ tên và lớp, rồi chat với gia sư AI để tự giải bài. Gia sư **không bao giờ đưa đáp án**, chỉ nhận xét, chỉ chỗ sai và gợi ý dần.
- Chấm theo 4 tiêu chí (hiểu đề, lập kế hoạch, thực hiện, kiểm tra), thống kê, link xem kết quả cho phụ huynh.

## Skill này khác gì chỉ gõ một prompt dài?
Phần khó nhất (kiểm tra phép tính sai, chặn bot lỡ miệng nói đáp án, hiểu cách học sinh viết số, chuẩn hóa đề, che thông tin cá nhân) đã được viết và kiểm thử sẵn (212 bài test) và nằm trong `assets/template/`. Mỗi lần dựng, bạn nhận kết quả ổn định thay vì để AI viết lại từ đầu và mắc lại những lỗi cũ.

## Cài đặt
1. Cài [Claude Code](https://claude.com/claude-code) (hoặc ứng dụng Claude trên máy tính, tab Code).
2. Chép **cả thư mục `math-web-builder`** vào thư mục skill của Claude Code:
   - Dùng cho mọi dự án: `~/.claude/skills/math-web-builder/` (Windows: `C:\Users\<tên bạn>\.claude\skills\math-web-builder\`)
   - Hoặc chỉ cho một dự án: `<thư mục dự án>/.claude/skills/math-web-builder/`
3. Mở Claude Code trong một **thư mục trống** để chứa app mới.

## Cách dùng
Gõ `/math-web-builder` rồi dán mô tả chức năng của bạn. Ví dụ ngắn nhất:

```
/math-web-builder Làm app như bản đầy đủ trong file PROMPT-CHUC-NANG.md của skill.
```

Hoặc mô tả theo ý bạn (xem `MAU-PROMPT.md`). Trước khi dùng, đọc `HUONG-DAN.md` để biết cần chuẩn bị gì (khoảng 15 phút, toàn thứ miễn phí).

## Các file trong skill
| File | Dùng để |
|---|---|
| `HUONG-DAN.md` | hướng dẫn từng bước: chuẩn bị, dùng skill, đưa app lên mạng |
| `CONG-NGHE.md` | mỗi công nghệ là gì, làm gì (giải thích bằng lời đời thường) |
| `CAU-HOI-THUONG-GAP.md` | gặp lỗi thì xem ở đây |
| `MAU-PROMPT.md` | các mẫu mô tả chức năng để dán |
| `PROMPT-CHUC-NANG.md` | bản mô tả đầy đủ đúng như app gốc |
| `SKILL.md` | quy trình cho Claude (bạn không cần đọc) |
| `references/` | tài liệu kỹ thuật cho Claude |
| `assets/template/` | bộ khung dự án hoàn chỉnh đã kiểm thử |

## Lưu ý
- App dùng khóa Google Gemini của **từng giáo viên** (không phải của bạn), nên chi phí AI do giáo viên tự chịu (có gói miễn phí).
- Bộ khung không chứa khóa hay dữ liệu thật của ai. Đề mẫu là đề tự soạn.
- Dữ liệu học sinh là dữ liệu nhạy cảm: đọc `references/security-privacy.md` trước khi cho học sinh dùng thật.
