import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'toggle_webview_state.dart';

class ToggleWebviewCubit extends Cubit<ToggleWebviewState> {
  ToggleWebviewCubit() : super(const ToggleWebviewState());

  void reset() {
    emit(const ToggleWebviewState());
  }

  void setLastIndex(int index) {
    emit(state.copyWith(lastIndex: index));
  }

  void setIsMinimized(bool isMinimized) {
    emit(state.copyWith(isMinimized: isMinimized));
  }

  void setIsInitialized(bool isInitialized) {
    emit(state.copyWith(isInitialized: isInitialized));
  }

  void setToggleWebview(bool toggleWebview) {
    emit(state.copyWith(toggleWebview: toggleWebview));
  }

  void setCurrentIndex(int currentIndex) {
    emit(state.copyWith(
        currentIndex: currentIndex, lastIndex: state.currentIndex));
  }

  void openWebview() {
    emit(state.copyWith(
        currentIndex: 2, isMinimized: false, lastIndex: state.currentIndex));
  }
}
