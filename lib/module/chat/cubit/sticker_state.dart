part of 'sticker_cubit.dart';

enum AddStickerStatus { initial, loading, success, failure }
enum DeleteStickerStatus { initial, loading, success, failure }
enum FetchStickerStatus { initial, loading, success, failure }

class StickerState extends Equatable {
  final AddStickerStatus addStickerStatus;
  final DeleteStickerStatus deleteStickerStatus;
  final FetchStickerStatus fetchStickerStatus;
  const StickerState({
    this.addStickerStatus = AddStickerStatus.initial,
    this.deleteStickerStatus = DeleteStickerStatus.initial,
    this.fetchStickerStatus = FetchStickerStatus.initial,
  });
  StickerState copyWith({
    AddStickerStatus? addStickerStatus,
    DeleteStickerStatus? deleteStickerStatus,
    FetchStickerStatus? fetchStickerStatus,
  }) {
    return StickerState(
      addStickerStatus: addStickerStatus ?? this.addStickerStatus,
      deleteStickerStatus: deleteStickerStatus ?? this.deleteStickerStatus,
      fetchStickerStatus: fetchStickerStatus ?? this.fetchStickerStatus,
    );
  }

  @override
  List<Object> get props => [addStickerStatus, deleteStickerStatus, fetchStickerStatus];
}


