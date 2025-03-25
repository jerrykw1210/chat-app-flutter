import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/friend/cubit/user_cubit.dart';
import 'package:protech_mobile_chat_stream/module/webview/cubit/toggle_webview_cubit.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/service/database_helper.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/toast_utils.dart';
import 'package:protech_mobile_chat_stream/widgets/chat_avatar.dart';
import 'package:turms_client_dart/turms_client.dart';

class SearchFriendResult extends StatefulWidget {
  const SearchFriendResult({
    super.key,
    required this.userInfo,
    required this.friendMethod,
  });
  final UserInfo userInfo;
  final String friendMethod;

  @override
  State<SearchFriendResult> createState() => _SearchFriendResultState();
}

class _SearchFriendResultState extends State<SearchFriendResult> {
  @override
  void initState() {
    context.read<UserCubit>().resetSearchUser();
    context.read<UserCubit>().getUserSettings(targetUserId: widget.userInfo.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: BlocListener<UserCubit, UserState>(
        listener: (context, state) {
          state.sendFriendRequestStatus == SendFriendRequestStatus.loading
              ? context.loaderOverlay.show()
              : context.loaderOverlay.hide();

          if (state.sendFriendRequestStatus == SendFriendRequestStatus.fail) {
            ToastUtils.showToast(
              context: context,
              msg: state.errorMessage ?? "unable to send friend request",
              type: Type.warning,
            );
            return;
          }

          // if (state.sendFriendRequestStatus ==
          //     SendFriendRequestStatus.success) {
          //   ToastUtils.showToast(
          //     context: context,
          //     msg: "Friend request sent successfully",
          //     type: Type.success,
          //   );
          //   context.read<UserCubit>().resetSearchUser();
          //   Navigator.pushNamedAndRemoveUntil(
          //       context, AppPage.navBar.routeName, (_) => false,
          //       arguments: 1);
          //   return;
          // }
        },
        child: Scaffold(
          appBar: AppBar(
              leading: IconButton(
                  onPressed: () {
                    context.read<ToggleWebviewCubit>().setCurrentIndex(0);
                    Navigator.popUntil(
                        context, ModalRoute.withName(AppPage.navBar.routeName));
                  },
                  icon: const Icon(Icons.arrow_back_ios)),
              title:  Text(Strings.addFriend)),
          body: SafeArea(
            child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ListTile(
                    tileColor: Colors.white,
                    leading: ChatAvatar(
                        errorWidget: CircleAvatar(
                          radius: 33,
                          backgroundColor: Theme.of(context).primaryColorLight,
                          child: ClipOval(
                            child: Text(widget.userInfo.name[0],
                                style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                        targetId: widget.userInfo.id.toString(),
                        radius: 20),
                    horizontalTitleGap: 10,
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.userInfo.name,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.w500)),
                        Text("Protech ID: ${widget.userInfo.id}",
                            style: const TextStyle(
                                color: Color.fromRGBO(126, 126, 130, 1),
                                fontSize: 13,
                                fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  BlocBuilder<UserCubit, UserState>(
                    builder: (context, state) {
                      return Column(mainAxisSize: MainAxisSize.min, children: [
                        if (state.getUserSettingsStatus ==
                            GetUserSettingsStatus.success)
                          if (widget.friendMethod == "id" &&
                              state.userSettings['ADDING_USING_ID']
                                      ?.int32Value ==
                                  1)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: SizedBox(
                                  width: MediaQuery.sizeOf(context).width,
                                  child: BlocListener<UserCubit, UserState>(
                                    listenWhen: (previous, current) =>
                                        previous.getUserSettingsStatus !=
                                            current.getUserSettingsStatus ||
                                        previous.createRelationshipStatus !=
                                            current.createRelationshipStatus ||
                                        previous.createRelationshipStatus !=
                                            current.createRelationshipStatus ||
                                        previous.sendFriendRequestStatus !=
                                            current.sendFriendRequestStatus,
                                    listener: (context, userState) {
                                      // if (userState.getUserSettingsStatus ==
                                      //         GetUserSettingsStatus.success &&
                                      //     userState
                                      //             .userSettings[
                                      //                 'ADD_I_NEED_VERIFICATION']
                                      //             ?.int32Value ==
                                      //         1) {
                                      //   context
                                      //       .read<UserCubit>()
                                      //       .sendFriendRequest(widget.userInfo.id);
                                      // } else if (userState.getUserSettingsStatus ==
                                      //     GetUserSettingsStatus.success) {
                                      //   context
                                      //       .read<UserCubit>()
                                      //       .addFriendWithoutRequest(
                                      //           widget.userInfo.id);
                                      // }

                                      // context
                                      //     .read<UserCubit>()
                                      //     .sendFriendRequest(widget.userInfo.id);
                                      if (userState.createRelationshipStatus ==
                                          CreateRelationshipStatus.success) {
                                        ToastUtils.showToast(
                                          context: context,
                                          msg: Strings.friendAddedSuccessfully,
                                          type: Type.success,
                                        );
                                        context
                                            .read<UserCubit>()
                                            .resetAllUserStatus();
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                          builder: (context) {
                                            return AddFriendSuccess(
                                              userInfo: widget.userInfo,
                                            );
                                          },
                                        ));
                                        // context
                                        //     .read<ToggleWebviewCubit>()
                                        //     .setCurrentIndex(1);
                                        // Navigator.pushNamedAndRemoveUntil(context,
                                        //     AppPage.navBar.routeName, (_) => false,
                                        //     arguments: 1);
                                      }
                                      if (userState.sendFriendRequestStatus ==
                                          SendFriendRequestStatus.success) {
                                        ToastUtils.showToast(
                                          context: context,
                                          msg: Strings
                                              .friendRequestSentSuccessfully,
                                          type: Type.success,
                                        );
                                        context
                                            .read<UserCubit>()
                                            .resetAllUserStatus();

                                        // Navigator.pop(context);
                                        context
                                            .read<ToggleWebviewCubit>()
                                            .setCurrentIndex(0);
                                        Navigator.popUntil(
                                            context,
                                            ModalRoute.withName(
                                                AppPage.navBar.routeName));
                                        // context
                                        //     .read<ToggleWebviewCubit>()
                                        //     .setCurrentIndex(1);
                                        // Navigator.pushNamedAndRemoveUntil(context,
                                        //     AppPage.navBar.routeName, (_) => false,
                                        //     arguments: 1);
                                      }
                                    },
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 16)),
                                        onPressed: () {
                                          if (state
                                                  .userSettings[
                                                      'ADD_ME_NEED_VERIFICATION']
                                                  ?.int32Value ==
                                              1) {
                                            context
                                                .read<UserCubit>()
                                                .sendFriendRequest(
                                                    widget.userInfo.id);
                                          } else {
                                            context
                                                .read<UserCubit>()
                                                .addFriendWithoutRequest(
                                                    widget.userInfo.id);
                                          }
                                        },
                                        child: Text(Strings.addFriend,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontFamily: "Inter",
                                                fontWeight: FontWeight.w400))),
                                  )),
                            ),
                        if (state.getUserSettingsStatus ==
                                GetUserSettingsStatus.success &&
                            widget.friendMethod == "qr" &&
                            state.userSettings['ADDING_USING_MY_QR_CODE']
                                    ?.int32Value ==
                                1)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24.0),
                            child: SizedBox(
                                width: MediaQuery.sizeOf(context).width,
                                child: BlocListener<UserCubit, UserState>(
                                  listenWhen: (previous, current) =>
                                      previous.getUserSettingsStatus !=
                                          current.getUserSettingsStatus ||
                                      previous.createRelationshipStatus !=
                                          current.createRelationshipStatus ||
                                      previous.createRelationshipStatus !=
                                          current.createRelationshipStatus ||
                                      previous.sendFriendRequestStatus !=
                                          current.sendFriendRequestStatus,
                                  listener: (context, userState) {
                                    // if (userState.getUserSettingsStatus ==
                                    //         GetUserSettingsStatus.success &&
                                    //     userState
                                    //             .userSettings[
                                    //                 'ADD_I_NEED_VERIFICATION']
                                    //             ?.int32Value ==
                                    //         1) {
                                    //   context
                                    //       .read<UserCubit>()
                                    //       .sendFriendRequest(widget.userInfo.id);
                                    // } else if (userState.getUserSettingsStatus ==
                                    //     GetUserSettingsStatus.success) {
                                    //   context
                                    //       .read<UserCubit>()
                                    //       .addFriendWithoutRequest(
                                    //           widget.userInfo.id);
                                    // }

                                    // context
                                    //     .read<UserCubit>()
                                    //     .sendFriendRequest(widget.userInfo.id);
                                    if (userState.createRelationshipStatus ==
                                        CreateRelationshipStatus.success) {
                                      ToastUtils.showToast(
                                        context: context,
                                        msg: Strings.friendAddedSuccessfully,
                                        type: Type.success,
                                      );
                                      context
                                          .read<UserCubit>()
                                          .resetAllUserStatus();
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) {
                                          return AddFriendSuccess(
                                            userInfo: widget.userInfo,
                                          );
                                        },
                                      ));
                                      // context
                                      //     .read<ToggleWebviewCubit>()
                                      //     .setCurrentIndex(1);
                                      // Navigator.pushNamedAndRemoveUntil(context,
                                      //     AppPage.navBar.routeName, (_) => false,
                                      //     arguments: 1);
                                    }
                                    if (userState.sendFriendRequestStatus ==
                                        SendFriendRequestStatus.success) {
                                      ToastUtils.showToast(
                                        context: context,
                                        msg: Strings
                                            .friendRequestSentSuccessfully,
                                        type: Type.success,
                                      );
                                      context
                                          .read<UserCubit>()
                                          .resetAllUserStatus();

                                      // Navigator.pop(context);
                                      context
                                          .read<ToggleWebviewCubit>()
                                          .setCurrentIndex(0);
                                      Navigator.popUntil(
                                          context,
                                          ModalRoute.withName(
                                              AppPage.navBar.routeName));
                                      // context
                                      //     .read<ToggleWebviewCubit>()
                                      //     .setCurrentIndex(1);
                                      // Navigator.pushNamedAndRemoveUntil(context,
                                      //     AppPage.navBar.routeName, (_) => false,
                                      //     arguments: 1);
                                    }
                                  },
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 16)),
                                      onPressed: () {
                                        if (state
                                                .userSettings[
                                                    'ADD_ME_NEED_VERIFICATION']
                                                ?.int32Value ==
                                            1) {
                                          context
                                              .read<UserCubit>()
                                              .sendFriendRequest(
                                                  widget.userInfo.id);
                                        } else {
                                          context
                                              .read<UserCubit>()
                                              .addFriendWithoutRequest(
                                                  widget.userInfo.id);
                                        }

                                        // context.read<UserCubit>().getUserSettings();
                                      },
                                      child: Text(Strings.addFriend,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontFamily: "Inter",
                                              fontWeight: FontWeight.w400))),
                                )),
                          ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: SizedBox(
                              width: MediaQuery.sizeOf(context).width,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 16)),
                                  onPressed: () {
                                    context
                                        .read<ToggleWebviewCubit>()
                                        .setCurrentIndex(0);
                                    Navigator.popUntil(
                                        context,
                                        ModalRoute.withName(
                                            AppPage.navBar.routeName));
                                  },
                                  child: Text(Strings.cancel,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontFamily: "Inter",
                                          fontWeight: FontWeight.w400)))),
                        ),
                        const SizedBox(height: 12),
                      ]);
                    },
                  )
                ]),
          ),
        ),
      ),
    );
  }
}

