# Quy trình chuẩn hóa đề và tạo đề bằng AI

Mã: `lib/fill.ts` (chính), `lib/solve.ts`, `lib/verify-solution.ts`, `lib/repair.ts`, `lib/lint.ts`, `lib/grade.ts`, `lib/answers.ts`, `lib/answer-check.ts`, `lib/latex-fix.ts`, `lib/math-wrap.ts`, `lib/format-rule.ts`; đường vào ở `app/api/problems/*`. Có test (`solve`, `proof`, `quality`, `substitute`, `guides-fix`, `format`...).

## Nguyên tắc
`statement` (đề bài) là nguồn sự thật duy nhất. AI tạo mọi thứ còn lại từ đó. Đề do AI tạo luôn `reviewed=false`; chỉ giáo viên xác nhận đáp án (tick) mới đưa vào link được. Đáp án đã khóa (`answer_locked`) không bao giờ bị đổi.

## Chuẩn hóa một đề (`standardizeProblem` trong `fill.ts`)
1. **Giữ đáp án cũ** khi `answer_locked` hoặc đã qua kiểm thay nghiệm bằng mã (`substituteState`). Ngược lại AI giải lại.
2. **Giải bỏ phiếu** (`voteAnswer`): kết quả của lượt tạo lại + 2 lượt giải độc lập (`solveOnce`: văn bản có thẻ `<loi_giai>`, `<kiem_tra>`, `<dap_an>`, không dùng JSON để khỏi hỏng dấu `\`; nhiệt độ 0 rồi 0.5; bắt buộc tự thay số kiểm). Cần ít nhất 2 bộ trùng nhau (`sameAnswers`: so số không kể thứ tự, sai số 0.5%; đáp án toàn chữ so chuỗi chính tắc) rồi qua kiểm thay nghiệm. Không đồng thuận → báo "Chưa có đáp án đáng tin", KHÔNG đoán.
3. **Phần phụ** (`rebuildFromStatement`): `data`, `skills`, `common_errors`, 3 `hints`, chọn model mạnh nhất (`smartModel`). Văn bản tiếng Việt không có dấu (`unaccented`) thì gọi lại 1 lần rồi báo lỗi.
4. **Lời giải từng bước** (`makeSteps`): 2-8 bước, mỗi bước MỘT phép biến đổi hoặc tính toán nhỏ; đề nhiều ý a) b) thì bước đầu mỗi ý mở đầu "a) ", "b) " và bước cuối mỗi ý kết luận. Mọi số ≥ 100 của đáp án phải xuất hiện nguyên vẹn trong lời giải (`missingAnswers`), thiếu thì báo lỗi.
5. **Rà soát** (`finishProblem`): kiểm chéo đáp án (`crossCheck`, chỉ với đề mới hoặc đang cảnh báo); rà lỗi tính trong lời giải (`checkSteps`, sai thì viết lại 1 lần, vẫn sai thì báo lỗi); kiến thức vượt lớp (`aboveGrade`, viết lại 1 lần); bước chỉ mô tả mà không có phép tính cụ thể (`descriptiveSteps`, viết lại 1 lần); `blockers` + `lintProblem` còn lỗi thì báo; đáp án chữ phải đúng là đáp án cần điền (`checkKey`).
6. **Đạt** → `reviewed=true`, xóa `check_note`. **Không đạt** → trả chuỗi lỗi dễ hiểu và KHÔNG ghi đè đề cũ.

## Giới hạn theo lớp (`lib/grade.ts`)
Mọi prompt sinh nội dung kèm `gradeRule(grade)`: chỉ dùng kiến thức đến hết lớp của đề (không đạo hàm, tích phân, ma trận...). Lớp < 9 chưa có phương trình bậc hai, Vi-ét, căn bậc ba; lớp < 10 chưa có logarit, vectơ, bất phương trình bậc hai.

## Đề chứng minh
Đáp án chỉ là kết quả của ý "tìm/xác định/tính" (khóa `ket_luan`); ý chứng minh không có đáp án. `proofAnswer` và `proofKey` xử lý.

## Chuẩn hóa văn bản công thức
`latex-fix.ts` sửa ký tự điều khiển do JSON nuốt dấu `\` (`\f`,`\t`,`\b` thành `\frac`,`\times`,`\begin`) và đổi `\( \)`, `\[ \]` thành `$...$`; `math-wrap.ts` bọc công thức trần trong `data` bằng `$...$` để hiện được.

## Đọc ảnh và tệp Word
- Ảnh (`lib/read-image.ts`, `read-multi.ts`, `image-check.ts`, `figure.ts`): Gemini đọc ảnh thành đề; đề hình học có khung hình vẽ để giáo viên chỉnh; ảnh cắt lưu kho `figures`, đề chỉ giữ `path` + mô tả bằng chữ; chat, giải, chấm chỉ đọc mô tả.
- Word (`lib/docx-read.ts`, `lib/import-batch.ts`, `lib/batch.ts`, `app/api/problems/batch.ts`, `bulk.ts`): giải nén bằng jszip, tách từng đề thô, chạy song song có giới hạn và hạn giờ theo lượt, tạo bản nháp trong `import_batches`; giáo viên xem rồi xác nhận mới lưu.

## Đề mẫu
`de-mau-10.json` (10 đề TC01–TC10, lớp 6-9). Đăng ký xong tự nạp (`lib/seed-account.ts`, không ghi đè mã đề đã có); đáp án đề mẫu đã khóa sẵn. Muốn đề mẫu khác thì thay file này và giữ đúng schema `lib/schema/problem.ts` (chạy `npm test` để kiểm).
