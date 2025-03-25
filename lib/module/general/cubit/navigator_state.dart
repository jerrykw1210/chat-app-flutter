part of 'navigator_cubit.dart';

class MyNavigatorState extends Equatable {
  MyNavigatorState({this.inMessageScreen = false});
  bool inMessageScreen;

  MyNavigatorState copyWith({bool? inMessageScreen}) {
    return MyNavigatorState(
      inMessageScreen: inMessageScreen ?? this.inMessageScreen,
    );
  }

  @override
  List<Object?> get props => [inMessageScreen];
}
