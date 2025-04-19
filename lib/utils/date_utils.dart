import 'package:intl/intl.dart';

String formatDate(String? rawDate) {
  if (rawDate == null || rawDate.isEmpty) return 'Chưa cập nhật';
  try {
    final date = DateTime.parse(rawDate);
    return DateFormat('dd/MM/yyyy').format(date);
  } catch (e) {
    return 'Sai định dạng ngày';
  }
}

String getEventStatus(dynamic timestart, dynamic timeend) {
  if (timestart == null || timeend == null) return "Không rõ trạng thái";

  try {
    final now = DateTime.now();
    final start = DateTime.parse(timestart);
    final end = DateTime.parse(timeend);

    if (now.isBefore(start)) return "Sắp diễn ra";
    if (now.isAfter(end)) return "Đã kết thúc";
    return "Đang diễn ra";
  } catch (e) {
    return "Thời gian không hợp lệ";
  }
}
