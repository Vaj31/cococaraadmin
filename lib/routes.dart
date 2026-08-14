import 'package:ccpladmin/features/po/presentation/views/pending_order_list.dart';

import 'package:ccpladmin/features/auth/presentation/views/forgot_password_screen.dart'
    as forgot_password;
import 'package:ccpladmin/features/auth/presentation/views/splash_screen.dart';
import 'package:ccpladmin/features/auth/presentation/views/login_screen.dart'
    as auth;
import 'package:ccpladmin/features/auth/presentation/views/reset_password_screen.dart'
    as reset_password;

import 'package:ccpladmin/features/auth/presentation/views/sign_up_screen.dart'
    as sign_up;
import 'package:ccpladmin/features/dashboard/presentation/views/analytics_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ccpladmin/features/po/presentation/views/polist_screen.dart';
import 'package:ccpladmin/services/auth_service.dart';

import 'package:ccpladmin/features/masters/presentation/views/customer_list_screen.dart';
import 'package:ccpladmin/features/masters/presentation/views/suppliers_master_screen.dart';
import 'package:ccpladmin/features/google_sync/presentation/views/google_sync_screen.dart';
import 'package:ccpladmin/features/shipping_schedule/presentation/views/shipping_schedule.dart';
import 'package:ccpladmin/features/po/presentation/views/create_pallet_screen.dart';
import 'package:ccpladmin/features/masters/presentation/views/pallet_list_screen.dart';
import 'package:ccpladmin/features/po/presentation/views/pallet_stickering_screen.dart';
import 'package:ccpladmin/features/production_report/presentation/views/production_report_screen.dart';
import 'package:ccpladmin/features/downloads/presentation/views/upload_doc_screen.dart';
import 'package:ccpladmin/features/downloads/presentation/views/download_doc_screen.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return AuthService.isLoggedIn
        ? null
        : const RouteSettings(name: '/auth/login');
  }
}

List<GetPage> getPageRoute() {
  var routes = [
    GetPage(name: '/splash', page: () => const SplashScreen()),
    GetPage(name: '/auth/login', page: () => auth.LoginScreen()),
    GetPage(
      name: '/auth/forgot_password',
      page: () => forgot_password.ForgotPasswordScreen(),
    ),
    GetPage(
      name: '/auth/reset_password',
      page: () => reset_password.ResetPasswordScreen(),
    ),
    GetPage(name: '/auth/register_account', page: () => sign_up.SignUpScreen()),

    GetPage(
      name: '/po/polist',
      page: () => PolistScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/dashboard/analytics',
      page: () => AnalyticsScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/po/pending_order_list',
      page: () => const PendingOrderList(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/masters/customers',
      page: () => const CustomerListScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/masters/suppliers',
      page: () => const SuppliersMasterScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/processing/google_sync',
      page: () => const GoogleSyncScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/ss/shipping_schedule',
      page: () => ShippingSchedule(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/po/create_pallet',
      page: () => CreatePalletScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/masters/pallet_list',
      page: () => const PalletListScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/palletsticker/pallet_stickering',
      page: () => PalletStickeringScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/processing/production_report',
      page: () => const ProductionReportScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/downloads/upload_doc',
      page: () => const UploadDocScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/downloads/download_doc',
      page: () => const DownloadDocScreen(),
      middlewares: [AuthMiddleware()],
    ),
  ];
  return routes
      .map(
        (e) => GetPage(
          name: e.name,
          page: e.page,
          middlewares: e.middlewares,
          transition: Transition.noTransition,
        ),
      )
      .toList();
}
