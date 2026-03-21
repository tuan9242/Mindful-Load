# AI Interaction Rules - Project: Mindful Load (Mobile/Flutter)

## 🎯 Mục tiêu và Ngữ cảnh dự án
- Dự án phát triển ứng dụng di động sử dụng framework **Flutter**.
- **Nhiệm vụ chính**: Nhận mã HTML (từ stich.ai) hoặc mô tả giao diện rồichuyển đổi sang ngôn ngữ Dart/Flutter, sau đó gắn thêm chức năng (logic) và thiết lập kết nối (routing).
- **Tính chất**: Dự án nhóm, mọi thay đổi đều có thể ảnh hưởng đến người khác. Cần có sự liên kết chặt chẽ với cấu trúc mã nguồn hiện tại.

## 🤖 Quy tắc hành xử của AI (Sự Linh Hoạt & Đọc Hiểu Mã Nguồn)
1. **Linh hoạt và Thích ứng (Không gò bó)**:
   - Mặc dù có các quy tắc, AI **không được áp dụng một cách rập khuôn, gò bó máy móc**. Hãy chủ động đưa ra phương án tối ưu nhất và giải thích sự lựa chọn của mình dựa trên ngữ cảnh thực tế của đoạn code/module đó.
   - Khi gặp tình huống các quy tắc có vẻ xung đột với "giải pháp tốt nhất," AI có quyền đề xuất ngoại lệ và xin phép người dùng.
2. **Khả năng Đọc Hiểu Mã Nguồn (Context Awareness)**:
   - Trước khi đề xuất viết mới 1 chức năng, AI phải chủ động quét và tận dụng tối đa mã nguồn đã có (models, widgets truyền thống, màn hình liên quan) thay vì code lại từ đầu.
   - Chủ động theo dõi các "Active Documents" (File đang mở sẵn) của người dùng để hiểu phong cách code, pattern (VD: Provider/BLoC) để code sinh ra có sự đồng nhất hoàn toàn với tổng thể.

## 🛡️ Ranh giới An Toàn & Tương tác
1. **Tuyệt đối KHÔNG tự ý thay đổi (Sửa/Xóa)** mã nguồn hiện có của project nhóm mà không có sự đồng ý rõ ràng.
2. **Chạy ngầm (Commands)**: Chỉ được chạy lệnh (ví dụ: pub get, flutter run) khi thực sự cần thiết hoặc sau khi giải thích và được người dùng duyệt qua.
3. **Dọn dẹp rác**: Tự động xóa hoặc hủy bỏ các files nháp, variables debug tạm thời ngay khi hoàn thành tác vụ.

## 🛠️ Trọng tâm Lập trình Flutter & Chuyển đổi
1. **Chuyển đổi UI**: Tối giản cấu trúc cây Widget từ HTML (không lồng nhau quá nhiều). Sử dụng triệt để Expanded, Flexible, Row, Column và Stack.
2. **Chia nhỏ (Componentization)**: Khuyến khích extract thành Widget con (`StatelessWidget`) ngay khi nhận thấy component giao diện tái sử dụng nhiều (VD: Nút bấm, Card thống kê).
3. **Quản lý Routing & State**: Áp dụng đúng kiến trúc Điều hướng và State đang có trong dự án (luôn kiểm tra file logic để đồng bộ).
4. **Clean Code & Format**: Chuẩn `camelCase` cho biến/hàm, `PascalCase` cho class. Sử dụng `const` cho các Widget tĩnh để tối ưu hiệu suất bộ nhớ. Xử lý bắt ngoại lệ (`try-catch`) cho các luồng xử lý dữ liệu.

## 🏗️ Quản lý Kiến trúc Feature-based
1. Đặt code vào đúng thư mục `features`, `models`, `widgets` chuyên biệt.
2. Quản lý Thư viện (`pubspec.yaml`): Tuân thủ luật giới hạn package ngoài, chỉ dùng những dependencies chuẩn hoặc xin ý kiến trước.
3. Chú ý dọn dẹp `Controller` qua hàm `dispose()` để chặn triệt để Memory Leak trên Mobile.
