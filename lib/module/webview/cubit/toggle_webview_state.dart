part of 'toggle_webview_cubit.dart';

class ToggleWebviewState extends Equatable {
  final bool toggleWebview;
  final int lastIndex;
  final int currentIndex;
  final bool isMinimized;
  final bool isInitialized;
  const ToggleWebviewState({
    this.toggleWebview = false,
    this.lastIndex = 0,
    this.currentIndex = 0,
    this.isMinimized = true,
    this.isInitialized = false,
  });
  ToggleWebviewState copyWith({
    bool? toggleWebview,
    int? lastIndex,
    int? currentIndex,
    bool? isMinimized,
    bool? isInitialized,
  }) {
    return ToggleWebviewState(
      toggleWebview: toggleWebview ?? this.toggleWebview,
      lastIndex: lastIndex ?? this.lastIndex,
      currentIndex: currentIndex ?? this.currentIndex,
      isMinimized: isMinimized ?? this.isMinimized,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  List<Object?> get props =>
      [toggleWebview, lastIndex, isMinimized, isInitialized, currentIndex];
}
