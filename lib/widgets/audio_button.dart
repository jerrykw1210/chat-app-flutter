// import 'dart:async';
// import 'dart:developer';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:protech_mobile_chat_stream/module/chat/cubit/chat_trigger_cubit.dart';
// import 'package:record/record.dart';
// import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

// class AudioButton extends StatefulWidget {
//   const AudioButton({super.key});

//   @override
//   State<AudioButton> createState() => _AudioButtonState();
// }

// class _AudioButtonState extends State<AudioButton> {
//   Stopwatch stopwatch = Stopwatch();
//   AudioRecorder audioRecord = AudioRecorder();
//   late Timer _timer;
//   startStopwatch() {
//     stopwatch.start();

//     context.read<ChatTriggerCubit>().saveStopwatchTime(stopwatch.elapsed);
//   }

//   stopStopwatch() {
//     stopwatch.stop();
//     stopwatch.reset();
//     context.read<ChatTriggerCubit>().saveStopwatchTime(stopwatch.elapsed);
//     // setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LongPressDraggable(
//       //data: Colors.orangeAccent,
//       feedback: Transform.scale(
//         scale: 1.1,
//         child: Container(
//           padding: const EdgeInsets.all(8.0),
//           child: const Icon(Icons.mic),
//         ),
//       ),
//       onDragStarted: () async {
//         context.read<ChatTriggerCubit>().isRecording(true);
//         startStopwatch();

//         if (await audioRecord.hasPermission()) {
//           final Directory? downloadDir;
//           if (Platform.isAndroid) {
//             downloadDir = await getDownloadsDirectory();
//           } else {
//             downloadDir = await getApplicationDocumentsDirectory();
//           }

//           audioRecord.start(const RecordConfig(),
//               path:
//                   '${downloadDir?.path}/${DateTime.now().millisecondsSinceEpoch}.m4a');
//         }
//       },

//       onDragEnd: (details) async {
//         if (details.wasAccepted) {
//           // Handle drag to cancel (drop on target)
//           debugPrint('Recording canceled');
//           stopStopwatch();

//           context.read<ChatTriggerCubit>().isRecording(false);
//         } else {
//           // Handle successful recording (not canceled)
//           debugPrint('Recording finished');
//           final path = await audioRecord.stop();
//           log("recorded audio path $path");
//           stopStopwatch();
//           if (context.mounted) {
//             context.read<ChatTriggerCubit>().isRecording(false);
//             File file = File(path.toString());
//             log("file path ${await file.length()}");
//             file.length().then((fileSize) {
//               log("file length $fileSize");
//               StreamChannel.of(context)
//                   .channel
//                   .sendMessage(Message(attachments: [
//                     Attachment(
//                         type: "audio",
//                         file: AttachmentFile(size: fileSize, path: path)),
//                   ]));
//             });

//             // BlocProvider.of<ChatBloc>(context).add(
//             //     SendChat(path, widget.user, "audio", messages: widget.messages));
//           }
//         }
//       },
//       onDraggableCanceled: (velocity, offset) {},
//       child: InkWell(
//         child: Container(
//           padding: const EdgeInsets.all(8.0),
//           child: const Icon(Icons.mic),
//         ),
//       ),
//     );
//   }
// }
