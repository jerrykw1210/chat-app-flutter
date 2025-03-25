// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';

// class FeedbackScreen extends StatelessWidget {
//   FeedbackScreen({super.key});
//   final ImagePicker _picker = ImagePicker();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 10.0),
//                 child: Text(
//                   "Feedback Type",
//                   style: Theme.of(context)
//                       .textTheme
//                       .titleMedium
//                       ?.copyWith(fontWeight: FontWeight.bold),
//                 ),
//               ),
//               BlocBuilder<ProfileCubit, ProfileState>(
//                 builder: (context, state) {
//                   return Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: Strings.feedbackList
//                           .map((feedbackType) => FilledButton(
//                               onPressed: () {
//                                 context.read<ProfileCubit>().selectFeedbackType(
//                                     feedbackType.toLowerCase());
//                               },
//                               style: FilledButton.styleFrom(
//                                   backgroundColor:
//                                       state.feedbackType.toLowerCase() ==
//                                               feedbackType.toLowerCase()
//                                           ? Colors.blue
//                                           : AppColor.greyBackgroundColor),
//                               child: Text(
//                                 feedbackType,
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .bodyMedium
//                                     ?.copyWith(
//                                         color:
//                                             state.feedbackType.toLowerCase() ==
//                                                     feedbackType.toLowerCase()
//                                                 ? Colors.white
//                                                 : AppColor.greyText),
//                               )))
//                           .toList());
//                 },
//               ),
//               const Divider(),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 10.0),
//                 child: Text("Feedback Content",
//                     style: Theme.of(context)
//                         .textTheme
//                         .titleMedium
//                         ?.copyWith(fontWeight: FontWeight.bold)),
//               ),
//               Container(
//                 padding: const EdgeInsets.all(10.0),
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10.0),
//                     color: AppColor.greyBackgroundColor),
//                 child: TextField(
//                   minLines: 5,
//                   maxLines: 8,
//                   maxLength: 300,
//                   decoration: InputDecoration(
//                       border: InputBorder.none,
//                       hintText:
//                           "Please try to describe the feedback in detail and we will deal with it for you as soon as possible",
//                       hintStyle: Theme.of(context)
//                           .textTheme
//                           .bodyMedium
//                           ?.copyWith(color: AppColor.greyText)),
//                 ),
//               ),
//               BlocBuilder<ProfileCubit, ProfileState>(
//                 builder: (context, state) {
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 10.0),
//                         child: Text(
//                             "Feedback Screenshots (${context.read<ProfileCubit>().state.imageList.length}/5)",
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .titleMedium
//                                 ?.copyWith(fontWeight: FontWeight.bold)),
//                       ),
//                       Wrap(
//                         children: [
//                           if (state.imageList.isNotEmpty)
//                             Wrap(
//                               children: state.imageList
//                                   .map((image) => SizedBox(
//                                       width: 80,
//                                       height: 80,
//                                       child: Image.file(
//                                         File(image.path),
//                                         fit: BoxFit.cover,
//                                       )))
//                                   .toList(),
//                             ),
//                           GestureDetector(
//                             onTap: () async {
//                               final image = await _picker.pickImage(
//                                   source: ImageSource.gallery);
//                               if (context.mounted) {
//                                 context
//                                     .read<ProfileCubit>()
//                                     .addFeedbackScreenshot(image!);
//                               }
//                             },
//                             child: Container(
//                               width: 80,
//                               height: 80,
//                               decoration: const BoxDecoration(
//                                   color: AppColor.greyBackgroundColor),
//                               child: const Icon(
//                                 Icons.add,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   );
//                 },
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 50.0),
//                 child: Align(
//                   alignment: Alignment.center,
//                   child: SizedBox(
//                     width: 300,
//                     child: FilledButton(
//                         onPressed: () {}, child: const Text("Submit")),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
