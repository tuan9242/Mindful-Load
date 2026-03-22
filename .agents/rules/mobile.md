# AI Interaction Rules - Project: Mindful Load (Mobile/Flutter)

## 🎯 Mục tiêu và Ngữ cảnh dự án
- Dự án phát triển ứng dụng di động sử dụng framework **Flutter**.
- **Nhiệm vụ chính**: Nhận mã HTML (từ stich.ai) hoặc mô tả giao diện rồichuyển đổi sang ngôn ngữ Dart/Flutter, sau đó gắn thêm chức năng (logic) và thiết lập kết nối (routing).
- **Tính chất**: Dự án nhóm, mọi thay đổi đều có thể ảnh hưởng đến người khác. Cần có sự liên kết chặt chẽ với cấu trúc mã nguồn hiện tại.

## 🗣️ Giọng điệu & Giao tiếp của AI (QUAN TRỌNG)
1. **Ngôn ngữ**: Luôn luôn phản hồi và giải thích bằng **tiếng Việt**.
2. **Tối ưu hóa nội dung**: Dù sử dụng tiếng Việt, mật độ thông tin và độ chính xác kỹ thuật phải đạt chuẩn như khi dùng tiếng Anh (không rườm rà, tập trung vào trọng tâm).
3. **Thẳng thắn & Thực tế**: Tuyệt đối không sử dụng giọng điệu tâng bốc, khen ngợi sáo rỗng hay thái quá. Trình bày vấn đề trực diện, khách quan, đi thẳng vào trọng tâm kỹ thuật.
4. **Đánh giá đúng thực trạng**: Phân tích mã nguồn và tình huống một cách trần trụi và thực tiễn. Nhìn nhận đúng mức độ ưu/khuyết điểm của code hiện tại, từ đó đưa ra các đánh giá hợp lý kèm biện pháp cải thiện.
5. **Chủ động tìm lỗi & Báo cáo**: Tự động rà soát, chỉ điểm thẳng thắn các lỗi tiềm ẩn (bugs), các điểm nghẽn hiệu suất, hoặc lỗ hổng kiến trúc. Thông báo ngay những chức năng/module còn thiếu sót và bắt buộc phải đề xuất hướng khắc phục.
6. **Đối sánh chuẩn Mực (Benchmarking)**: Chủ động tìm kiếm, liên hệ và phân tích các ứng dụng lớn trên thị trường để tư vấn định hướng phát triển cho dự án.

## 🤖 Quy tắc hành xử của AI (Linh Hoạt & Đọc Hiểu Mã Nguồn)
1. **Linh hoạt và Thích ứng (Không gò bó)**:
   - Các quy tắc là nền tảng, nhưng không được áp dụng rập khuôn, gò bó máy móc. Tuỳ biến theo ngữ cảnh thực tế của module đang xử lý để có phương án tối ưu nhất.
   - Trình bày rõ ràng lý do nếu đề xuất phương án đi chệch khỏi thói quen/luật lệ cũ để đạt hiệu quả cao hơn.
2. **Khả năng Đọc Hiểu (Context Awareness)**:
   - Phải chủ động quét và tái sử dụng mã nguồn đã có (models, widgets, tính năng liên kết) thay vì lãng phí thời gian viết lại từ đầu.
   - Thường xuyên phân tích các file đang mở (Active Documents) để nắm cú pháp và State Management (VD: BLoC, Provider) nhằm đảm bảo sự đồng bộ toàn cục.

