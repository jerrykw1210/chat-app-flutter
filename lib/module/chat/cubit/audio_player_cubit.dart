import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'audio_player_state.dart';

class AudioPlayerCubit extends Cubit<AudioPlayerState> {
  AudioPlayerCubit() : super(const AudioPlayerState());

  void play({required String voiceSource}) {
    emit(AudioPlayerState(isPlaying: true, voiceSource: voiceSource));
  }

  void pause() {
    emit(const AudioPlayerState(isPlaying: false, voiceSource: null));
  }
}