class AddFriendSuccess extends StatefulWidget {
  const AddFriendSuccess({
    super.key,
    required this.userInfo,
  });
  final UserInfo userInfo;

  @override
  State<AddFriendSuccess> createState() => _AddFriendSuccessState();
}

class _AddFriendSuccessState extends State<AddFriendSuccess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                context.read<ToggleWebviewCubit>().setCurrentIndex(0);
                Navigator.popUntil(
                    context, ModalRoute.withName(AppPage.navBar.routeName));
              },
              icon: const Icon(Icons.arrow_back_ios)),
          title: Text(Strings.addFriend)),
      body: SafeArea(
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ListTile(
                tileColor: Colors.white,
                leading: ChatAvatar(
                    errorWidget: CircleAvatar(
                      radius: 33,
                      backgroundColor: Theme.of(context).primaryColorLight,
                      child: ClipOval(
                        child: Text(widget.userInfo.name[0],
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                    targetId: widget.userInfo.id.toString(),
                    radius: 20),
                horizontalTitleGap: 10,
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.userInfo.name,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w500)),
                    Text("Prochat ID: ${widget.userInfo.id}",
                        style: const TextStyle(
                            color: Color.fromRGBO(126, 126, 130, 1),
                            fontSize: 13,
                            fontWeight: FontWeight.w400)),
                  ],
                ),
              ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16)),
                          onPressed: () async {
                            String friendId = widget.userInfo.id.toString();
                            String myUserId = sl<CredentialService>().turmsId!;
                            UserInfo friendInfo = widget.userInfo;
                            await sl<DatabaseHelper>().upsertConversation(
                                friendId: friendId,
                                members: [friendId, myUserId],
                                isGroup: false,
                                targetId: friendId,
                                title: friendInfo.name ?? friendId,
                                ownerId: myUserId);

                            context
                                .read<ToggleWebviewCubit>()
                                .setCurrentIndex(0);
                            Navigator.popUntil(context,
                                ModalRoute.withName(AppPage.navBar.routeName));
                            // Navigator.of(context).push(
                            //   MaterialPageRoute(
                            //       builder: (context) => MessageScreen(
                            //           conversation: conversation,
                            //           isGroup: false)),
                            // );
                          },
                          child: Text(Strings.startChatting,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.w400)))),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16)),
                          onPressed: () {
                            context
                                .read<ToggleWebviewCubit>()
                                .setCurrentIndex(0);
                            Navigator.popUntil(context,
                                ModalRoute.withName(AppPage.navBar.routeName));
                          },
                          child: Text(Strings.cancel,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.w400)))),
                ),
                const SizedBox(height: 12),
              ])
            ]),
      ),
    );
  }
}
