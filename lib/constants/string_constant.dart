import 'package:easy_localization/easy_localization.dart';

class Strings {
  //conversation
  static String get createChat => "Create Chat".tr();

  // chat
  static String get isTyping => "is typing...".tr();
  static String get members => "members".tr();
  static String get online => "Online".tr();
  static String get lastSeenTodayAt => "last seen today at".tr();
  static String get lastSeen => "last seen ".tr();
  static String get editMessage => "Edit Message".tr();
  static String get photo => "Photo".tr();
  static String get file => "File".tr();
  static String get video => "Video".tr();
  static String get namecard => "Name Card".tr();
  static String get deleteMessage => "Delete Message".tr();
  static String get deleteMessageDescription =>
      "Are you sure to delete this message in the chat?".tr();
  static String get typeHere => "Type Here...".tr();
  static String get recall => "Recall".tr();
  static String get recallMessage => "Recall Message".tr();
  static String get recallMessageDesc =>
      "Are you sure to recall this message in the chat?".tr();
  static String get recallMessageFailed => "Recall Message Failed".tr();
  static String get deleteForEveryone => "Delete For Everyone".tr();
  static String get deleteForMe => "Delete For Me".tr();
  static String get reply => "Reply".tr();
  static String get edit => "Edit".tr();
  static String get select => "Select".tr();
  static String get copy => "Copy".tr();
  static String get textCopied => "Text Copied".tr();
  static String get translate => "Translate".tr();
  static String get forward => "Forward".tr();
  static String get favourite => "Favourite".tr();
  static String get unFavourite => "Remove Favourite".tr();
  // profile
  static String get accountSecurity => "Account Security".tr();
  static String get privacy => "Privacy".tr();
  static String get myQrCode => "My QR Code".tr();
  static String get systemSettings => "System Settings".tr();
  static String get shareInvitation => "Share Invitation".tr();
  static String get feedback => "Feedback".tr();
  static String get customerService => "Contact Customer Service".tr();
  static List<String> get systemSettingsList => [
        "Message Notice".tr(),
        "Change Language".tr(),
        "Clear Cache".tr(),
        "Clear Chat History".tr(),
        "Feedback".tr()
      ];
  static List<String> get feedbackList =>
      ["Suggestion".tr(), "Error".tr(), "Other".tr()];
  static String get changeEmail => "Change Email".tr();
  static String get enterPasswordDescription =>
      "Enter password for account security".tr();
  static String get changePhone => "Change Phone Number".tr();
  static String get email => "Email".tr();
  static String get signature => "Signature".tr();
  static String get password => "Password".tr();
  static String get myProfile => "My Profile".tr();
  static String get about => "About".tr();
  static String get checkAppVersion => "Check App Version".tr();
  static String get userAgreement => "User Agreement".tr();
  static String get privacyPolicy => "Privacy Policy".tr();
  static String get phone => "Phone".tr();
  static String get deviceManagement => "Device Management".tr();
  static String get changePassword => "Change Password".tr();
  static String get deleteAccount => "Delete Account".tr();
  static String get oldPassword => "Old Password".tr();
  static String get newPassword => "New Password".tr();
  static String get confirmPassword => "Confirm Password".tr();
  static String get accountDeletion => "Account Deletion".tr();
  static String get accountDeletionDescription =>
      "Are you sure you want to delete your account?, this action cannot be undone and all your data will be permanently deleted."
          .tr();
  static String get verifyPassword => "Verify Password".tr();

  // general
  static String get nothingHereYet => "Nothing Here Yet".tr();
  static String get today => "Today".tr();
  static String get yesterday => "Yesterday".tr();
  static String get errorOccured => "Oh no, an error occured.".tr();
  static String get cancel => "Cancel".tr();
  static String get ok => "Ok".tr();
  static String get next => "Next".tr();
  static String get searchHint => "Search...".tr();
  static String get search => "Search".tr();
  static String get delete => "Delete".tr();
  static String get wrongPassword => "Wrong Password".tr();
  static String get passwordEmpty => "Password is empty".tr();
  static String get passwordTooShort =>
      "Password should contain at least 6 characters".tr();

