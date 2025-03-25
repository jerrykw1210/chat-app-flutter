import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/friend/cubit/user_cubit.dart';
import 'package:protech_mobile_chat_stream/module/friend/screen/search_friend_result_screen.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/utils/colors.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:protech_mobile_chat_stream/utils/toast_utils.dart';
import 'package:protech_mobile_chat_stream/widgets/chat_avatar.dart';
import 'package:turms_client_dart/turms_client.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  TextEditingController idController = TextEditingController();
  bool searching = false;
  @override
  void initState() {
    context.read<UserCubit>().getFriendRequest();
    super.initState();
  }

  Widget userInfoTiles(UserInfo? userInfo) {
    return Column(
      children: [
        ListTile(
          tileColor: Colors.white,
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SearchFriendResult(
                        userInfo: userInfo,
                        friendMethod: "id",
                      ))),
          leading: ChatAvatar(
              errorWidget: CircleAvatar(
                radius: 33,
                backgroundColor: Theme.of(context).primaryColorLight,
                child: ClipOval(
                  child: Text(userInfo!.name[0],
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
              targetId: userInfo.id.toString(),
              radius: 20),
          horizontalTitleGap: 10,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userInfo.name,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w500)),
              Text("Prochat ID: ${userInfo.id}",
                  style: const TextStyle(
                      color: Color.fromRGBO(126, 126, 130, 1),
                      fontSize: 13,
                      fontWeight: FontWeight.w400)),
            ],
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 24.0),
        //   child: SizedBox(
        //       width: MediaQuery.sizeOf(context).width,
        //       child: ElevatedButton(
        //           style: ElevatedButton.styleFrom(
        //               padding: const EdgeInsets.symmetric(
        //                   vertical: 10, horizontal: 16)),
        //           onPressed: () {
        //             context.read<UserCubit>().sendFriendRequest(userInfo.id);
        //           },
        //           child: const Text("Add now",
        //               style: TextStyle(
        //                   color: Colors.white,
        //                   fontSize: 16,
        //                   fontFamily: "Inter",
        //                   fontWeight: FontWeight.w400)))),
        // )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: searching
              ? TextField(
                  controller: idController,
                  cursorColor: Colors.white,
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: (value) {},
                  decoration: InputDecoration(
                      hintText: Strings.searchHint,
                      hintStyle: const TextStyle(color: Colors.white),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false))
              : Text(Strings.addFriend),
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  // if(userState.userSettings)
                  if (searching) {
                    String targetUserId = idController.text;
                    String? myUserId = sl<CredentialService>().turmsId;

                    if (targetUserId.isBlank) {
                      context.read<UserCubit>().resetSearchUser();
                      return;
                    }

                    if (targetUserId == myUserId) {
                      ToastUtils.showToast(
                          context: context,
                          msg: Strings.cannotAddYourselfAsFriend,
                          type: Type.warning);
                      return;
                    }

                    // await context.read<UserCubit>().resetSearchUser();
                    context
                        .read<UserCubit>()
                        .fetchUserProfile(userId: idController.text);
                    setState(() {
                      searching = false;
                    });
                    return;
                  }
                  idController.clear();
                  setState(() {
                    searching = true;
                  });
                },
                icon: const Icon(Icons.search))
          ],
          centerTitle: false,
        ),
        backgroundColor: AppColor.greyBackgroundColor,
        body: BlocConsumer<UserCubit, UserState>(
          listener: (context, state) {
            state.fetchUserProfileStatus == FetchUserProfileStatus.loading ||
                    state.sendFriendRequestStatus ==
                        SendFriendRequestStatus.loading
                ? context.loaderOverlay.show()
                : context.loaderOverlay.hide();

            if (state.fetchUserProfileStatus == FetchUserProfileStatus.fail) {
              ToastUtils.showToast(
                  context: context,
                  msg: state.errorMessage ?? Strings.unableToSearchUser,
                  type: Type.warning);
            }

            if (state.fetchUserProfileStatus ==
                    FetchUserProfileStatus.success &&
                state.userProfile == null &&
                state.searchResultUsers.isEmpty) {
              ToastUtils.showToast(
                  context: context,
                  msg: Strings.userProfileNotFound,
                  type: Type.warning);
              return;
            }

            if (state.sendFriendRequestStatus == SendFriendRequestStatus.fail) {
              ToastUtils.showToast(
                context: context,
                msg: state.errorMessage ?? Strings.unableToSendFriendRequest,
                type: Type.warning,
              );
              return;
            }

            if (state.sendFriendRequestStatus ==
                SendFriendRequestStatus.success) {
              ToastUtils.showToast(
                context: context,
                msg: Strings.friendRequestSentSuccessfully,
                type: Type.success,
              );
              context.read<UserCubit>().resetSearchUser();
              return;
            }
          },
          builder: (context, state) {
            if (state.fetchUserProfileStatus ==
                    FetchUserProfileStatus.success &&
                (state.userProfile != null ||
                    state.searchResultUsers.isNotEmpty)) {
              if (state.userProfile != null) {
                return userInfoTiles(state.userProfile);
              }

              if (state.searchResultUsers.isNotEmpty) {
                return ListView.builder(
                    itemCount: state.searchResultUsers.length,
                    itemBuilder: (context, index) {
                      return userInfoTiles(state.searchResultUsers[index]);
                    });
              }
            }

            return Column(
              children: [
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
                //   child: Container(
                //     decoration: BoxDecoration(
                //         borderRadius: BorderRadius.circular(10.0),
                //         color: Colors.white),
                //     child: TextField(
                //       controller: idController,
                //       keyboardType: TextInputType.number,
                //       decoration: InputDecoration(
                //           prefixIcon: IconButton(
                //               onPressed: () => context
                //                   .read<UserCubit>()
                //                   .sendFriendRequest(
                //                       idController.text.parseInt64()),
                //               icon: const Icon(Icons.search)),
                //           border: InputBorder.none,
                //           hintText: "Please enter the other party ID"),
                //       onSubmitted: (value) => context
                //           .read<UserCubit>()
                //           .sendFriendRequest(idController.text.parseInt64()),
                //     ),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                      "${Strings.myId} ${sl<CredentialService>().turmsId!.parseInt64()}"),
                ),
                ListTile(
                  tileColor: Colors.white,
                  visualDensity: const VisualDensity(
                      vertical: VisualDensity.minimumDensity),
                  onTap: () => Navigator.of(context)
                      .pushNamed(AppPage.qrScanner.routeName),
                  leading: SvgPicture.asset(
                    "assets/icons/scan_qr_add.svg",
                    width: 30,
                    height: 30,
                  ),
                  title:  Text(Strings.scanQRCode),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Color.fromRGBO(60, 60, 67, 0.3)),
                ),
                const Divider(height: 2),
                ListTile(
                  tileColor: Colors.white,
                  visualDensity: const VisualDensity(
                      vertical: VisualDensity.minimumDensity),
                  onTap: () => Navigator.of(context)
                      .pushNamed(AppPage.myQrCode.routeName),
                  leading: SvgPicture.asset(
                    "assets/icons/my_qr_add.svg",
                    width: 30,
                    height: 30,
                  ),
                  title:  Text(Strings.myQrCode),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Color.fromRGBO(60, 60, 67, 0.3)),
                ),
                // const Padding(
                //   padding: EdgeInsets.all(8.0),
                //   child: Align(
                //     alignment: Alignment.centerLeft,
                //     child: Text(
                //       "Incoming Friend Request",
                //       textAlign: TextAlign.left,
                //     ),
                //   ),
                // ),
                // if (state.friendRequests.isNotEmpty)
                //   ListView.builder(
                //       itemCount: state.friendRequests.length,
                //       shrinkWrap: true,
                //       itemBuilder: (context, index) {
                //         return ListTile(
                //           tileColor: Colors.white,
                //           leading: const CircleAvatar(
                //             backgroundColor: Colors.blue,
                //             child: Icon(Icons.person),
                //           ),
                //           title: Text(
                //               "${state.friendRequests[index].requesterId}"),
                //           trailing: Row(
                //             mainAxisSize: MainAxisSize.min,
                //             children: [
                //               IconButton(
                //                 icon: const Icon(
                //                   Icons.done,
                //                   color: Colors.green,
                //                 ),
                //                 onPressed: () => context
                //                     .read<UserCubit>()
                //                     .respondFriendRequest(
                //                         state.friendRequests[index].id.toInt(),
                //                         ResponseAction.ACCEPT),
                //               ),
                //               IconButton(
                //                 icon: const Icon(
                //                   Icons.cancel,
                //                   color: Colors.red,
                //                 ),
                //                 onPressed: () => context
                //                     .read<UserCubit>()
                //                     .respondFriendRequest(
                //                         state.friendRequests[index].id.toInt(),
                //                         ResponseAction.DECLINE),
                //               ),
                //             ],
                //           ),
                //         );
                //       })
              ],
            );
          },
        ),
      ),
    );
  }
}
