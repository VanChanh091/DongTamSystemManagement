import "package:dongtam/constant/request_type.dart";
import "package:dongtam/data/controller/notification_controller.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:intl/intl.dart";

void showNotificationDialog(NotificationController controller) {
  Get.dialog(
    AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          const Icon(Icons.hub_outlined, color: Color.fromARGB(255, 252, 220, 41)),
          const SizedBox(width: 10),
          const Text(
            "Trung Tâm Quản Lý Thông Báo",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),

          Obx(
            () => IconButton(
              icon:
                  controller.isLoading.value
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black54),
                      )
                      : const Icon(Icons.refresh, color: Colors.black87, size: 20),
              onPressed:
                  controller.isLoading.value ? null : () => controller.fetchOldNotifications(),
              tooltip: "Tải lại dữ liệu",
            ),
          ),

          IconButton(
            icon: const Icon(Icons.close, color: Colors.black, size: 20),
            onPressed: () => Get.back(),
          ),
        ],
      ),

      content: SizedBox(
        width: 600,
        height: 750,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color.fromARGB(255, 252, 220, 41)),
            );
          }

          if (controller.notifications.isEmpty) {
            return const Center(
              child: Text(
                "Không có thông báo hoặc tác vụ nào đang chờ",
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
            );
          }

          return ListView.builder(
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notif = controller.notifications[index];
              final payload = notif.payload;

              final formatter = DateFormat("dd/MM/yyyy");
              final parsedDate = DateTime.tryParse(payload["newDeliveryDate"]?.toString() ?? "");

              // FIX BUG: "HH:mm" (phút dùng mm thường, MM hoa là Tháng)
              final timeRaw = notif.createdAt;
              final createdDateTime =
                  timeRaw != null ? DateTime.tryParse(timeRaw.toString()) : null;
              final createdTimeStr =
                  createdDateTime != null
                      ? DateFormat("dd/MM/yyyy HH:mm").format(createdDateTime)
                      : "";

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF282A36),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        notif.isRead
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color.fromARGB(255, 252, 220, 41).withValues(alpha: 0.6),
                    width: notif.isRead ? 1 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Từ:",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.cyanAccent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.cyanAccent.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Text(
                                  notif.senderName,
                                  style: TextStyle(
                                    color: Colors.cyan.shade300,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (createdTimeStr.isNotEmpty)
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 13,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  createdTimeStr,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      //title
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: "Tiêu đề: ",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  TextSpan(
                                    text: notif.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      //content
                      if (payload["orderId"] != null ||
                          payload["newDeliveryDate"] != null ||
                          payload["reason"] != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Mã đơn & Ngày giao
                              if (payload["orderId"] != null || payload["newDeliveryDate"] != null)
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 8,
                                  children: [
                                    if (payload["orderId"] != null)
                                      _buildMiniBadge(
                                        icon: Icons.tag,
                                        text: "Mã Đơn: ${payload["orderId"]}",
                                        textColor: Colors.white70,
                                      ),
                                    if (payload["newDeliveryDate"] != null && parsedDate != null)
                                      _buildMiniBadge(
                                        icon: Icons.calendar_month_outlined,
                                        text: "Ngày giao mới: ${formatter.format(parsedDate)}",
                                        textColor: Colors.green.shade300,
                                      ),
                                  ],
                                ),

                              // Lý do
                              if (payload["reason"] != null) ...[
                                if (payload["orderId"] != null ||
                                    payload["newDeliveryDate"] != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Divider(
                                      color: Colors.white.withValues(alpha: 0.08),
                                      height: 1,
                                    ),
                                  ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Lý do: ",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "${payload["reason"]}",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12.5,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),

                      //button
                      Builder(
                        builder:
                            (context) => buildNotificationActionButtons(
                              context: context,
                              payload: payload,
                              notif: notif,
                              controller: controller,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    ),
  );
}

Widget buildNotificationActionButtons({
  required BuildContext context,
  required Map<String, dynamic> payload,
  required dynamic notif,
  required dynamic controller,
}) {
  //parse enum from payload
  final requestType = RequestType.fromString(notif.type ?? "");
  final status = RequestStatus.fromString(payload['status']?.toString());
  final bool isAction = payload['action']?.toString().toUpperCase() == 'RESPONSE';

  debugPrint("DEBUG: isAction: $isAction, type=$requestType, status=$status");

  if (isAction) {
    if (status == RequestStatus.approved ||
        requestType == RequestType.orderConfirm ||
        requestType == RequestType.orderUpdate) {
      return _buildStatusRow(
        label: "Đã chấp nhận",
        icon: Icons.check_circle_outline,
        color: Colors.green,
        btnColor: Colors.green.shade500,
        onPressed:
            () => controller.executeAction(
              context: context,
              notif: notif,
              action: "CONFIRM",
              type: "order",
            ),
      );
    }

    if (status == RequestStatus.rejected || requestType == RequestType.orderReject) {
      return _buildStatusRow(
        label: "Bị từ chối",
        icon: Icons.cancel_outlined,
        color: Colors.red,
        btnColor: Colors.green.shade600,
        onPressed:
            () => controller.executeAction(
              context: context,
              notif: notif,
              action: "CONFIRM",
              type: "order",
            ),
      );
    }
  }

  if (status == RequestStatus.pending) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.redAccent,
            side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            minimumSize: const Size(0, 36),
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          onPressed:
              () => controller.executeAction(
                context: context,
                notif: notif,
                action: "rejected",
                type: "planning",
              ),
          child: const Text(
            "Từ chối",
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 226, 198, 38),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            minimumSize: const Size(0, 36),
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            elevation: 0,
          ),
          onPressed:
              () => controller.executeAction(
                context: context,
                notif: notif,
                action: "approved",
                type: "planning",
              ),
          child: const Text(
            "Chấp nhận",
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  return const SizedBox.shrink();
}

Widget _buildStatusRow({
  required String label,
  required IconData icon,
  required MaterialColor color,
  required Color btnColor,
  required VoidCallback onPressed,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Icon(icon, size: 16, color: color.shade600),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color.shade700, fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: btnColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          minimumSize: const Size(0, 36),
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: const Text(
          "Xác nhận",
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
        ),
      ),
    ],
  );
}

Widget _buildMiniBadge({required IconData icon, required String text, required Color textColor}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12.5, color: textColor.withValues(alpha: 0.6)),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(color: textColor, fontSize: 12.5, fontWeight: FontWeight.w500)),
    ],
  );
}