  // my qr
  static String get saveQr => "Save QR".tr();
  static String get shareNow => "Share QR Code".tr();
  static String get forgotPassword => "Forgot Password".tr();
  static String get registerAccount => "Register Account".tr();
  static String get login => "Login".tr();
  static String get pleaseEnterPassword => "Please Enter Password".tr();
  static String get phoneNoLogin => "Phone No. Login".tr();
  static String get phoneLogin => "Phone Login".tr();
  static String get emailLogin => "Email Login".tr();
  static String get pleaseFillInPhoneNumber =>
      "Please Fill In Phone Number".tr();
  static String get unableToSendOTP => "Unable To Send OTP".tr();
  static String get welcomeMessage =>
      "Welcome back! Please Enter Your Credentials".tr();
  static String get loginSuccess => "Login Success".tr();
  static String get loginFailed => "Login Failed".tr();
  static String get pleaseFillInVerificationCode =>
      "Please Fill In Verification Code".tr();
  static String get pleaseEnterEmail => "Please Enter Email".tr();
  static String get invitationCodeValid => "Invitation Code Valid".tr();
  static String get invitationCodeInvalid => "Invitation Code Invalid".tr();
  static String get joinWithInvitationCode => "Join With Invitation Code".tr();
  static String get join => "Join".tr();
  static String get loginAgreement =>
      "By logging in, you have read and agree to our terms of service and privacy policy."
          .tr();
  static String get getOTP => "Get OTP".tr();
  static String get passwordFormat =>
      "The password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, one number, and one special character."
          .tr();
  static String get groupAnnouncement => "Group Announcement".tr();
  static String get mediaLinkFile => "Media, Links & Files".tr();
  static String get groupJoinRequest => "Group Join Request".tr();
  static String get pinnedMessages => "Pinned Messages".tr();
  static String get addMember => "Add Member".tr();
  static String get save => "Save".tr();
  static String get all => "All".tr();
  static String get offline => "Offline".tr();
  static String get groupProfile => "Group Profile".tr();
  static String get editGroupInfo => "Edit Group Info".tr();
  static String get groupName => "Group Name".tr();
  static String get groupDescription => "Group Description".tr();
  static String get areYouSureYouWantToRemove =>
      "Are you sure you want to remove".tr();
  static String get kickMemberDescription =>
      "Once removed, it cannot be recovered. Are you sure you want to remove it?"
          .tr();
  static String get kickMember => "Kick Member".tr();
  static String get memberKicked => "Member Kicked".tr();
  static String get admin => "Admin".tr();
  static String get inactiveUsers => "Inactive Users".tr();
  static String get kickAllInactiveUser => "Kick All Inactive Users".tr();
  static String get manageInactiveUsers => "Manage Inactive Users".tr();
  static String get anonymous => "Anonymous".tr();
  static String get onlyAdminAbleToSendMessage =>
      "Only Admin Able To Send Message".tr();

  // response
  static String get invalidLogin => "Invalid Login Credential".tr();
  static String get emailFormatInvalid => "Email Format Invalid".tr();
  static String get emailUnavailable => "Email Unavailable".tr();
  static String get emailBanned => "Email is banned".tr();
  static String get emailInvalid => "Email Invalid".tr();
  static String get phoneFormatInvalid => "Phone Format Invalid".tr();
  static String get phoneUnavailable => "Phone Unavailable".tr();
  static String get phoneBanned => "Phone is banned".tr();
  static String get phoneInvalid => "Phone Invalid".tr();
  static String get nameInvalid => "Name Invalid".tr();
  static String get nameUnavailable => "Name unavailable".tr();
  static String get nameBanned => "Name is banned".tr();

