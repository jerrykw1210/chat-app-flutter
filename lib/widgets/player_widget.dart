import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart' as wave;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:protech_mobile_chat_stream/constants/network_constants.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/audio_player_cubit.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';

class PlayerWidget extends StatefulWidget {
  final bool isReceiver;
  final String voiceSource;
  final bool isLocal;

  const PlayerWidget({
    required this.isReceiver,
    required this.voiceSource,
    this.isLocal = true,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState();
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  bool _isPlying = false;

  String duration = "00:00";

  //String get _positionText => _position?.toString().split('.').first ?? '';
  List<double> waveformSamples = [];

  final wave.PlayerController _playerController = wave.PlayerController();

  @override
  void initState() {
    super.initState();

    _initAudioWaveController();
  }

  String formatMilliseconds(int milliseconds) {
    // Convert milliseconds to seconds
    int totalSeconds = (milliseconds ~/ 1000);

    // Calculate minutes and seconds
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;

    // Format to 00:00
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _extractFileName(String url) {
    log("audio file url $url");
    int start = url.indexOf("attachments/") + "attachments/".length;

    int end = url.indexOf("?", start);

    String fileName = url.substring(start, end);

    return fileName;
  }

  Future<void> _initAudioWaveController() async {
    File audioFile;
    if (widget.isLocal) {
      audioFile = File(widget.voiceSource);
    } else {
      // String fileName = _extractFileName(widget.voiceSource);

      // final directory = await getApplicationDocumentsDirectory();

      // audioFile = File("${directory.path}/$fileName");

      // bool fileExist = await audioFile.exists();

      // if (!fileExist) {
      //   audioFile = await downloadFile(widget.voiceSource, fileName);
      // }

      String fileName = widget.voiceSource;

      final directory = await getApplicationDocumentsDirectory();

      audioFile = File("${directory.path}/$fileName");

      bool fileExist = await audioFile.exists();

      if (!fileExist) {
        audioFile = await downloadFile(widget.voiceSource, widget.voiceSource);
      }
    }

    await _playerController.preparePlayer(
        path: audioFile.path,
        shouldExtractWaveform: true,
        noOfSamples: const wave.PlayerWaveStyle().getSamplesForWidth(150),
        volume: 1);

    setState(
        () => duration = formatMilliseconds(_playerController.maxDuration));

    _playerController.onCurrentDurationChanged.listen((audioDuration) {
      int remainingDuration = _playerController.maxDuration - audioDuration;
      setState(() {
        duration = formatMilliseconds(remainingDuration);
      });
    });

    _playerController.onPlayerStateChanged.listen((state) async {
      log("player state $state");
      if (state == wave.PlayerState.playing) {
        setState(() {
          _isPlying = true;
        });
      }

      if (state == wave.PlayerState.paused) {
        setState(() {
          _isPlying = false;
        });
      }

      if (state == wave.PlayerState.stopped) {
        setState(() {
          _isPlying = false;
        });
      }
    });
  }

  @override
  void setState(VoidCallback fn) {
    // Subscriptions only can be closed asynchronously,
    // therefore events can occur after widget has been disposed.
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    super.dispose();
  }

  // Function to download the file
  Future<File> downloadFile(String url, String fileName) async {
    // final response = await http.get(Uri.parse(url));
    // final directory = await getTemporaryDirectory();
    // final file = File('${directory.path}/$fileName');

    // // Write the downloaded bytes to a file
    // return file.writeAsBytes(response.bodyBytes);

    String? jwtToken = sl<CredentialService>().jwtToken;
    Map<String, String> headers = {"Authorization": "Bearer $jwtToken"};
    try {
      final res = await http.get(
          Uri.parse("${NetworkConstants.getFileUrl}?fileUrl=$fileName"),
          headers: headers);
      if (res.statusCode == 200) {
        log("status ${res.statusCode}");
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');

        // Write the downloaded bytes to a file
        return file.writeAsBytes(res.bodyBytes);
      } else {
        throw Exception("Failed to get image. Status code: ${res.statusCode}");
      }
    } on Exception catch (e) {
      throw Exception("Failed to get image. Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AudioPlayerCubit, AudioPlayerState>(
      listener: (context, state) {
        if (state.isPlaying && state.voiceSource != widget.voiceSource) {
          _pause();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.only(left: 5, right: 12, top: 6, bottom: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _isPlying
                    ? IconButton(
                        constraints: const BoxConstraints(
                            minHeight: 30,
                            minWidth: 30,
                            maxHeight: 32,
                            maxWidth: 32),
                        padding: EdgeInsets.zero,
                        key: const Key('pause_button'),
                        onPressed: _isPlying ? _pause : null,
                        icon: Icon(
                          Icons.pause,
                          color: Theme.of(context).primaryColor,
                        ),
                        style:
                            IconButton.styleFrom(backgroundColor: Colors.white),
                      )
                    : IconButton(
                        constraints: const BoxConstraints(
                            minHeight: 30,
                            minWidth: 30,
                            maxHeight: 32,
                            maxWidth: 32),
                        padding: EdgeInsets.zero,
                        key: const Key('play_button'),
                        onPressed: _isPlying ? null : _play,
                        icon: Icon(
                          Icons.play_arrow,
                          color: Theme.of(context).primaryColor,
                        ),
                        style:
                            IconButton.styleFrom(backgroundColor: Colors.white),
                      ),
                wave.AudioFileWaveforms(
                  size: const Size(100, 50),
                  playerController: _playerController,
                  enableSeekGesture: true,
                  waveformType: wave.WaveformType.fitWidth,
                  // continuousWaveform: true,
                  waveformData: const [],
                  playerWaveStyle: const wave.PlayerWaveStyle(
                      fixedWaveColor: Color.fromRGBO(0, 200, 254, 1),
                      liveWaveColor: Colors.white,
                      scaleFactor: 100,
                      waveThickness: 2,
                      spacing: 5),
                ),
                const SizedBox(width: 5),
                SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(duration,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              widget.isReceiver ? Colors.black : Colors.white,
                        )),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _play() async {
    // await player.resume();
    // setState(() => _playerState = PlayerState.playing);
    await _playerController.seekTo(0);
    await _playerController.startPlayer(finishMode: wave.FinishMode.pause);
    context.read<AudioPlayerCubit>().play(voiceSource: widget.voiceSource);
  }

  Future<void> _pause() async {
    // await player.pause();
    // setState(() => _playerState = PlayerState.paused);
    await _playerController.pausePlayer();
  }
}
