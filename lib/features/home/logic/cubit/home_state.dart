part of 'home_cubit.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState.initial() = _Initial;
  const factory HomeState.loading() = Loading;

  const factory HomeState.error({required String error}) = Error;
  const factory HomeState.pageChanged(int index) = PageChanged;
}
