import 'package:go_router/go_router.dart';

import '../../features/auth/pages/phone_page.dart';
import '../../features/auth/pages/splash_page.dart';
import '../../features/auth/pages/pin_login_page.dart';
import '../../features/auth/pages/otp_page.dart';
import '../../features/auth/pages/thaid_info_page.dart';
import '../../features/auth/pages/thaid_verify_page.dart';
import '../../features/auth/pages/thaid_mismatch_page.dart';
import '../../features/auth/pages/onboarding_success_page.dart';
import '../../features/auth/pages/set_pin_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/loan/pages/loan_detail_page.dart';
import '../../features/loan/pages/payment_channels_page.dart';
import '../../features/loan/pages/pay_loan_page.dart';
import '../../features/loan/pages/payment_qr_page.dart';
import '../../features/loan/pages/receipt_page.dart';
import '../../features/loan/pages/loan_request_page.dart';
import 'app_routes.dart';

/// Application router.
///
/// Auth/onboarding screens are implemented; home, loan detail, and loan request
/// remain placeholders until their dedicated bolts.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.pinLogin,
        builder: (context, state) => const PinLoginPage(),
      ),
      GoRoute(
        path: AppRoutes.phone,
        builder: (context, state) => const PhonePage(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) => const OtpPage(),
      ),
      GoRoute(
        path: AppRoutes.thaidInfo,
        builder: (context, state) => const ThaidInfoPage(),
      ),
      GoRoute(
        path: AppRoutes.thaidVerify,
        builder: (context, state) => const ThaidVerifyPage(),
      ),
      GoRoute(
        path: AppRoutes.thaidMismatch,
        builder: (context, state) => const ThaidMismatchPage(),
      ),
      GoRoute(
        path: AppRoutes.onboardingSuccess,
        // ThaiID redirects (deep link) to this route carrying the verification
        // session id, e.g. sawadfinnix://sawadfinnix.com/onboarding/success?sessionId=...
        builder: (context, state) => OnboardingSuccessPage(
          sessionId: state.uri.queryParameters['sessionId'] ??
              state.uri.queryParameters['session_id'] ??
              state.uri.queryParameters['session'],
        ),
      ),
      GoRoute(
        path: AppRoutes.setPin,
        builder: (context, state) => const SetPinPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.loanDetail,
        builder: (context, state) => const LoanDetailPage(),
      ),
      GoRoute(
        path: AppRoutes.paymentChannels,
        builder: (context, state) => const PaymentChannelsPage(),
      ),
      GoRoute(
        path: AppRoutes.payLoan,
        builder: (context, state) => const PayLoanPage(),
      ),
      GoRoute(
        path: AppRoutes.paymentQr,
        builder: (context, state) => const PaymentQrPage(),
      ),
      GoRoute(
        path: AppRoutes.receipt,
        builder: (context, state) => const ReceiptPage(),
      ),
      GoRoute(
        path: AppRoutes.loanRequest,
        builder: (context, state) => const LoanRequestPage(),
      ),
    ],
  );
}