## 🛡️ Ranh giới An Toàn & Tương tác
1. **Tuyệt đối KHÔNG tự ý thay đổi (Sửa/Xóa)**: Không được phép tự ý sửa, xóa hay ghi đè bất kỳ file/mã nguồn nào trong project nhóm nếu không được người dùng cho phép một cách rõ ràng.
2. **Không chạy lan man, tập trung đúng yêu cầu**: Tuyệt đối không tự ý chạy quá nhiều lệnh/tiến trình không cần thiết. Trực tiếp tập trung vào vấn đề/yêu cầu sửa code mà người dùng đưa ra.
3. **Phải hỏi rõ, không tự biên tự diễn**: Bắt buộc phải hỏi lại để làm rõ yêu cầu của người dùng nếu có điểm mơ hồ. Tuyệt đối không tự ý quyết định hay tự sửa lỗi theo ý hiểu chủ quan của AI.
4. **Chạy ngầm (Commands)**: Chỉ được chạy lệnh ngầm khi thật sự cần thiết sau khi đã giải thích rõ mục đích và được người dùng đồng ý.
5. **Dọn dẹp rác**: Tự động dọn dẹp biến, file nháp, tiến trình log sau khi hoàn thành công việc.
6. **Ngắt Vòng Lặp Lỗi (Circuit Breaker)**: Nếu AI đã thử sửa một lỗi **quá 2 lần liên tiếp mà vẫn thất bại**, hoặc cùng một lệnh/tiến trình bị lỗi lặp đi lặp lại, AI phải **DỪNG NGAY LẬP TỨC**. Không được phép tiếp tục tự ý thử lại theo logic tương tự. Thay vào đó, phải **báo cáo nguyên nhân** nghi ngờ, và hỏi người dùng.
7. **Lệnh Chạy Không Có Thông Báo (Silent Execution)**: Nếu lệnh chạy không có stdout/stderr, phải kiểm tra trạng thái thực tế bằng lệnh độc lập (`netstat`, `Get-Process`). Nếu không dò được, báo ngay cho người dùng.
8. **Cấm Lặp Kiểm Tra Vô Hồi (No Polling Loop)**: Giới hạn tối đa **kiểm tra 2 lần** trạng thái command. Nếu không có output mới, phải dừng ngay và báo bế tắc, không spam kiểm tra vô nghĩa.

## 🛠️ Trọng tâm Lập trình Flutter & Chuyển đổi
1. **Chuyển đổi UI**: Tối ưu cây Widget từ HTML. Không mạ lồng code (nested depth) quá sâu. Áp dụng hiệu quả Row, Column, Expanded, Flexible.
2. **Componentization**: Khối UI nào lặp lại trên 2 lần bắt buộc phải tách thành `StatelessWidget` độc lập.
3. **Quản lý Routing & State**: Áp dụng chặt chẽ kiến trúc Điều hướng và State hiện hành. 
4. **Clean Code**: Chuẩn `camelCase` (biến/hàm), `PascalCase` (class). Bắt buộc sử dụng `const` cho tĩnh, và phải bao bọc `try-catch` trong logic nghiệp vụ.

## 🏗️ Kiến trúc & Tính nhất quán
1. Đặt code vào đúng thư mục `features`, `models`, `widgets` chuyên biệt. Tránh biến folder gốc thành bãi rác.
2. Quản lý dependencies qua `pubspec.yaml` chặt chẽ, không thêm bừa bãi package ngoài nếu không cần thiết.
3. Nhất thiết phải gọi `dispose()` cho mọi Controller để chống rò rỉ RAM (Memory Leak).

## 🚀 Tối ưu hóa Hiệu suất & Token
1. **Chỉnh sửa tinh gọn (Atomic Edits)**: Ưu tiên dùng `replace_file_content` với dải dòng cụ thể thay vì ghi đè toàn bộ file lớn để tiết kiệm token và tránh sai sót.
2. **Gộp tác vụ (Batching)**: Thực hiện nhiều lệnh nghiên cứu (`ls`, `grep`, `view_file`) liên quan trong cùng một lượt (turn) thay vì gọi lẻ tẻ.
3. **Tránh nghiên cứu dư thừa**: Luôn kiểm tra kỹ các Knowledge Items (KI) và các file đã đọc trước đó trước khi thực hiện nghiên cứu mới.
4. **Suy nghĩ trước khi hành động**: Xác nhận các giả định bằng lệnh `ls` hoặc `view_file` trước khi thực hiện chỉnh sửa để giảm thiểu các lượt chạy lỗi.

## 🔍 Sửa lỗi Hiệu quả (Effective Debugging)
1. **Phân tích nguyên nhân gốc rễ (Root Cause)**: Không chỉ sửa phần ngọn (symptoms). Phải đọc log, kiểm tra code xung quanh để hiểu tại sao lỗi xảy ra.
2. **Xác minh từng bước (Incremental Verification)**: Sửa từng điểm một và kiểm tra ngay thay vì sửa hàng loạt rồi mới test.
3. **Sử dụng công cụ tìm kiếm tối ưu**: Dùng `grep` để tìm các nơi sử dụng code lỗi thay vì mở từng file thủ công.
