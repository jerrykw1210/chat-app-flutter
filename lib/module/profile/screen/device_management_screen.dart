import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/profile/cubit/profile_cubit.dart';
import 'package:protech_mobile_chat_stream/utils/colors.dart';
import 'package:protech_mobile_chat_stream/utils/device_info.dart';
import 'package:protech_mobile_chat_stream/utils/helper.dart';

class DeviceManagementScreen extends StatefulWidget {
  const DeviceManagementScreen({super.key});

  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  String? fcmToken;
  String censorString(String input, int censorLength) {
    if (input.length <= censorLength) {
      // If the string is shorter than or equal to the censor length, return all asterisks
      return '*' * input.length;
    }

    // Generate the censored part with asterisks
    String censoredPart = '*' * censorLength;

    // Keep the remaining part of the string
    String visiblePart = input.substring(censorLength);

    // Combine the censored part with the visible part
    return censoredPart + visiblePart;
  }

  @override
  initState() {
    super.initState();
    context.read<ProfileCubit>().getDevices();
    // Future.delayed(Duration.zero, () async {
    //   fcmToken = Platform.isIOS
    //       ? await FirebaseMessaging.instance.getAPNSToken() ??
    //           Helper.generateUUID()
    //       : await FirebaseMessaging.instance.getToken() ??
    //           Helper.generateUUID();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.deviceManagement),
        centerTitle: true,
      ),
      backgroundColor: AppColor.greyBackgroundColor3,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
              child: BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  if (state.getDevicesStatus == GetDevicesStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.getDevicesStatus == GetDevicesStatus.fail) {
                    return Center(child: Text(Strings.somethingWentWrong));
                  }
                  if (state.getDevicesStatus == GetDevicesStatus.empty) {
                    return Center(child: Text(Strings.noDeviceFound));
                  }
                  if (state.getDevicesStatus == GetDevicesStatus.success) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(Strings.currentDevice,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.blue)),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DeviceInfoClass.getDeviceModel()),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width * 0.8,
                                  child: Text(
                                    censorString(fcmToken.toString(), 10),
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                // IconButton(
                                //     onPressed: () {
                                //       showDialog(
                                //         context: context,
                                //         builder: (context) => const RemarkDialog(),
                                //       );
                                //     },
                                //     icon: const Icon(Icons.edit))
                              ],
                            ),
                            // Text(
                            //     "${Strings.lastOnline}: ${DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(state.linkedDevices[0].lastOnline ?? 0))}")
                          ],
                        ),
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                if (state.getDevicesStatus == GetDevicesStatus.success) {
                  return ListView.separated(
                    itemCount: state.linkedDevices.length,
                    padding: const EdgeInsets.only(top: 8.0),
                    shrinkWrap: true,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      return Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(state.linkedDevices[index].model),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width * 0.8,
                                  child: Text(
                                    censorString(
                                        state.linkedDevices[index].token, 10),
                                    maxLines: 1,
                                  ),
                                ),
                                // IconButton(
                                //     onPressed: () {
                                //       showDialog(
                                //         context: context,
                                //         builder: (context) => const RemarkDialog(),
                                //       );
                                //     },
                                //     icon: const Icon(Icons.edit))
                              ],
                            ),
                            Text(DateFormat('dd/MM/yyyy').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    state.linkedDevices[index].lastOnline ??
                                        0)))
                          ],
                        ),
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            )
          ],
        ),
      ),
    );
  }
}

class RemarkDialog extends StatelessWidget {
  const RemarkDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Remark"),
      content: TextFormField(
        decoration: const InputDecoration(
          hintText: "Enter remark",
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        ),
      ),
      actions: [TextButton(onPressed: () {}, child: const Text("Ok"))],
    );
  }
}
