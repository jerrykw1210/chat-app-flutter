import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/chat/screen/pin_message_screen.dart';
import 'package:protech_mobile_chat_stream/module/friend/cubit/user_cubit.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/service/database_helper.dart';
import 'package:protech_mobile_chat_stream/utils/colors.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/toast_utils.dart';
import 'package:protech_mobile_chat_stream/widgets/chat_avatar.dart';

class FriendProfileScreen extends StatelessWidget {
  const FriendProfileScreen({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    String conversationId =
        ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Strings.friendProfile,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColor.greyBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                return ListTile(
                  tileColor: Colors.white,
                  leading: ChatAvatar(
                      errorWidget: CircleAvatar(
                        child: Image.network(
                          width: 80,
                          height: 80,
                          state.userProfile?.name[0].toString() ?? "",
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                                  width: 80,
                                  height: 80,
                                  'assets/default-img/default-user.png'),
                        ),
                      ),
                      targetId: state.userProfile?.id.toString() ?? "",
                      radius: 20),
                  title: Text(state.userProfile?.name.toString() ?? ""),
                  subtitle: Text(state.userProfile?.id.toString() ?? ""),
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: Container(
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10.0)),
                    child: const Icon(
                      Icons.photo,
                      color: Colors.white,
                    )),
                tileColor: Colors.white,
                title: Text(Strings.mediaFile),
                onTap: () => Navigator.pushNamed(
                    context, AppPage.friendMedia.routeName,
                    arguments: conversationId),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StreamBuilder(
                      stream: sl<DatabaseHelper>().getMediaTotal(conversationId,
                          ["IMAGE_TYPE", "VIDEO_TYPE", "FILE_TYPE"]),
                      builder: (context, message) {
                        return Text(
                          message.data?.length.toString() ?? "0",
                          style: Theme.of(context).textTheme.bodyMedium,
                        );
                      },
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Image.asset("assets/Buttons/pinned-icon.jpg"),
              tileColor: Colors.white,
              title: Text(Strings.pinnedMessages),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PinMessageScreen(
                    conversationId: conversationId,
                  ),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StreamBuilder(
                    stream:
                        sl<DatabaseHelper>().getPinnedMessage(conversationId),
                    builder: (context, message) {
                      return Text(
                        message.data?.length.toString() ?? "0",
                        style: Theme.of(context).textTheme.bodyMedium,
                      );
                    },
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                  ),
                ],
              ),
            ),
            // ListTile(
            //     leading: Container(
            //         decoration: BoxDecoration(
            //             shape: BoxShape.rectangle,
            //             borderRadius: BorderRadius.circular(6.0),
            //             color: Colors.red),
            //         child:
            //             SvgPicture.asset("assets/Buttons/slash-circle-01.svg")),
            //     tileColor: Colors.white,
            //     title: Text(Strings.blacklist),
            //     trailing: CupertinoSwitch(
            //       value: false,
            //       onChanged: (value) {},
            //     )),

            ListTile(
              tileColor: Colors.white,
              title: BlocConsumer<UserCubit, UserState>(
                listener: (context, state) {
                  if (state.deleteFriendStatus == DeleteFriendStatus.success) {
                    ToastUtils.showToast(
                      context: context,
                      msg: Strings.friendDeletedSuccessfully,
                      type: Type.success,
                    );
                    context.read<UserCubit>().resetAllUserStatus();
                    Navigator.of(context).popUntil(
                        ModalRoute.withName(AppPage.navBar.routeName));
                  }
                },
                builder: (context, state) {
                  return TextButton(
                      onPressed: () {
                        context
                            .read<UserCubit>()
                            .deleteFriend(state.userProfile!.id);
                      },
                      child: Text(
                        Strings.deleteFriend,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: Colors.red),
                      ));
                },
              ),
            ),

            // const ListTile(
            //   tileColor: Colors.white,
            //   title: Text("Group"),
            //   trailing: Icon(Icons.arrow_forward_ios),
            // ),
            // const Padding(
            //   padding: EdgeInsets.symmetric(vertical: 8.0),
            //   child: ListTile(
            //     tileColor: Colors.white,
            //     title: Text("Personal Signature"),
            //     trailing: Icon(Icons.arrow_forward_ios),
            //   ),
            // ),
            // ListTile(
            //   tileColor: Colors.white,
            //   title: const Text("Add to blacklist"),
            //   subtitle: const Text(
            //       "After enabled, you will not receive messages from the other party"),
            //   trailing: CupertinoSwitch(
            //     value: false,
            //     onChanged: (value) {},
            //   ),
            // ),
            // const SizedBox(
            //   height: 50,
            // ),
            // FilledButton(onPressed: () {}, child: const Text("Delete Friend"))
          ],
        ),
      ),
    );
  }
}
