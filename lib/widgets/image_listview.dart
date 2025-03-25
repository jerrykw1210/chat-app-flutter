// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:protech_mobile_chat_stream/model/database.dart';

// class ImageListview extends StatelessWidget {
//   const ImageListview({super.key, required this.message});
//   final Message message;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "${message.attachment?.length} photos",
//           style: Theme.of(context)
//               .textTheme
//               .bodyLarge
//               ?.copyWith(color: Colors.white),
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: ListView.separated(
//           itemCount: message.attachment?.length,
//           separatorBuilder: (context, index) =>
//               const Padding(padding: EdgeInsets.only(bottom: 10)),
//           itemBuilder: (context, index) {
//             return Stack(children: [
//               CachedNetworkImage(
//                 imageUrl: message.attachment![index].imageUrl.toString(),
//                 width: double.infinity,
//                 fit: BoxFit.fill,
//               ),
//               Positioned(
//                 bottom: 0,
//                 right: 10,
//                 child: Padding(
//                   padding: const EdgeInsets.only(right: 5.0, bottom: 5.0),
//                   child: Text(
//                     DateFormat("HH:mm").format(message.createdAt.toLocal()),
//                     style: Theme.of(context)
//                         .textTheme
//                         .bodyMedium
//                         ?.copyWith(color: Colors.white),
//                   ),
//                 ),
//               ),
//             ]);
//           },
//         ),
//       ),
//     );
//   }
// }
