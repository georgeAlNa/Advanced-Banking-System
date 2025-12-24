part of 'signup_cubit.dart'; // Fix spacing for consistency

@freezed
class SignupState with _$SignupState {
  const factory SignupState.initial() = _Initial;
  const factory SignupState.loading() = _Loading;
  const factory SignupState.otpSent() = _OtpSent; 
  const factory SignupState.error(String message) = _Error;
}
