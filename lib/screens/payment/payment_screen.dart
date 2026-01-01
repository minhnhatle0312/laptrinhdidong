// File: lib/screens/payment/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  // --- CẤU HÌNH TÀI KHOẢN NHẬN TIỀN CỦA BẠN ---
  final String bankId = 'MB'; // Mã ngân hàng (MB, VCB, TCB, VPB...)
  final String accountNo = '0945647176'; // Số tài khoản của bạn
  final String template = 'compact2'; // Giao diện QR (compact, compact2, qr_only)
  final String accountName = 'LE MINH NHAT'; // Tên chủ tài khoản

  @override
  Widget build(BuildContext context) {
    // Giả sử nhận số tiền từ màn hình trước (hoặc mặc định test)
    // Sau này bạn có thể truyền số tiền thật qua biến 'extra' của GoRouter
    final double amount = 500000; 
    final String content = 'THANHTOAN GARA 123'; // Nội dung chuyển khoản

    // Tạo link QR Code động (API miễn phí của VietQR)
    final String qrUrl = 'https://img.vietqr.io/image/$bankId-$accountNo-$template.png?amount=$amount&addInfo=$content&accountName=$accountName';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán chuyển khoản'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Quét mã để thanh toán',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Vui lòng mở App ngân hàng để quét mã bên dưới',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // --- KHUNG MÃ QR ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Ảnh QR từ VietQR
                    Image.network(
                      qrUrl,
                      width: 280,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 280,
                          width: 280,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(
                          height: 280,
                          width: 280,
                          child: Center(child: Text('Lỗi tải mã QR')),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                    
                    // Thông tin chi tiết text
                    _buildInfoRow('Chủ tài khoản', accountName),
                    _buildInfoRow('Số tài khoản', accountNo),
                    _buildInfoRow('Ngân hàng', bankId),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.black12),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Số tiền:', style: TextStyle(color: Colors.grey)),
                        Text(
                          _formatMoney(amount),
                          style: const TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.blue
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- NÚT XÁC NHẬN (GIẢ LẬP THÀNH CÔNG) ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handlePaymentSuccess(context),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Xác nhận đã chuyển khoản'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Màu xanh lá xác nhận
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Hủy bỏ / Quay lại', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  // Hàm xử lý khi bấm nút "Đã chuyển khoản"
  void _handlePaymentSuccess(BuildContext context) {
    // Ở đây bạn có thể gọi API cập nhật trạng thái đơn hàng nếu cần
    // Vì đây là chuyển khoản thủ công, ta giả định là thành công ngay
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Column(
          children: [
             Icon(Icons.check_circle, color: Colors.green, size: 60),
             SizedBox(height: 10),
             Text('Thanh toán thành công!'),
          ],
        ),
        content: const Text(
          'Hệ thống đã ghi nhận giao dịch của bạn.\nCảm ơn quý khách!',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Đóng Dialog
              context.go('/dashboard'); // Về trang chủ
            },
            child: const Text('Về trang chủ'),
          ),
        ],
      ),
    );
  }

  String _formatMoney(double amount) {
    final formatter = NumberFormat("#,###", "vi_VN");
    return '${formatter.format(amount)} đ';
  }
}