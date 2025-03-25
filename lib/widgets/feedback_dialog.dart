import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/feedback/cubit/feedback_cubit.dart';
import 'package:protech_mobile_chat_stream/module/profile/cubit/profile_cubit.dart';
import 'package:protech_mobile_chat_stream/utils/colors.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:protech_mobile_chat_stream/utils/toast_utils.dart';

class FeedbackDialog extends StatelessWidget {
  FeedbackDialog({super.key});
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _feedbackContentController =
      TextEditingController();

  Widget feedbackImgItem(BuildContext context, {required XFile image}) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0, bottom: 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
                width: 80,
                height: 80,
                child: Image.file(
                  File(image.path),
                  fit: BoxFit.cover,
                )),
            Positioned(
              top: -5,
              right: -5,
              child: GestureDetector(
                onTap: () {
                  context.read<ProfileCubit>().removeFeedbackScreenshot(image);
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: const Icon(
                    Icons.horizontal_rule,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _submitFeedback(BuildContext context) {
    ProfileCubit profileCubit = context.read<ProfileCubit>();
    FeedbackCubit feedbackCubit = context.read<FeedbackCubit>();
    List<XFile> imageList = profileCubit.state.imageList;
    String feedbackType = profileCubit.state.feedbackType;
    String content = _feedbackContentController.text;

    if (content.isBlank) {
      ToastUtils.showToast(
          context: context, msg: "请输入反馈内容", type: Type.warning);
      return;
    }

    feedbackCubit.submitFeedback(
        content: content, category: feedbackType, attachment: imageList);

    // Navigator.pop(context);
  }

  _uploadAttachment(BuildContext context) {
    ProfileCubit profileCubit = context.read<ProfileCubit>();
    List<XFile> imageList = profileCubit.state.imageList;
    List<Future> uploadFuture = [];

    if (imageList.isNotEmpty) {}
    // context.read<FileCubit>().upload();
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Dialog(
        insetPadding: const EdgeInsets.all(15.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: BlocListener<FeedbackCubit, FeedbackState>(
          listener: (context, state) {
            state.submitFeedbackStatus == SubmitFeedbackStatus.loading
                ? context.loaderOverlay.show()
                : context.loaderOverlay.hide();

            if (state.submitFeedbackStatus == SubmitFeedbackStatus.success) {
              ToastUtils.showToast(
                  context: context, msg: Strings.feedbackSubmittedSuccess, type: Type.success);
              Navigator.pop(context);
              return;
            }

            if (state.submitFeedbackStatus == SubmitFeedbackStatus.fail) {
              ToastUtils.showToast(
                  context: context,
                  msg: state.errorMessage ?? Strings.feedbackSubmitFail,
                  type: Type.warning);
              return;
            }
          },
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          Strings.feedbackType,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close,
                              size: 20,
                              color: Color.fromRGBO(152, 162, 179, 1)),
                          padding: EdgeInsets.zero,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, state) {
                      return Container(
                          decoration: BoxDecoration(
                              color: AppColor.feedbackTypeColor,
                              border: Border.all(
                                  color: AppColor.feedbackTypeBorderColor),
                              borderRadius: BorderRadius.circular(12.0)),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children:
                                    Strings.feedbackList.map((feedbackType) {
                                  log("feedback ${'suggestion'.tr()} $feedbackType");
                                  return Expanded(
                                    flex: 3,
                                    child: FilledButton(
                                        onPressed: () {
                                          context
                                              .read<ProfileCubit>()
                                              .selectFeedbackType(
                                                  feedbackType.toLowerCase());
                                        },
                                        style: FilledButton.styleFrom(
                                            backgroundColor:
                                                "${state.feedbackType[0].toUpperCase()}${state.feedbackType.substring(1)}"
                                                            .tr() ==
                                                        feedbackType
                                                    ? Colors.white
                                                    : Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    color: "${state.feedbackType[0].toUpperCase()}${state.feedbackType.substring(1)}"
                                                                .tr() ==
                                                            feedbackType
                                                        ? const Color.fromRGBO(
                                                            16, 24, 40, 0.1)
                                                        : Colors.transparent),
                                                borderRadius:
                                                    BorderRadius.circular(12))),
                                        child: Text(
                                          feedbackType,
                                          maxLines: 1,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      "${state.feedbackType[0].toUpperCase()}${state.feedbackType.substring(1)}"
                                                                  .tr() ==
                                                              feedbackType
                                                          ? Colors.black
                                                          : AppColor.greyText),
                                        )),
                                  );
                                }).toList()),
                          ));
                    },
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(Strings.feedbackContent,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  TextField(
                    minLines: 5,
                    maxLines: 8,
                    maxLength: 500,
                    controller: _feedbackContentController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText:
                            Strings.feedbackHintText,
                        hintStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColor.greyText)),
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Text(
                                "${Strings.feedbackScreenshots} (${context.read<ProfileCubit>().state.imageList.length}/5)",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                          ),
                          if (state.imageList.isNotEmpty)
                            Wrap(
                              children: state.imageList
                                  .map((image) =>
                                      feedbackImgItem(context, image: image))
                                  .toList(),
                            ),
                          const SizedBox(height: 10),
                          if (context
                                  .read<ProfileCubit>()
                                  .state
                                  .imageList
                                  .length <
                              5)
                            GestureDetector(
                              onTap: () async {
                                final image = await _picker.pickImage(
                                    source: ImageSource.gallery);
                                if (context.mounted) {
                                  if (image != null) {
                                    // context.read<FileCubit>().upload(file: image);

                                    context
                                        .read<ProfileCubit>()
                                        .addFeedbackScreenshot(image);
                                  }
                                }
                              },
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: const BoxDecoration(
                                    color: AppColor.greyBackgroundColor),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        child: FilledButton(
                            onPressed: () {
                              _submitFeedback(context);
                            },
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      color: AppColor.greyButtonBorderColor),
                                  borderRadius: BorderRadius.circular(8.0)),
                            ),
                            child: const Text("Submit")),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        child: FilledButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      color: AppColor.greyButtonBorderColor),
                                  borderRadius: BorderRadius.circular(8.0)),
                            ),
                            child: Text(
                              "Cancel",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.black),
                            )),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
