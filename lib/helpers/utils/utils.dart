import 'package:ccpladmin/helpers/extensions/date_time_extension.dart';
import 'package:ccpladmin/helpers/services/navigation_services.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class Utils {
  static void _showCustomToast({
    required String message,
    required String defaultTitle,
    required Color iconBgColor,
    required IconData iconData,
    required Color glowColor,
    required Color fallbackBgColor,
    String? title,
    BuildContext? context,
  }) {
    BuildContext? activeContext = context ?? Get.context ?? Get.overlayContext ?? NavigationService.navigatorKey.currentContext;

    if (activeContext != null) {
      try {
        if (Overlay.maybeOf(activeContext) != null) {
          FToast fToast = FToast()..init(activeContext);
          fToast.removeQueuedCustomToasts();

          Widget toast = Container(
            width: 360,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: const Color(0xfff3f4f6), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.12),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      iconData,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title ?? defaultTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xff111827),
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        message,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: Color(0xff6b7280),
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    fToast.removeCustomToast();
                  },
                  child: const Icon(
                    Icons.close,
                    color: Color(0xff9ca3af),
                    size: 18,
                  ),
                ),
              ],
            ),
          );

          fToast.showToast(
            child: GestureDetector(
              onTap: () {
                fToast.removeCustomToast();
              },
              child: toast,
            ),
            positionedToastBuilder: (BuildContext context, Widget child, ToastGravity? gravity) {
              final Widget positioned = Positioned(
                top: 24.0,
                left: 0.0,
                right: 0.0,
                child: Center(child: child),
              );
              return positioned;
            },
            toastDuration: const Duration(seconds: 4),
          );
          return;
        }
      } catch (e) {
        debugPrint("FToast error: $e");
      }
    }

    // Fallback to standard toast if no overlay is available
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: fallbackBgColor,
      textColor: Colors.white,
      timeInSecForIosWeb: 4,
    );
  }

  static void showErrorToast(String message, {String? title, BuildContext? context}) {
    _showCustomToast(
      message: message,
      defaultTitle: "Error toast",
      iconBgColor: const Color(0xfff3a090),
      iconData: Icons.block,
      glowColor: const Color(0xfff3a090),
      fallbackBgColor: const Color(0xffdc2626),
      title: title,
      context: context,
    );
  }

  static void showSuccessToast(String message, {String? title, BuildContext? context}) {
    _showCustomToast(
      message: message,
      defaultTitle: "Success 😊",
      iconBgColor: const Color(0xff86efac),
      iconData: Icons.check_rounded,
      glowColor: const Color(0xff86efac),
      fallbackBgColor: const Color(0xff10b981),
      title: title,
      context: context,
    );
  }

  static void showWarningToast(String message, {String? title, BuildContext? context}) {
    _showCustomToast(
      message: message,
      defaultTitle: "Warning toast",
      iconBgColor: const Color(0xfffba857),
      iconData: Icons.warning_amber_rounded,
      glowColor: const Color(0xfffba857),
      fallbackBgColor: const Color(0xfff59e0b),
      title: title,
      context: context,
    );
  }

  static void showInfoToast(String message, {String? title, BuildContext? context}) {
    _showCustomToast(
      message: message,
      defaultTitle: "Info toast",
      iconBgColor: const Color(0xff93c5fd),
      iconData: Icons.info_outline_rounded,
      glowColor: const Color(0xff93c5fd),
      fallbackBgColor: const Color(0xff3b82f6),
      title: title,
      context: context,
    );
  }
  static String getDateStringFromDateTime(DateTime dateTime, {bool showMonthShort = false}) {
    String date = dateTime.day < 10 ? "0${dateTime.day}" : dateTime.day.toString();
    late String month;
    if (showMonthShort) {
      month = dateTime.getMonthName();
    } else {
      month = dateTime.month < 10 ? "0${dateTime.month}" : dateTime.month.toString();
    }

    String year = dateTime.year.toString();
    String separator = showMonthShort ? " " : "/";
    return "$date$separator$month$separator$year";
  }

  static String getTimeStringFromDateTime(DateTime dateTime, {bool showSecond = true}) {
    String hour = dateTime.hour.toString();
    if (dateTime.hour > 12) {
      hour = (dateTime.hour - 12).toString();
    }

    String minute = dateTime.minute < 10 ? "0${dateTime.minute}" : dateTime.minute.toString();
    String second = "";

    if (showSecond) {
      second = dateTime.second < 10 ? "0${dateTime.second}" : dateTime.second.toString();
    }
    String meridian = "";
    meridian = dateTime.hour < 12 ? " AM" : " PM";

    return "$hour:$minute${showSecond ? ":" : ""}$second$meridian";
  }

  static String getDateTimeStringFromDateTime(
    DateTime dateTime, {
    bool showSecond = true,
    bool showDate = true,
    bool showTime = true,
    bool showMonthShort = false,
  }) {
    if (showDate && !showTime) {
      return getDateStringFromDateTime(dateTime);
    } else if (!showDate && showTime) {
      return getTimeStringFromDateTime(dateTime, showSecond: showSecond);
    }
    return "${getDateStringFromDateTime(dateTime, showMonthShort: showMonthShort)} ${getTimeStringFromDateTime(dateTime, showSecond: showSecond)}";
  }

  static String getStorageStringFromByte(int bytes) {
    double b = bytes.toDouble(); //1024
    double k = bytes / 1024; //1
    double m = k / 1024; //0.001
    double g = m / 1024; //...
    double t = g / 1024; //...

    if (t >= 1) {
      return "${t.toStringAsFixed(2)} TB";
    } else if (g >= 1) {
      return "${g.toStringAsFixed(2)} GB";
    } else if (m >= 1) {
      return "${m.toStringAsFixed(2)} MB";
    } else if (k >= 1) {
      return "${k.toStringAsFixed(2)} KB";
    } else {
      return "${b.toStringAsFixed(2)} Bytes";
    }
  }
}
