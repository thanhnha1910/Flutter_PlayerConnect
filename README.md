# PlayerConnect

**PlayerConnect** là một ứng dụng di động được thiết kế để kết nối những người đam mê thể thao với các cơ sở và cộng đồng thể thao. Dù bạn đang muốn đặt sân để chơi tennis, tìm một sân bóng đá địa phương, hay tham gia các trận đấu mở, PlayerConnect giúp bạn thực hiện điều đó một cách dễ dàng và tiện lợi.

_Dự án này được xây dựng bằng **Flutter** và nhấn mạnh vào việc phát triển một mã nguồn sạch, có khả năng mở rộng và dễ bảo trì bằng cách áp dụng phương pháp **Kiến trúc Sạch (Clean Architecture)**._

## ✨ Tính năng nổi bật

-   **Xác thực người dùng**: Đăng ký và đăng nhập an toàn bằng email/mật khẩu và Google Sign-In.
-   **Tìm kiếm dựa trên vị trí**: Khám phá và tìm kiếm các địa điểm thể thao gần bạn.
-   **Chi tiết địa điểm**: Xem thông tin chi tiết về các cơ sở thể thao, bao gồm sân có sẵn, hình ảnh và đánh giá từ người dùng.
-   **Đặt sân theo thời gian thực**: Đặt sân thể thao và sân chơi trong thời gian thực.
-   **Trò chuyện cộng đồng**: Tương tác với những người chơi khác và các cộng đồng thông qua các phòng trò chuyện tích hợp.
-   **Trận đấu mở**: Tìm và tham gia các trận đấu mở do cộng đồng tổ chức.
-   **Chatbot AI**: Nhận sự trợ giúp và câu trả lời cho các câu hỏi của bạn thông qua một chatbot thông minh.
-   **Hồ sơ người dùng**: Quản lý hồ sơ, xem các lượt đặt chỗ và theo dõi hoạt động của bạn.

---

## 🚀 Bắt đầu

Làm theo các hướng dẫn sau để sao chép và chạy dự án trên máy cục bộ của bạn cho mục đích phát triển và thử nghiệm.

### Yêu cầu

-   [Flutter SDK](https://flutter.dev/docs/get-started/install) (phiên bản 3.x trở lên)
-   [Dart SDK](https://dart.dev/get-dart)
-   Một IDE như [Android Studio](https://developer.android.com/studio) hoặc [VS Code](https://code.visualstudio.com/) với plugin Flutter.

### Cài đặt & Chạy

1.  **Sao chép repository:**
    ```sh
    git clone https://github.com/your-username/PlayerConnect.git
    cd PlayerConnect
    ```

2.  **Cài đặt các dependency:**
    ```sh
    flutter pub get
    ```

3.  **Chạy trình tạo mã:**
    Dự án này sử dụng trình tạo mã để quản lý dependency injection và các model dữ liệu. Chạy lệnh sau để tạo các tệp cần thiết:
    ```sh
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

4.  **Chạy ứng dụng:**
    ```sh
    flutter run
    ```

---

## 🛠️ Công nghệ & Các Dependency chính

-   **Framework**: [Flutter](https://flutter.dev/)
-   **Quản lý trạng thái**: [flutter_bloc](https://pub.dev/packages/flutter_bloc)
-   **Dependency Injection**: [get_it](https://pub.dev/packages/get_it) với [injectable](https://pub.dev/packages/injectable)
-   **Mạng**: [dio](https://pub.dev/packages/dio)
-   **Routing**: [auto_route](https://pub.dev/packages/auto_route) (hoặc giải pháp routing bạn chọn)
-   **Mô hình dữ liệu**: [freezed](https://pub.dev/packages/freezed), [json_serializable](https://pub.dev/packages/json_serializable)
-   **Xử lý lỗi**: [dartz](https://pub.dev/packages/dartz)
-   **Lưu trữ an toàn**: [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)
-   **Dịch vụ vị trí**: [geolocator](https://pub.dev/packages/geolocator), [google_maps_flutter](https://pub.dev/packages/google_maps_flutter)
-   **Xác thực**: [google_sign_in](https://pub.dev/packages/google_sign_in)

---

## 🏗️ Kiến trúc dự án

_Dự án này tuân thủ các nguyên tắc của **Kiến trúc Sạch (Clean Architecture)**, tách mã nguồn thành ba lớp riêng biệt: `Presentation`, `Domain`, và `Data`. Việc tách biệt các mối quan tâm này giúp ứng dụng dễ dàng kiểm thử, bảo trì và mở rộng hơn._

-   **`lib/presentation/`**: Lớp giao diện người dùng (Widgets, Screens, BLoCs).
-   **`lib/domain/`**: Lớp logic nghiệp vụ cốt lõi (Entities, Repositories, Use Cases).
-   **`lib/data/`**: Lớp dữ liệu (Data Sources, Models, Repository Implementations).
-   **`lib/core/`**: Mã nguồn dùng chung, các tiện ích và cấu hình (DI, Routing, Theme).

---

## 👨‍💻 Dành cho nhà phát triển: Cách đóng góp

Để duy trì tính nhất quán, các tính năng mới nên được triển khai theo các bước sau, đi từ logic nghiệp vụ cốt lõi ra ngoài giao diện người dùng.

### Bước 1: Xác định Logic cốt lõi (lớp `domain`)
1.  **Tạo/Cập nhật Entity**: Trong `lib/domain/entities/`, xác định đối tượng nghiệp vụ thuần túy.
2.  **Xác định Repository Contract**: Trong `lib/domain/repositories/`, xác định lớp trừu tượng cho các hoạt động dữ liệu.
3.  **Tạo Use Case**: Trong `lib/domain/usecases/`, tạo một lớp đóng gói một hành động nghiệp vụ cụ thể.

### Bước 2: Triển khai xử lý dữ liệu (lớp `data`)
1.  **Tạo/Cập nhật Model**: Trong `lib/data/models/`, tạo một model dữ liệu ánh xạ tới nguồn dữ liệu của bạn (ví dụ: JSON từ API).
2.  **Triển khai Data Source**: Trong `lib/data/datasources/`, tạo một lớp để lấy dữ liệu thô.
3.  **Triển khai Repository**: Trong `lib/data/repositories/`, tạo triển khai cụ thể của repository contract.

### Bước 3: Xây dựng UI & Trạng thái (lớp `presentation`)
1.  **Tạo BLoC/Cubit**: Trong `lib/presentation/bloc/`, tạo một BLoC để quản lý trạng thái của tính năng.
2.  **Phát triển UI**: Trong `lib/presentation/screens/` và `lib/presentation/widgets/`, xây dựng màn hình hoặc widget mới.

### Bước 4: Kết nối các Dependency
1.  **Đăng ký Dependencies**: Trong thiết lập dependency injection, thêm các annotation (`@injectable`, `@lazySingleton`, v.v.).
2.  **Chạy trình tạo mã**: Chạy `flutter pub run build_runner build --delete-conflicting-outputs`.