import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'navigator_state.dart';

class NavigatorCubit extends Cubit<MyNavigatorState> {
  NavigatorCubit() : super(MyNavigatorState());

  void navigatedToMessageScreen() {
    emit(state.copyWith(inMessageScreen: true));
  }

  void navigatedToOtherScreen() {
    emit(state.copyWith(inMessageScreen: false));
  }
}
