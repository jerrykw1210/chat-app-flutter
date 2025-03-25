part of 'group_permission_cubit.dart';

class GroupPermissionState extends Equatable {
  const GroupPermissionState({
    this.disableScreenshot = false,
  });

  final bool disableScreenshot;

  GroupPermissionState copyWith({
    bool? disableScreenshot,
  }) =>
      GroupPermissionState(
        disableScreenshot: disableScreenshot ?? this.disableScreenshot,
      );

  @override
  List<Object?> get props => [
        disableScreenshot,
      ];
}
