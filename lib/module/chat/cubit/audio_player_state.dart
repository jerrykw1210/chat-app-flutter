part of 'audio_player_cubit.dart';

class AudioPlayerState extends Equatable {
  final bool isPlaying;
  final String? voiceSource;
  const AudioPlayerState({this.isPlaying = false, this.voiceSource});

  AudioPlayerState copyWith({bool? isPlaying, String? voiceSource}) {
    return AudioPlayerState(
        isPlaying: isPlaying ?? this.isPlaying,
        voiceSource: voiceSource ?? this.voiceSource);
  }

  @override
  List<Object?> get props => [isPlaying, voiceSource];
}
