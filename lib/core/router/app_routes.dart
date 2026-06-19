/// Centralized route paths and names for the app.
class AppRoutes {
  AppRoutes._();

  // Onboarding / auth
  static const splash = '/';
  static const phone = '/onboarding/phone';
  static const otp = '/onboarding/otp';
  static const thaidInfo = '/onboarding/thaid-info';
  static const thaidVerify = '/onboarding/thaid-verify';
  static const thaidMismatch = '/onboarding/thaid-mismatch';
  static const onboardingSuccess = '/onboarding/success';
  static const setPin = '/onboarding/set-pin';

  // Main
  static const home = '/home';

  // Loan detail / payment
  static const loanDetail = '/loan/detail';
  static const paymentChannels = '/loan/payment-channels';
  static const payLoan = '/loan/pay';
  static const paymentQr = '/loan/qr';
  static const receipt = '/loan/receipt';

  // Loan request (multi-step)
  static const loanRequest = '/loan/request';
}