  static String get otpInvalid => "OTP Invalid".tr();
  static String get otpNotFound => "OTP incorrect".tr();
  static String get passwordDoesNotMatch => "Password Does Not Match".tr();
  static String get passwordFormatInvalid => "Password format is invalid".tr();
  static String get newPasswordFormatInvalid =>
      "New password format is invalid".tr();
  static String get lastOnline => "Last Online".tr();
  static String get pin => "Pin".tr();
  static String get unpin => "Unpin".tr();
  static String get termOfUse => "Terms of Use".tr();
  static String get cantSendToDeletedFriend =>
      "You can't message someone who aren't friend".tr();
  static String get noResultFound => "No Result Found".tr();
  static String get searchChat => "Search Chat".tr();
  static String get me => "Me".tr();
  static String get disbandGroup => "Disband Group".tr();
  static String get leaveGroup => "Leave Group".tr();
  static String get currentDevice => "Current Device".tr();
  static String get downloadableLanguage => "Downloadable Languages".tr();
  static String get groupWelcomeMessage => "Welcome to [name] group".tr();
  static String get media => "Media".tr();
  static String get friendProfile => "Friend Profile".tr();
  static String get mediaFile => "Media & Files".tr();
  static String get blacklist => "Blacklist".tr();
  static String get friendDeletedSuccessfully =>
      "Friend Deleted Successfully".tr();
  static String get deleteFriend => "Delete Friend".tr();
  static String get noGroupJoinRequestYet => "No Group Join Request Yet".tr();
  static String get groupEntryVerification => "Group Entry Verification".tr();
  static String get groupEntryDescription =>
      "After enabling this feature, members will need to be approved by the group owner or group admin."
          .tr();
  static String get screenshot => "Screenshot".tr();
  static String get muteMember => "Mute Member".tr();
  static String get memberInvisible => "Member unable to see each other".tr();
  static String get memberCanViewPastHistory =>
      "Member can view past history".tr();
  static String get memberCanSendNamecard => "Member can send namecard".tr();
  static String get memberCanSendPictures => "Member can send pictures".tr();
  static String get memberCanSendVideos => "Member can send videos".tr();
  static String get memberCanSendFiles => "Member can send files".tr();
  static String get memberCanSeeMemberList => "Member can see member list".tr();
  static String get memberCanAddNewMember => "Member can add new member".tr();
  static String get onlyOwnerCanAccess => "Only Owner Can Access".tr();
  static String get friendAddedSuccessfully => "Friend Added Successfully".tr();
  static String get friendRequestSentSuccessfully =>
      "Friend Request Sent Successfully".tr();
  static String get addFriend => "Add Friend".tr();
  static String get ownerFailedToLeaveGroupDesc =>
      "Failed to leave the group. Kindly transfer your group ownership before leaving"
          .tr();
  static String get exit => "exit".tr();
  static String get unpinAllMessages => "Unpin all messages".tr();
  static String get deletedUser => "Deleted User".tr();
  static String get chat => "Chat".tr();
  static String get syncingMessages => "Syncing Messages...".tr();
  static String get chatHistoryNotFound => "Chat History Not Found".tr();
  static String get conversationNotFound => "Conversation Not Found".tr();
  static String get searchTermNotFound => "Your Search Term Not Found".tr();
  static String get pleaseRetry => "Please Retry".tr();
  static String get welcomeToMyFavourites => "Welcome To My Favourites".tr();
  static String get favouriteDetails => "Favourite Details".tr();
  static String get removeFavourite => "Remove Favourite".tr();
  static String get noFavouriteMessages => "No Favourite Messages".tr();
  static String get noFavouriteMessageYet =>
      "You don't have any favorite message yet".tr();
  static String get tapStarIcon =>
      "Tap on the star icon on a message popup menu to add it to your favorite list."
          .tr();
  static String get unableToConnectToServer =>
      "Unable to connect to the server, please try again.".tr();
  static String get passwordFormatDesc =>
      "Password must contain uppercase letters, lowercase letters,numbers and symbols, at least 8 characters"
          .tr();
  static String get resetPassword => "Reset Password".tr();
  static String get resetPasswordSuccess => "Reset Password Success".tr();
  static String get backToLogin => "Back To Login".tr();
  static String get unknownError => "Unknown Error".tr();
  static String get alreadyFriendWithThisUser =>
      "You are already friends with this user".tr();
  static String get you => "You".tr();
  static String get message => "Message".tr();
  static String get passwordChangedSuccessfully =>
      "Your password has been changed succesfully".tr();
  static String get passwordResetFail => "Password Reset Failed".tr();
  static String get couldNotSendOTP => "Could not send OTP".tr();
  static String get phoneVerification => "Phone Verification".tr();
  static String get emailVerification => "Email Verification".tr();
  static String get cannotAddYourselfAsFriend =>
      "Cannot Add Yourself As Friend".tr();
  static String get unableToSearchUser => "Unable to search user".tr();
  static String get userProfileNotFound => "User profile not found".tr();
  static String get unableToSendFriendRequest =>
      "Unable to send friend request".tr();
  static String get myId => "My ID:".tr();
  static String get scanQRCode => "Scan QR Code".tr();
  static String get enterGroupName => "Enter Group Name".tr();
  static String get groupNameCannotBeEmpty => "Group Name Cannot Be Empty".tr();
  static String get createGroup => "Create Group".tr();
  static String get noContactAdded => "No Contact Added".tr();
  static String get somethingWentWrong => "Something Went Wrong".tr();
  static String get noGroupAdded => "No Group Added".tr();
  static String get addYourGroupMember => "Add your group member".tr();
  static String get remove => "Remove".tr();
  static String get uploadProfileImage => "Upload Profile Image".tr();
  static String get chooseOneImageToUpload => "Choose one image to upload".tr();
  static String get friendRequest => "Friend Request".tr();
  static String get noFriendRequestYet => "No Friend Request Yet".tr();
  static String get pendingFriendRequest => "Pending Friend Request".tr();
  static String get noSentFriendRequestYet => "No Sent Friend Request Yet".tr();
  static String get selectFriends => "Select Friends".tr();
  static String get selected => "Selected".tr();
  static String get friends => "Friends".tr();
  static String get groups => "Groups".tr();
  static String get failToGetUserInfo => "Failed to get user info".tr();
  static String get invalidQRCode => "Invalid QR Code".tr();
  static String get startChatting => "Start Chatting".tr();
  static String get noInternetConnection => "No Internet Connection".tr();
  static String get version => "Version".tr();
  static String get addContactMethod => "Add Contact Method".tr();
  static String get noDeviceFound => "No Device Found".tr();
  static String get changeSignatureSuccessfully =>
      "Changed signature successfully".tr();
  static String get unableToChangeSignature =>
      "Unable to change signature".tr();
  static String get failToUpdateUserInfo => "Fail To Update User Info".tr();
  static String get successfullyUpdateUserInfo =>
      "Successfully Update User Info".tr();
  static String get unableToChangeProfileImage =>
      "Unable To Change Profile Image".tr();
  static String get changeProfileImageSuccessfully =>
      "Change Profile Image Successfully".tr();
  static String get unableToChangeGender => "Unable To Change Gender".tr();
  static String get changeGenderSuccessfully =>
      "Change Gender Successfully".tr();
  static String get unableToChangeName => "Unable To Change Name".tr();
  static String get changeNameSuccessfully => "Change Name Successfully".tr();
  static String get enterYourName => "Enter Your Name".tr();
  static String get nameCannotBeEmpty => "Name cannot be empty".tr();
  static String get name => "Name".tr();
  static String get gender => "Gender".tr();
  static String get enterYourSignature => "Enter Your Signature".tr();
  static String get enterYourStatusMessage => "Enter Your Status Message".tr();
  static String get male => "Male".tr();
  static String get female => "Female".tr();
  static String get preferNotToSay => "Prefer Not To Say".tr();
  static String get changeLanguage => "Change Language".tr();
  static String get messageNotice => "Message Notice".tr();
  static String get newMessageNotification => "New Message Notification".tr();
  static String get inAppSound => "In-app Sound".tr();
  static String get inAppVibration => "In-app Vibration".tr();
  static String get scanQRToAddFriend =>
      "Scan QR code and add me as a friend".tr();
  static String get pleaseEnterUsername => "Please Enter Username".tr();
  static String get methodsForAddingContact =>
      "Methods for adding contact".tr();
  static String get addMeNeedVerification => "Add Me Need Verification".tr();
  static String get unknown => "Unknown".tr();
  static String get logout => "Logout".tr();
  static String get logoutSuccess => "Logout Successfully".tr();
  static String get logoutFail => "Logout Failed".tr();
  static String get logoutDescription =>
      "Are you sure you want to logout?".tr();
  static String get aboutUs => "About Us".tr();
  static String get accountSettings => "Account Settings".tr();
  static String get settings => "Settings".tr();
  static String get deleteFailed => "Delete Failed".tr();
  static String get deleteSuccess => "Delete Success".tr();
  static String get switchLanguage => "Switch Language".tr();
  static String get clearCache => "Clear Cache".tr();
  static String get clearCacheSuccess => "Clear Cache Success".tr();
  static String get clearCacheFailed => "Clear Cache Failed".tr();
  static String get clear => "Clear".tr();
  static String get clearCacheDesc =>
      "The cache contains a message attachment of size [fileSize]. Clearing it will free up storage space on your phone. This operation is safe and reliable, and will not result in the loss of your friend/group information or chat history."
          .tr();
  static String get clearChatHistory => "Clear Chat History".tr();
  static String get clearChatHistoryDesc =>
      "The cleared chat history cannot be restored. Please confirm if you want to delete all personal and group chat history."
          .tr();
  static String get changeLanguageDesc =>
      "Changing language will require to restart the app. Are you sure?".tr();
  static String get registerSuccess => "Register Success".tr();
  static String get registerFailed => "Register Failed".tr();
  static String get registerSuccessDesc =>
      "We have sent a verification email to you. \nThank you for registering!"
          .tr();
  static String get iHaveReadAndAgreeTo => "I have read and agree to".tr();
  static String get pleaseReadAndAgreeToPrivacyPolicy =>
      "Please Read And Agree To Privacy Policy".tr();
  static String get browser => "Browser".tr();
  static String get contact => "Contact".tr();
  static String get QRSaved => "QR saved to album successfully".tr();
  static String get myQRDesc =>
      "Your friend invited you to use Prochat, scan the QR code with your phone's built-in browser to download the app. After the installation is complete, scan again to apply for both parties as friends. Let's experience the journey together now!"
          .tr();
  static String get typeHint => "Type Here...".tr();
  static String get showLess => "Show Less".tr();
  static String get showMore => "Show More".tr();
  static String get stickerNotFound => "Sticker Not Found".tr();
  static String get audio => "Audio".tr();
  static String get youHaveBeenLoggedOut => "You Have Been Logged Out".tr();
  static String get youHaveBeenLoggedOutDesc =>
      "You have been logged out, please login again".tr();
  static String get cannotSendToDeletedFriend =>
      "Cannot Send To Deleted Friend".tr();
  static String get youHaveBeenKickedOut => "You Have Been Kicked Out".tr();
  static String get memberAdded => "Member Added".tr();
  static String get joinRequestSent => "Join Request Sent".tr();
  static String get unmute => "Unmute".tr();
  static String get mute => "Mute".tr();

  // last update 14/2

  static String get selectGroupMembers => "Selected Group Members".tr();
  static String get feedbackType => "Feedback Type".tr();
  static String get messageHasBeenRecalled =>
      "This message has been recalled".tr();
  static String get feedbackScreenshots => "Feedback Screenshots".tr();
  static String get feedbackContent => "Feedback Content".tr();
  static String get feedbackHintText =>
      "Please try to describe the feedback in detail and we will deal with it for you as soon as possible"
          .tr();
  static String get feedbackSubmittedSuccess => "Feedback submitted".tr();
  static String get feedbackSubmitFail =>
      "Feedback submit failed. Please try again".tr();
  static String get image => "Image".tr();
  static String get favouriteList => "Favourite List".tr();
  static String get sentByMe => "Sent By Me".tr();
  static String get sticker => "Sticker".tr();
  static String get fileSizeExceed30MB => "File size exceeds 30 MB".tr();
  static String get pleaseSelectValidFile => "Please select a valid file".tr();
  static String get failToCreateGroup => "Failed to create group".tr();
  static String get chatCreatedSuccessful => "Chat created successfully".tr();
  static String get connecting => "Connecting..".tr();
  static String get sentFriendRequest => "Sent Friend Request".tr();
}
