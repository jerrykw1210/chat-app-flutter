import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:protech_mobile_chat_stream/constants/network_constants.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/profile/cubit/profile_cubit.dart';
import 'package:protech_mobile_chat_stream/module/profile/model/user_profile.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/utils/colors.dart';
import 'package:protech_mobile_chat_stream/utils/helper.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/toast_utils.dart';
import 'package:protech_mobile_chat_stream/widgets/edit_profile_dialog.dart';
import 'package:http/http.dart' as http;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController signatureController = TextEditingController();
  TextEditingController statusMessageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? profileImagePath;

  @override
  void initState() {
    context.read<ProfileCubit>().getProfile();
    context.read<ProfileCubit>().reset();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    signatureController.dispose();
    statusMessageController.dispose();
  }

  void getProfileImage(UserProfile userInfo) async {
    final directory = Helper.directory;

    final profileImgFile = File(
        "${directory?.path}/${sl<CredentialService>().turmsId}_${userInfo.profileUrl}");

    bool fileExist = await profileImgFile.exists();

    if (!fileExist) {
      final downloadProfileImgFile = await downloadFile(userInfo.profileUrl);
      setState(() {
        profileImagePath = downloadProfileImgFile.path;
      });
    } else {
      setState(() {
        profileImagePath = profileImgFile.path;
      });
    }
  }

