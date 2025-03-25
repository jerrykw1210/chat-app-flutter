part of 'chat_cubit.dart';

enum ForwardMessageStatus { initial, loading, success, failed }

enum QuerySearchStatus { initial, loading, success, failed }

enum RecallMessageStatus { initial, loading, success, recallTimeout }

enum VideoStatus { initial, loading, loadVideo, failed }

enum DownloadStatus { initial, downloading, downloaded, failed }

enum DownloadImageStatus { initial, downloading, downloaded, failed }

enum UploadAttachmentStatus { initial, uploading, uploaded, failed }

class ChatState extends Equatable {
  final bool isGroup;
  final ForwardMessageStatus forwardMessageStatus;
  final QuerySearchStatus querySearchStatus;
  final RecallMessageStatus recallMessageStatus;
  final DownloadStatus downloadStatus;
  final DownloadImageStatus downloadImageStatus;
  final VideoStatus videoStatus;
  final UploadAttachmentStatus uploadAttachmentStatus;
  final List<db.Message> selectedMessages;
  final List<dynamic> selectedUsers;
  final List<db.Message> pinnedMessages;
  final List<db.Message> searchedMessages;
  final String forwardError;
  final String recallErrorMessage;
  final bool expandText;
  final List<String> expandTextId;
  final List gifUrl;
  final bool sendNamecard;
  final Int64? sendNamecardToId;
  List<String> videoThumbnail;
  final List<AttachmentModel> attachmentList;
  final List<Map<String, dynamic>>? thumbnailList;
  final AttachmentModel? fileToDownload;
  final XFile? fileToUpload;

  ChatState({
    this.isGroup = false,
    this.forwardMessageStatus = ForwardMessageStatus.initial,
    this.querySearchStatus = QuerySearchStatus.initial,
    this.recallMessageStatus = RecallMessageStatus.initial,
    this.downloadStatus = DownloadStatus.initial,
    this.downloadImageStatus = DownloadImageStatus.initial,
    this.videoStatus = VideoStatus.initial,
    this.uploadAttachmentStatus = UploadAttachmentStatus.initial,
    this.selectedMessages = const [],
    this.selectedUsers = const [],
    this.pinnedMessages = const [],
    this.searchedMessages = const [],
    this.forwardError = "",
    this.recallErrorMessage = "",
    this.expandText = false,
    this.expandTextId = const [],
    this.gifUrl = const [],
    this.sendNamecard = false,
    this.sendNamecardToId,
    this.videoThumbnail = const [],
    this.attachmentList = const [],
    this.thumbnailList,
    this.fileToDownload,
    this.fileToUpload,
  });

  ChatState copyWith({
    bool? isGroup,
    ForwardMessageStatus? forwardMessageStatus,
    QuerySearchStatus? querySearchStatus,
    RecallMessageStatus? recallMessageStatus,
    DownloadStatus? downloadStatus,
    DownloadImageStatus? downloadImageStatus,
    VideoStatus? videoStatus,
    UploadAttachmentStatus? uploadAttachmentStatus,
    List<db.Message>? selectedMessages,
    List<dynamic>? selectedUsers,
    List<db.Message>? pinnedMessages,
    List<db.Message>? searchedMessages,
    String? forwardError,
    String? recallErrorMessage,
    bool? expandText,
    List<String>? expandTextId,
    List? gifUrl,
    bool? sendNamecard,
    Int64? sendNamecardToId,
    List<String>? videoThumbnail,
    List<AttachmentModel>? attachmentList,
    List<Map<String, dynamic>>? thumbnailList,
    AttachmentModel? fileToDownload,
    XFile? fileToUpload,
  }) {
    return ChatState(
      isGroup: isGroup ?? this.isGroup,
      forwardMessageStatus: forwardMessageStatus ?? this.forwardMessageStatus,
      querySearchStatus: querySearchStatus ?? this.querySearchStatus,
      recallMessageStatus: recallMessageStatus ?? this.recallMessageStatus,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      downloadImageStatus: downloadImageStatus ?? this.downloadImageStatus,
      videoStatus: videoStatus ?? this.videoStatus,
      uploadAttachmentStatus:
          uploadAttachmentStatus ?? this.uploadAttachmentStatus,
      selectedMessages: selectedMessages ?? this.selectedMessages,
      selectedUsers: selectedUsers ?? this.selectedUsers,
      attachmentList: attachmentList ?? this.attachmentList,
      pinnedMessages: pinnedMessages ?? this.pinnedMessages,
      searchedMessages: searchedMessages ?? this.searchedMessages,
      forwardError: forwardError ?? this.forwardError,
      recallErrorMessage: recallErrorMessage ?? this.recallErrorMessage,
      expandText: expandText ?? this.expandText,
      expandTextId: expandTextId ?? this.expandTextId,
      gifUrl: gifUrl ?? this.gifUrl,
      sendNamecard: sendNamecard ?? this.sendNamecard,
      sendNamecardToId: sendNamecardToId ?? this.sendNamecardToId,
      videoThumbnail: videoThumbnail ?? this.videoThumbnail,
      thumbnailList: thumbnailList ?? this.thumbnailList,
      fileToDownload: fileToDownload ?? this.fileToDownload,
      fileToUpload: fileToUpload ?? this.fileToUpload,
    );
  }

  @override
  List<Object?> get props => [
        isGroup,
        selectedMessages,
        selectedUsers,
        attachmentList,
        pinnedMessages,
        searchedMessages,
        forwardMessageStatus,
        querySearchStatus,
        recallMessageStatus,
        downloadStatus,
        downloadImageStatus,
        videoStatus,
        uploadAttachmentStatus,
        forwardError,
        recallErrorMessage,
        expandText,
        expandTextId,
        gifUrl,
        sendNamecard,
        sendNamecardToId,
        videoThumbnail,
        thumbnailList,
        fileToDownload,
        fileToUpload,
      ];
}