// Function to download the file
  Future<File> downloadFile(String fileName) async {
    // final response = await http.get(Uri.parse(url));
    // final directory = await getTemporaryDirectory();
    // final file = File('${directory.path}/$fileName');

    // // Write the downloaded bytes to a file
    // return file.writeAsBytes(response.bodyBytes);

    String? jwtToken = sl<CredentialService>().jwtToken;
    String? turmsId = sl<CredentialService>().turmsId;
    Map<String, String> headers = {"Authorization": "Bearer $jwtToken"};
    try {
      final res = await http.get(
          Uri.parse("${NetworkConstants.getProfileImgUrl}$turmsId"),
          headers: headers);
      if (res.statusCode == 200) {
        log("status ${res.statusCode}");
        final directory = Helper.directory;
        final file = File(
            '${directory?.path}/${sl<CredentialService>().turmsId}_$fileName');

        // Write the downloaded bytes to a file
        return file.writeAsBytes(res.bodyBytes);
      } else {
        throw Exception(
            "Failed to get profile image. Status code: ${res.statusCode}");
      }
    } on Exception catch (e) {
      throw Exception("Failed to get profile image. Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            Strings.myProfile,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white),
          ),
        ),
        backgroundColor: AppColor.conversationBackgroundColor,
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            state.editProfileStatus == EditProfileStatus.loading ||
                    state.uploadProfileImageStatus ==
                        UploadProfileImageStatus.loading ||
                    state.updateGenderStatus == UpdateGenderStatus.loading ||
                    state.updateNameStatus == UpdateNameStatus.loading ||
                    state.updateSignatureStatus == UpdateSignatureStatus.loading
                ? context.loaderOverlay.show()
                : context.loaderOverlay.hide();

            // state.editProfileStatus == EditProfileStatus.loading
            //     ? context.loaderOverlay.show()
            //     : context.loaderOverlay.hide();

            // state.uploadProfileImageStatus == UploadProfileImageStatus.loading
            //     ? context.loaderOverlay.show()
            //     : context.loaderOverlay.hide();

            // state.updateGenderStatus == UpdateGenderStatus.loading
            //     ? context.loaderOverlay.show()
            //     : context.loaderOverlay.hide();

            // state.updateNameStatus == UpdateNameStatus.loading
            //     ? context.loaderOverlay.show()
            //     : context.loaderOverlay.hide();

            if (state.editProfileStatus == EditProfileStatus.fail) {
              ToastUtils.showToast(
                  context: context,
                  msg: Strings.failToUpdateUserInfo,
                  type: Type.warning);
              context.read<ProfileCubit>().reset();
              return;
            }

            if (state.editProfileStatus == EditProfileStatus.success) {
              ToastUtils.showToast(
                  context: context,
                  msg: Strings.successfullyUpdateUserInfo,
                  type: Type.success);
              context.read<ProfileCubit>().getLoggedInUser();
              context.read<ProfileCubit>().reset();
              return;
            }

            if (state.uploadProfileImageStatus ==
                UploadProfileImageStatus.fail) {
              ToastUtils.showToast(
                  context: context,
                  msg: state.errorMessage ?? Strings.unableToChangeProfileImage,
                  type: Type.warning);
              context.read<ProfileCubit>().reset();
              return;
            }

            if (state.uploadProfileImageStatus ==
                UploadProfileImageStatus.success) {
              context.read<ProfileCubit>().getProfile();
              ToastUtils.showToast(
                  context: context,
                  msg: Strings.changeProfileImageSuccessfully,
                  type: Type.success);
              context.read<ProfileCubit>().reset();
              return;
            }

            if (state.updateGenderStatus == UpdateGenderStatus.fail) {
              ToastUtils.showToast(
                  context: context,
                  msg: state.errorMessage ?? Strings.unableToChangeGender,
                  type: Type.warning);
              context.read<ProfileCubit>().reset();
              return;
            }

            if (state.updateGenderStatus == UpdateGenderStatus.success) {
              ToastUtils.showToast(
                  context: context,
                  msg: Strings.changeGenderSuccessfully,
                  type: Type.success);
              context.read<ProfileCubit>().reset();
              return;
            }

            if (state.updateNameStatus == UpdateNameStatus.fail) {
              ToastUtils.showToast(
                  context: context,
                  msg: state.errorMessage ?? Strings.unableToChangeName,
                  type: Type.warning);
              context.read<ProfileCubit>().reset();
              return;
            }

            if (state.updateNameStatus == UpdateNameStatus.success) {
              ToastUtils.showToast(
                  context: context,
                  msg: Strings.changeNameSuccessfully,
                  type: Type.success);
              context.read<ProfileCubit>().reset();
              return;
            }

            if (state.updateSignatureStatus == UpdateSignatureStatus.fail) {
              ToastUtils.showToast(
                  context: context,
                  msg: state.errorMessage ?? Strings.unableToChangeSignature,
                  type: Type.warning);
              context.read<ProfileCubit>().reset();
              return;
            }

            if (state.updateSignatureStatus == UpdateSignatureStatus.success) {
              ToastUtils.showToast(
                  context: context,
                  msg: Strings.changeSignatureSuccessfully,
                  type: Type.success);
              context.read<ProfileCubit>().reset();
              return;
            }

            if (state.userProfile != null) {
              if (state.userProfile != null) {
                if (state.userProfile!.profileUrl.toString().isNotEmpty ||
                    state.userProfile!.profileUrl.toString() != "null") {
                  getProfileImage(state.userProfile!);
                }
              }
            }
          },
          builder: (context, state) {
            UserProfile? user = state.userProfile;

            return ListView(shrinkWrap: true, children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                margin: const EdgeInsets.only(bottom: 10),
                color: Colors.white,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 20,
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5)
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () {
                      _picker
                          .pickImage(source: ImageSource.gallery)
                          .then((value) {
                        if (value != null && user != null) {
                          context
                              .read<ProfileCubit>()
                              .uploadProfileImage(value, name: user.name);
                        }
                      });
                    },
                    child: CircleAvatar(
                      maxRadius: 48,
                      backgroundColor: Colors.white,
                      child: Stack(children: [
                        ClipOval(
                          child: profileImagePath == null
                              ? Image.asset(
                                  'assets/default-img/default-user.png',
                                  fit: BoxFit.cover,
                                  width: 84,
                                  height: 84,
                                )
                              : Image.file(
                                  File(profileImagePath!),
                                  fit: BoxFit.cover,
                                  width: 84,
                                  height: 84,
                                ),
                        ),
                        Positioned(
                            bottom: 0,
                            right: 0,
                            child: SvgPicture.asset(
                                "assets/Buttons/upload-04.svg"))
                      ]),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  nameController.value =
                      TextEditingValue(text: user?.name ?? "");
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.only(
                            left: 30,
                            right: 30,
                            top: 10,
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom + 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(Strings.enterYourName,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontWeight: FontWeight.bold)),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                    flex: 2,
                                    child: TextField(
                                      controller: nameController,
                                      autofocus: true,
                                    )),
                                Flexible(
                                  flex: 1,
                                  child: IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.emoji_emotions)),
                                )
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(Strings.cancel,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium)),
                                TextButton(
                                    onPressed: () {
                                      String updatedName = nameController.text;

                                      if (updatedName.trim().isEmpty) {
                                        ToastUtils.showToast(
                                            context: context,
                                            msg: Strings.nameCannotBeEmpty,
                                            type: Type.warning);
                                        return;
                                      }

                                      context
                                          .read<ProfileCubit>()
                                          .updateName(name: updatedName);
                                      Navigator.pop(context);
                                    },
                                    child: Text(Strings.save,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColorLight))),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: ListTile(
                  tileColor: Colors.white,
                  title: Padding(
                    padding:
                        const EdgeInsets.only(top: 10, bottom: 10.0, left: 10),
                    child: Text(Strings.name,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Row(
                      children: [
                        Text(state.userProfile?.name.toString() ?? "",
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(
                          width: 5,
                        ),
                        SvgPicture.asset("assets/Buttons/edit-04.svg")
                      ],
                    ),
                  ),
                ),
              ),
              // ListTile(
              //   tileColor: Colors.white,
              //   title: Text("ID",
              //       style: Theme.of(context).textTheme.bodyMedium),
              //   trailing: Row(
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       Text(state.user == null ? "ABC19201" : state.user!.id,
              //           style: Theme.of(context).textTheme.bodyMedium),
              //       const Icon(Icons.arrow_forward_ios)
              //     ],
              //   ),
              // ),
              // GestureDetector(
              //   onTap: () => Navigator.of(context)
              //       .pushNamed(AppPage.myQrCode.routeName),
              //   child: ListTile(
              //     tileColor: Colors.white,
              //     title: Text("My QR Code",
              //         style: Theme.of(context).textTheme.bodyMedium),
              //     trailing: const Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Icon(Icons.qr_code),
              //         Icon(Icons.arrow_forward_ios)
              //       ],
              //     ),
              //   ),
              // ),
              ListTile(
                  tileColor: Colors.white,
                  title: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(Strings.gender,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  trailing: const GenderDialog()),
              GestureDetector(
                onTap: () {
                  signatureController.value =
                      TextEditingValue(text: user?.statusMessage ?? "");
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.only(
                            left: 30,
                            right: 30,
                            top: 10,
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom + 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(Strings.enterYourSignature,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            TextField(
                              controller: signatureController,
                              autofocus: true,
                              minLines: 3,
                              maxLines: 5,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(Strings.cancel,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium)),
                                TextButton(
                                    onPressed: () {
                                      String updatedSignature =
                                          signatureController.text;

                                      context
                                          .read<ProfileCubit>()
                                          .updateSignature(
                                              signature: updatedSignature);
                                      Navigator.pop(context);
                                    },
                                    child: Text(Strings.save,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColorLight))),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: ListTile(
                  tileColor: Colors.white,
                  title: Padding(
                    padding:
                        const EdgeInsets.only(top: 10, bottom: 10.0, left: 10),
                    child: Text(Strings.signature,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Row(
                      children: [
                        Text(state.userProfile?.statusMessage.toString() ?? "",
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(
                          width: 5,
                        ),
                        SvgPicture.asset("assets/Buttons/edit-04.svg")
                      ],
                    ),
                  ),
                ),
              ),
              ListTile(
                tileColor: Colors.white,
                onTap: () => showDialog(
                  context: context,
                  builder: (dialogContext) => const VerifyEmailDialog(),
                ),
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0, left: 10.0),
                  child: Text(Strings.email,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.userProfile?.email.toString() ?? "",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColor.chatSenderBubbleColor,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SvgPicture.asset("assets/Buttons/edit-04.svg")
                    ],
                  ),
                ),
              ),
              ListTile(
                tileColor: Colors.white,
                onTap: () => showDialog(
                  context: context,
                  builder: (dialogContext) => const VerifyPhoneDialog(),
                ),
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0, left: 10.0),
                  child: Text(Strings.phone,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(left: 10.0, bottom: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.userProfile?.phone.toString() ?? "",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColor.chatSenderBubbleColor,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SvgPicture.asset("assets/Buttons/edit-04.svg")
                    ],
                  ),
                ),
              ),
            ]);
          },
        ),
      ),
    );
  }
}

class GenderDialog extends StatelessWidget {
  const GenderDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return DropdownButtonHideUnderline(
          child: DropdownButton(
              value: state.userProfile?.gender?.toUpperCase() ?? state.gender,
              alignment: Alignment.centerRight,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: [
                DropdownMenuItem(
                  value: "male".toUpperCase(),
                  child: Text(Strings.male,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                DropdownMenuItem(
                  value: "female".toUpperCase(),
                  child: Text(Strings.female,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                DropdownMenuItem(
                  value: "rather_not_say".toUpperCase(),
                  child: Text(Strings.preferNotToSay,
                      style: Theme.of(context).textTheme.bodyMedium),
                )
              ],
              onChanged: (value) {
                context.read<ProfileCubit>().changeGender(value.toString());
              }),
        );
      },
    );
  }
}
