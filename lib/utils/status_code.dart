// ignore_for_file: constant_identifier_names

import 'package:protech_mobile_chat_stream/utils/iterable_apis.dart';

enum StatusCode {
  ADMIN_IS_INVALID(400, "ADMIN_IS_INVALID", "Admin is invalid"),
  ADMIN_IS_UNAVAILABLE(400, "ADMIN_IS_UNAVAILABLE", "Admin is unavailable"),
  CATEGORY_CANNOT_BE_NULL(
      400, "CATEGORY_CANNOT_BE_NULL", "Category cannot be null"),
  CATEGORY_IS_INVALID(400, "CATEGORY_IS_INVALID", "Category is invalid"),
  CODE_CANNOT_BE_NULL(400, "CODE_CANNOT_BE_NULL", "Code cannot be null"),
  CODE_FORMAT_IS_INVALID(
      400, "CODE_FORMAT_IS_INVALID", "Code format is invalid"),
  CODE_IS_INVALID(400, "CODE_IS_INVALID", "Code is invalid"),
  CODE_IS_UNAVAILABLE(400, "CODE_IS_UNAVAILABLE", "Code is unavailable"),
  COUNTRY_CODE_IS_INVALID(
      400, "COUNTRY_CODE_IS_INVALID", "Country code is invalid"),
  CUSTOMER_SERVICE_NOT_FOUND(
      400, "CUSTOMER_SERVICE_NOT_FOUND", "Customer Service not found"),
  DEVICE_ID_CANNOT_BE_NULL(
      400, "DEVICE_ID_CANNOT_BE_NULL", "Device id cannot be null"),
  DEVICE_MODEL_CANNOT_BE_NULL(
      400, "DEVICE_MODEL_CANNOT_BE_NULL", "Device model cannot be null"),
  DEVICE_TOKEN_CANNOT_BE_NULL(
      400, "DEVICE_TOKEN_CANNOT_BE_NULL", "Device token cannot be null"),
  DEVICE_TOKEN_IS_UNAVAILABLE(
      400, "DEVICE_TOKEN_IS_UNAVAILABLE", "Device token is unavailable"),
  DEVICE_TYPE_CANNOT_BE_NULL(
      400, "DEVICE_TYPE_CANNOT_BE_NULL", "Device type cannot be null"),
  DEVICE_TYPE_IS_INVALID(
      400, "DEVICE_TYPE_IS_INVALID", "Device type is invalid"),
  EMAIL_CANNOT_BE_NULL(400, "EMAIL_CANNOT_BE_NULL", "Email cannot be null"),
  EMAIL_FORMAT_IS_INVALID(
      400, "EMAIL_FORMAT_IS_INVALID", "Email format is invalid"),
  EMAIL_IS_INVALID(400, "EMAIL_IS_INVALID", "Email is invalid"),
  EMAIL_IS_UNAVAILABLE(400, "EMAIL_IS_UNAVAILABLE", "Email is unavailable"),
  FAILED_TO_BLOCK_TURMS_FRIEND_SETTING(
      400,
      "FAILED_TO_BLOCK_TURMS_FRIEND_SETTING",
      "Failed to block turms friend setting"),
  FAILED_TO_CREATE_CUSTOMER_SERVICE(400, "FAILED_TO_CREATE_CUSTOMER_SERVICE",
      "Failed to create customer service"),
  FAILED_TO_CREATE_DEVICE(
      400, "FAILED_TO_CREATE_DEVICE", "Failed to create device"),
  FAILED_TO_CREATE_FEEDBACK(
      400, "FAILED_TO_CREATE_FEEDBACK", "Failed to create feedback"),
  FAILED_TO_CREATE_GETSTREAM_USER(400, "FAILED_TO_CREATE_GETSTREAM_USER",
      "Failed to create getstream user"),
  FAILED_TO_CREATE_TOKEN(
      400, "FAILED_TO_CREATE_TOKEN", "Failed to create token"),
  FAILED_TO_CREATE_TURMS_USER(
      400, "FAILED_TO_CREATE_TURMS_USER", "Failed to create turms user"),
  FAILED_TO_CREATE_USER(400, "FAILED_TO_CREATE_USER", "Failed to create user"),
  FAILED_TO_DELETE_ADMIN_FROM_REDIS(400, "FAILED_TO_DELETE_ADMIN_FROM_REDIS",
      "Failed to delete admin from redis"),
  FAILED_TO_DELETE_BAN_USER_NAME_FROM_REDIS(
      400,
      "FAILED_TO_DELETE_BAN_USER_NAME_FROM_REDIS",
      "Failed to ban user name from redis"),
  FAILED_TO_DELETE_ACCOUNT(
      400, "FAILED_TO_DELETE_ACCOUNT", "Failed to delete account"),
  FAILED_TO_DELETE_BAN_IP_FROM_REDIS(
      400, "FAILED_TO_DELETE_BAN_IP_FROM_REDIS", "Failed to ban IP from redis"),
  FAILED_TO_DELETE_CUSTOMER_SERVICE(400, "FAILED_TO_DELETE_CUSTOMER_SERVICE",
      "Failed to delete customer service"),
  FAILED_TO_DELETE_DEVICE(
      400, "FAILED_TO_DELETE_DEVICE", "Failed to update device"),
  FAILED_TO_DELETE_DEVICE_FROM_REDIS(400, "FAILED_TO_DELETE_DEVICE_FROM_REDIS",
      "Failed to delete device from redis"),
  FAILED_TO_DELETE_EMAIL_OTP_FROM_REDIS(
      400,
      "FAILED_TO_DELETE_EMAIL_OTP_FROM_REDIS",
      "Failed to email OTP from redis"),
  FAILED_TO_DELETE_FEEDBACK(
      400, "FAILED_TO_DELETE_FEEDBACK", "Failed to delete feedback"),
  FAILED_TO_DELETE_FROM_REDIS(
      400, "FAILED_TO_DELETE_FROM_REDIS", "Failed to delete from redis"),
  FAILED_TO_DELETE_GETSTREAM_USER(400, "FAILED_TO_DELETE_GETSTREAM_USER",
      "Failed to delete getstream user"),
  FAILED_TO_DELETE_INVITATION_CODE_FROM_REDIS(
      400,
      "FAILED_TO_DELETE_INVITATION_CODE_FROM_REDIS",
      "Failed to delete invitation code from redis"),
  FAILED_TO_DELETE_PHONE_OTP_FROM_REDIS(
      400,
      "FAILED_TO_DELETE_PHONE_OTP_FROM_REDIS",
      "Failed to phone OTP from redis"),
  FAILED_TO_DELETE_USER(400, "FAILED_TO_DELETE_USER", "Failed to update user"),
  FAILED_TO_DELETE_TEMP_UUID_FROM_REDIS(
      400,
      "FAILED_TO_DELETE_TEMP_UUID_FROM_REDIS",
      "Failed to temp uuid from redis"),
  FAILED_TO_DELETE_TENANT_FROM_REDIS(400, "FAILED_TO_DELETE_TENANT_FROM_REDIS",
      "Failed to delete tenant from redis"),
  FAILED_TO_DELETE_TURMS_USER(
      400, "FAILED_TO_DELETE_TURMS_USER", "Failed to delete turms user"),
  FAILED_TO_DELETE_USER_FROM_REDIS(400, "FAILED_TO_DELETE_USER_FROM_REDIS",
      "Failed to delete user from redis"),
  FAILED_TO_ENCODE_BASE_62(
      400, "FAILED_TO_ENCODE_BASE_62", "Failed to encode base 62"),
  FAILED_TO_ENCODE_PASSWORD(
      400, "FAILED_TO_ENCODE_PASSWORD", "Failed to encode password"),
  FAILED_TO_FILTER_TENANT_ID_FROM_TOKEN(
      400,
      "FAILED_TO_FILTER_TENANT_ID_FROM_TOKEN",
      "Failed to filter tenant id from token"),
  FAILED_TO_FIND_ADMIN_FROM_REDIS(400, "FAILED_TO_FIND_ADMIN_FROM_REDIS",
      "Failed to find admin from redis"),
  FAILED_TO_FIND_BAN_IP_FROM_REDIS(400, "FAILED_TO_FIND_BAN_IP_FROM_REDIS",
      "Failed to find ban IP from redis"),
  FAILED_TO_FIND_BAN_USER_NAME_FROM_REDIS(
      400,
      "FAILED_TO_FIND_BAN_USER_NAME_FROM_REDIS",
      "Failed to find ban user name from redis"),
  FAILED_TO_FIND_DEVICE_FROM_REDIS(400, "FAILED_TO_FIND_DEVICE_FROM_REDIS",
      "Failed to find device from redis"),
  FAILED_TO_FIND_EMAIL_OTP_FROM_REDIS(
      400,
      "FAILED_TO_FIND_EMAIL_OTP_FROM_REDIS",
      "Failed to find email OTP from redis"),
  FAILED_TO_FIND_FROM_REDIS(
      400, "FAILED_TO_FIND_FROM_REDIS", "Failed to find from redis"),
  FAILED_TO_FIND_INVITATION_CODE_FROM_REDIS(
      400,
      "FAILED_TO_FIND_INVITATION_CODE_FROM_REDIS",
      "Failed to find invitation code from redis"),
  FAILED_TO_FIND_PHONE_OTP_FROM_REDIS(
      400,
      "FAILED_TO_FIND_PHONE_OTP_FROM_REDIS",
      "Failed to find phone OTP from redis"),
  FAILED_TO_FIND_TEMP_UUID_FROM_REDIS(
      400,
      "FAILED_TO_FIND_TEMP_UUID_FROM_REDIS",
      "Failed to find temp uuid from redis"),
  FAILED_TO_FIND_TENANT_FROM_REDIS(400, "FAILED_TO_FIND_TENANT_FROM_REDIS",
      "Failed to find tenant from redis"),
  FAILED_TO_FIND_USER_FROM_REDIS(
      400, "FAILED_TO_FIND_USER_FROM_REDIS", "Failed to find user from redis"),
  FAILED_TO_GENERATE_GETSTREAM_API_JWT(
      400,
      "FAILED_TO_GENERATE_GETSTREAM_API_JWT",
      "Failed to generate getstream api jwt"),
  FAILED_TO_GENERATE_TURMS_API_JWT(400, "FAILED_TO_GENERATE_TURMS_API_JWT",
      "Failed to generate turms api jwt"),
  FAILED_TO_GET_ADMIN_FROM_REDIS(
      400, "FAILED_TO_GET_ADMIN_FROM_REDIS", "Failed to get admin from redis"),
  FAILED_TO_GET_ADMIN_API_HEADER(
      400, "FAILED_TO_GET_ADMIN_API_HEADER", "Failed to get admin api header"),
  FAILED_TO_GET_BAN_IP_FROM_REDIS(400, "FAILED_TO_GET_BAN_IP_FROM_REDIS",
      "Failed to get ban IP from redis"),
  FAILED_TO_GET_BAN_USER_NAME_FROM_REDIS(
      400,
      "FAILED_TO_GET_BAN_USER_NAME_FROM_REDIS",
      "Failed to get ban user name from redis"),
  FAILED_TO_GET_CALL_DURATION_BY_DATE(
      400,
      "FAILED_TO_GET_CALL_DURATION_BY_DATE",
      "Failed to get call duration by date"),
  FAILED_TO_GET_CLAIM_FROM_TOKEN(
      400, "FAILED_TO_GET_CLAIM_FROM_TOKEN", "Failed to get claim from token"),
  FAILED_TO_GET_CLAIMS_FROM_TOKEN(400, "FAILED_TO_GET_CLAIMS_FROM_TOKEN",
      "Failed to get claims from token"),
  FAILED_TO_GET_CUSTOMER_SERVICE(
      400, "FAILED_TO_GET_CUSTOMER_SERVICE", "Failed to get customer service"),
  FAILED_TO_GET_CUSTOMER_SERVICE_API_HEADER(
      400,
      "FAILED_TO_GET_CUSTOMER_SERVICE_API_HEADER",
      "Failed to get customer service api header"),
  FAILED_TO_GET_CUSTOMER_SERVICES(400, "FAILED_TO_GET_CUSTOMER_SERVICES",
      "Failed to get customer services"),
  FAILED_TO_GET_DEVICE(400, "FAILED_TO_GET_DEVICE", "Failed to get device"),
  FAILED_TO_GET_DEVICE_API_HEADER(400, "FAILED_TO_GET_DEVICE_API_HEADER",
      "Failed to get device api header"),
  FAILED_TO_GET_DEVICE_FROM_REDIS(400, "FAILED_TO_GET_DEVICE_FROM_REDIS",
      "Failed to get device from redis"),
  FAILED_TO_GET_DEVICES(400, "FAILED_TO_GET_DEVICES", "Failed to get devices"),
  FAILED_TO_GET_DEVICE_TOKEN_FROM_TOKEN(
      400,
      "FAILED_TO_GET_DEVICE_TOKEN_FROM_TOKEN",
      "Failed to get device token from token"),
  FAILED_TO_GET_DEVICE_TYPE_FROM_TOKEN(
      400,
      "FAILED_TO_GET_DEVICE_TYPE_FROM_TOKEN",
      "Failed to get device type from token"),
  FAILED_TO_GET_EMAIL_OTP_FROM_REDIS(400, "FAILED_TO_GET_EMAIL_OTP_FROM_REDIS",
      "Failed to get email OTP from redis"),
  FAILED_TO_GET_EXPIRATION_FROM_TOKEN(
      400,
      "FAILED_TO_GET_EXPIRATION_FROM_TOKEN",
      "Failed to get expiration from token"),
  FAILED_TO_GET_FEEDBACK(
      400, "FAILED_TO_GET_FEEDBACK", "Failed to get feedback"),
  FAILED_TO_GET_FEEDBACK_API_HEADER(400, "FAILED_TO_GET_FEEDBACK_API_HEADER",
      "Failed to get feedback api header"),
  FAILED_TO_GET_FEEDBACKS(
      400, "FAILED_TO_GET_FEEDBACKS", "Failed to get feedbacks"),
  FAILED_TO_GET_FROM_REDIS(
      400, "FAILED_TO_GET_FROM_REDIS", "Failed to get from redis"),
  FAILED_TO_GET_GETSTREAM_API_HEADER(400, "FAILED_TO_GET_GETSTREAM_API_HEADER",
      "Failed to get admin api header"),
  FAILED_TO_GET_GETSTREAM_API_KEY_FROM_TOKEN(
      400,
      "FAILED_TO_GET_GETSTREAM_API_KEY_FROM_TOKEN",
      "Failed to get GetStream API Key from token"),
  FAILED_TO_GET_GETSTREAM_JWT_FROM_TOKEN(
      400,
      "FAILED_TO_GET_GETSTREAM_JWT_FROM_TOKEN",
      "Failed to get GetStream JWT from token"),
  FAILED_TO_GET_GETSTREAM_UID_FROM_TOKEN(
      400,
      "FAILED_TO_GET_GETSTREAM_UID_FROM_TOKEN",
      "Failed to get GetStream UId from token"),
  FAILED_TO_GET_ID_FROM_TOKEN(
      400, "FAILED_TO_GET_ID_FROM_TOKEN", "Failed to get id from token"),
  FAILED_TO_GET_INVITATION_CODE_CODE_FROM_TOKEN(
      400,
      "FAILED_TO_GET_INVITATION_CODE_CODE_FROM_TOKEN",
      "Failed to get invitation code code from token"),
  FAILED_TO_GET_INVITATION_CODE_FROM_REDIS(
      400,
      "FAILED_TO_GET_INVITATION_CODE_FROM_REDIS",
      "Failed to get invitation code from redis"),
  FAILED_TO_GET_INVITATION_CODE_ID_FROM_TOKEN(
      400,
      "FAILED_TO_GET_INVITATION_CODE_ID_FROM_TOKEN",
      "Failed to get invitation code id from token"),
  FAILED_TO_GET_ISSUED_AT_FROM_TOKEN(400, "FAILED_TO_GET_ISSUED_AT_FROM_TOKEN",
      "Failed to get issued at from token"),
  FAILED_TO_GET_MASTER_ADMIN_API_HEADER(
      400,
      "FAILED_TO_GET_MASTER_ADMIN_API_HEADER",
      "Failed to get master admin api header"),
  FAILED_TO_GET_MASTER_ADMIN_POLICY_CONTENT(
      400,
      "FAILED_TO_GET_MASTER_ADMIN_POLICY_CONTENT",
      "Failed to get master admin policy content"),
  FAILED_TO_GET_PHONE_OTP_FROM_REDIS(400, "FAILED_TO_GET_PHONE_OTP_FROM_REDIS",
      "Failed to get phone OTP from redis"),
  FAILED_TO_GET_PROFILE(400, "FAILED_TO_GET_PROFILE", "Failed to get profile"),
  FAILED_TO_GET_RECENT_CALLS(
      400, "FAILED_TO_GET_RECENT_CALLS", "Failed to get recent calls"),
  FAILED_TO_GET_ROLE_ID_FROM_TOKEN(400, "FAILED_TO_GET_ROLE_ID_FROM_TOKEN",
      "Failed to get role id from token"),
  FAILED_TO_GET_ROLE_NAME_FROM_TOKEN(400, "FAILED_TO_GET_ROLE_NAME_FROM_TOKEN",
      "Failed to get role name from token"),
  FAILED_TO_GET_SUBJECT_FROM_TOKEN(400, "FAILED_TO_GET_SUBJECT_FROM_TOKEN",
      "Failed to get subject from token"),
  FAILED_TO_GET_USER_FROM_REDIS(
      400, "FAILED_TO_GET_USER_FROM_REDIS", "Failed to get user from redis"),
  FAILED_TO_GET_TEMP_UUID_FROM_REDIS(400, "FAILED_TO_GET_TEMP_UUID_FROM_REDIS",
      "Failed to get temp uuid from redis"),
  FAILED_TO_GET_TENANT_FROM_REDIS(400, "FAILED_TO_GET_TENANT_FROM_REDIS",
      "Failed to get tenant from redis"),
  FAILED_TO_GET_TENANT_ID_FROM_TOKEN(400, "FAILED_TO_GET_TENANT_ID_FROM_TOKEN",
      "Failed to get tenant id from token"),
  FAILED_TO_GET_TENANT_NAME_FROM_TOKEN(
      400,
      "FAILED_TO_GET_TENANT_NAME_FROM_TOKEN",
      "Failed to get tenant name from token"),
  FAILED_TO_GET_TENANT_SERVICE_URL(400, "FAILED_TO_GET_TENANT_SERVICE_URL",
      "Failed to get tenant service url"),
  FAILED_TO_GET_THIS_MONTH_ACTIVE_USER(
      400,
      "FAILED_TO_GET_THIS_MONTH_ACTIVE_USER",
      "Failed to get this month active user"),
  FAILED_TO_GET_TODAY_ACTIVE_USER(400, "FAILED_TO_GET_TODAY_ACTIVE_USER",
      "Failed to get today active user"),
  FAILED_TO_GET_TOKEN(400, "FAILED_TO_GET_TOKEN", "Failed to get token"),
  FAILED_TO_GET_TURMS_UID_FROM_TOKEN(400, "FAILED_TO_GET_TURMS_UID_FROM_TOKEN",
      "Failed to get Turms Uid from token"),
  FAILED_TO_GET_TURMS_API_HEADER(
      400, "FAILED_TO_GET_TURMS_API_HEADER", "Failed to get turms api header"),
  FAILED_TO_GET_USER(400, "FAILED_TO_GET_USER", "Failed to get user"),
  FAILED_TO_GET_USERNAME_FROM_TOKEN(400, "FAILED_TO_GET_USERNAME_FROM_TOKEN",
      "Failed to get username from token"),
  FAILED_TO_GET_USERS(400, "FAILED_TO_GET_USERS", "Failed to get users"),
  FAILED_TO_GET_JWT_TYPE_FROM_TOKEN(400, "FAILED_TO_GET_JWT_TYPE_FROM_TOKEN",
      "Failed to get jwt type from token"),
  FAILED_TO_KICK_DEVICE(400, "FAILED_TO_KICK_DEVICE", "Failed to kick device"),
  FAILED_TO_LINK_DEVICE(400, "FAILED_TO_LINK_DEVICE", "Failed to link device"),
  FAILED_TO_LIST_ONLINE_STATUS_BY_LIST_OF_TURMS_USER_ID(
      400,
      "FAILED_TO_LIST_ONLINE_STATUS_BY_LIST_OF_TURMS_USER_ID",
      "Failed to list online status by list of turms user id"),
  FAILED_TO_LIST_USER_FOR_BLOCK_FRIEND_SETTING(
      400,
      "FAILED_TO_LIST_USER_FOR_BLOCK_FRIEND_SETTING",
      "Failed to list user for block friend setting"),
  FAILED_TO_LOGIN_BY_EMAIL(
      400, "FAILED_TO_LOGIN_BY_EMAIL", "Failed to login by email"),
  FAILED_TO_LOGIN_BY_PHONE(
      400, "FAILED_TO_LOGIN_BY_PHONE", "Failed to login by phone"),
  FAILED_TO_LOGOUT(400, "FAILED_TO_LOGOUT", "Failed to logout"),
  FAILED_TO_MATCH_PASSWORD(
      400, "FAILED_TO_MATCH_PASSWORD", "Failed to match password"),
  FAILED_TO_PUT_ADMIN_TO_REDIS(
      400, "FAILED_TO_PUT_ADMIN_TO_REDIS", "Failed to put admin to redis"),
  FAILED_TO_PUT_BAN_IP_TO_REDIS(
      400, "FAILED_TO_PUT_BAN_IP_TO_REDIS", "Failed to put ban IP to redis"),
  FAILED_TO_PUT_BAN_USER_NAME_TO_REDIS(
      400,
      "FAILED_TO_PUT_BAN_USER_NAME_TO_REDIS",
      "Failed to put ban user name to redis"),
  FAILED_TO_PUT_DEVICE_TO_REDIS(
      400, "FAILED_TO_PUT_DEVICE_TO_REDIS", "Failed to put device to redis"),
  FAILED_TO_PUT_EMAIL_OTP_TO_REDIS(400, "FAILED_TO_PUT_EMAIL_OTP_TO_REDIS",
      "Failed to put email OTP to redis"),
  FAILED_TO_PUT_INVITATION_CODE_TO_REDIS(
      400,
      "FAILED_TO_PUT_INVITATION_CODE_TO_REDIS",
      "Failed to put invitation code to redis"),
  FAILED_TO_PUT_PHONE_OTP_TO_REDIS(400, "FAILED_TO_PUT_PHONE_OTP_TO_REDIS",
      "Failed to put phone OTP to redis"),
  FAILED_TO_PUT_TEMP_UUID_TO_REDIS(400, "FAILED_TO_PUT_TEMP_UUID_TO_REDIS",
      "Failed to put temp uuid to redis"),
  FAILED_TO_PUT_TENANT_TO_REDIS(
      400, "FAILED_TO_PUT_TENANT_TO_REDIS", "Failed to put tenant to redis"),
  FAILED_TO_PUT_TO_REDIS(
      400, "FAILED_TO_PUT_TO_REDIS", "Failed to put to redis"),
  FAILED_TO_PUT_USER_TO_REDIS(
      400, "FAILED_TO_PUT_USER_TO_REDIS", "Failed to put user to redis"),
  FAILED_TO_REGISTER_BY_EMAIL(
      400, "FAILED_TO_REGISTER_BY_EMAIL", "Failed to register by email"),
  FAILED_TO_REGISTER_BY_PHONE(
      400, "FAILED_TO_REGISTER_BY_PHONE", "Failed to register by phone"),
  FAILED_TO_SEND_OTP_TO_EMAIL(
      400, "FAILED_TO_SEND_OTP_TO_EMAIL", "Failed to send otp to email"),
  FAILED_TO_SEND_OTP_TO_PHONE(
      400, "FAILED_TO_SEND_OTP_TO_PHONE", "Failed to send otp to phone"),
  FAILED_TO_SEND_PUSH_NOTIFICATION(400, "FAILED_TO_SEND_PUSH_NOTIFICATION",
      "Failed to send push notification"),
  FAILED_TO_SEND_WEB_SOCKET(
      400, "FAILED_TO_SEND_WEB_SOCKET", "Failed to send web socket"),
  FAILED_TO_UPDATE_CUSTOMER_SERVICE(400, "FAILED_TO_UPDATE_CUSTOMER_SERVICE",
      "Failed to update customer service"),
  FAILED_TO_UPDATE_DEVICE(
      400, "FAILED_TO_UPDATE_DEVICE", "Failed to update device"),
  FAILED_TO_UPDATE_EMAIL(
      400, "FAILED_TO_UPDATE_EMAIL", "Failed to update email"),
  FAILED_TO_UPDATE_FEEDBACK(
      400, "FAILED_TO_UPDATE_FEEDBACK", "Failed to update feedback"),
  FAILED_TO_UPDATE_GETSTREAM_USER(400, "FAILED_TO_UPDATE_GETSTREAM_USER",
      "Failed to update getstream user"),
  FAILED_TO_UPDATE_INVITATION_CODE_CODE(
      400,
      "FAILED_TO_UPDATE_INVITATION_CODE_CODE",
      "Failed to update invitation code code"),
  FAILED_TO_UPDATE_INVITATION_CODE_USED(
      400,
      "FAILED_TO_UPDATE_INVITATION_CODE_USED",
      "Failed to update invitation code used"),
  FAILED_TO_UPDATE_OFFLINE(
      400, "FAILED_TO_UPDATE_OFFLINE", "Failed to update offline"),
  FAILED_TO_UPDATE_ONLINE(
      400, "FAILED_TO_UPDATE_ONLINE", "Failed to update online"),
  FAILED_TO_UPDATE_PASSWORD(
      400, "FAILED_TO_UPDATE_PASSWORD", "Failed to update password"),
  FAILED_TO_UPDATE_PASSWORD_BY_EMAIL(400, "FAILED_TO_UPDATE_PASSWORD_BY_EMAIL",
      "Failed to reset password by email"),
  FAILED_TO_UPDATE_PASSWORD_BY_PHONE(400, "FAILED_TO_UPDATE_PASSWORD_BY_PHONE",
      "Failed to reset password by phone"),
  FAILED_TO_UPDATE_PHONE(
      400, "FAILED_TO_UPDATE_PHONE", "Failed to update phone"),
  FAILED_TO_UPDATE_PROFILE(
      400, "FAILED_TO_UPDATE_PROFILE", "Failed to update profile"),
  FAILED_TO_UPDATE_TENANT_NAME(
      400, "FAILED_TO_UPDATE_TENANT_NAME", "Failed to update tenant name"),
  FAILED_TO_UPDATE_TURMS_USER(
      400, "FAILED_TO_UPDATE_TURMS_USER", "Failed to update turms user"),
  FAILED_TO_UPDATE_USER(400, "FAILED_TO_UPDATE_USER", "Failed to update user"),
  FAILED_TO_VALIDATE_CUSTOMER_SERVICE_STATUS(
      400,
      "FAILED_TO_VALIDATE_CUSTOMER_SERVICE_STATUS",
      "Failed to validate customer service status"),
  FAILED_TO_VALIDATE_DEVICE_ID(
      400, "FAILED_TO_VALIDATE_DEVICE_ID", "Failed to validate device id"),
  FAILED_TO_VALIDATE_DEVICE_MODEL(400, "FAILED_TO_VALIDATE_DEVICE_MODEL",
      "Failed to validate device model"),
  FAILED_TO_VALIDATE_DEVICE_TOKEN(400, "FAILED_TO_VALIDATE_DEVICE_TOKEN",
      "Failed to validate device token"),
  FAILED_TO_VALIDATE_DEVICE_TYPE(
      400, "FAILED_TO_VALIDATE_DEVICE_TYPE", "Failed to validate device type"),
  FAILED_TO_VALIDATE_EMAIL(
      400, "FAILED_TO_VALIDATE_EMAIL", "Failed to validate email"),
  FAILED_TO_VALIDATE_EMAIL_TYPE(
      400, "FAILED_TO_VALIDATE_EMAIL_TYPE", "Failed to validate email type"),
  FAILED_TO_VALIDATE_FEEDBACK_CATEGORY(
      400,
      "FAILED_TO_VALIDATE_FEEDBACK_CATEGORY",
      "Failed to validate feedback category"),
  FAILED_TO_VALIDATE_FEEDBACK_MESSAGE(
      400,
      "FAILED_TO_VALIDATE_FEEDBACK_MESSAGE",
      "Failed to validate feedback message"),
  FAILED_TO_VALIDATE_ID(400, "FAILED_TO_VALIDATE_ID", "Failed to validate id"),
  FAILED_TO_VALIDATE_INVITATION_CODE(400, "FAILED_TO_VALIDATE_INVITATION_CODE",
      "Failed to validate invitation code"),
  FAILED_TO_VALIDATE_INVITATION_CODE_CODE(
      400,
      "FAILED_TO_VALIDATE_INVITATION_CODE_CODE",
      "Failed to validate invitation code code"),
  FAILED_TO_VALIDATE_INVITATION_CODE_ID(
      400,
      "FAILED_TO_VALIDATE_INVITATION_CODE_ID",
      "Failed to validate invitation code id"),
  FAILED_TO_VALIDATE_NAME(
      400, "FAILED_TO_VALIDATE_NAME", "Failed to validate name"),
  FAILED_TO_VALIDATE_NEW_PASSWORD(400, "FAILED_TO_VALIDATE_NEW_PASSWORD",
      "Failed to validate new password"),
  FAILED_TO_VALIDATE_OTP(
      400, "FAILED_TO_VALIDATE_OTP", "Failed to validate OTP"),
  FAILED_TO_VALIDATE_OTP_TYPE(
      400, "FAILED_TO_VALIDATE_OTP_TYPE", "Failed to validate OTP type"),
  FAILED_TO_VALIDATE_PASSWORD(
      400, "FAILED_TO_VALIDATE_PASSWORD", "Failed to validate password"),
  FAILED_TO_VALIDATE_PHONE(
      400, "FAILED_TO_VALIDATE_PHONE", "Failed to validate phone"),
  FAILED_TO_VALIDATE_STATUS(
      400, "FAILED_TO_VALIDATE_STATUS", "Failed to validate status"),
  FAILED_TO_VALIDATE_SUPER_ADMIN(
      400, "FAILED_TO_VALIDATE_SUPER_ADMIN", "Failed to validate super admin"),
  FAILED_TO_VALIDATE_TENANT_ID(
      400, "FAILED_TO_VALIDATE_TENANT_ID", "Failed to validate tenant id"),
  FAILED_TO_VALIDATE_TENANT_NAME(
      400, "FAILED_TO_VALIDATE_TENANT_NAME", "Failed to validate tenant name"),
  FAILED_TO_VALIDATE_USERNAME(
      400, "FAILED_TO_VALIDATE_USERNAME", "Failed to validate username"),
  FAILED_TO_VERIFY_PASSWORD(
      400, "FAILED_TO_VERIFY_PASSWORD", "Failed to verify password"),
  FAILED_TO_VERIFY_VALIDITY_OF_TOKEN(400, "FAILED_TO_VERIFY_VALIDITY_OF_TOKEN",
      "Failed to verify validity of token"),
  GETSTREAM_APIKEY_CANNOT_BE_NULL(400, "GETSTREAM_APIKEY_CANNOT_BE_NULL",
      "GetStream API Key cannot be null"),
  GETSTREAM_APPSECRET_CANNOT_BE_NULL(400, "GETSTREAM_APPSECRET_CANNOT_BE_NULL",
      "GetStream APP Secret cannot be null"),
  INVITATION_CODE_CANNOT_BE_NULL(
      400, "INVITATION_CODE_CANNOT_BE_NULL", "Invitation code cannot be null"),
  INVITATION_CODE_ID_CANNOT_BE_NULL(400, "INVITATION_CODE_ID_CANNOT_BE_NULL",
      "Invitation code id cannot be null"),
  INVITATION_CODE_IS_FULLY_CLAIM(
      400, "INVITATION_CODE_IS_FULLY_CLAIM", "Invitation code is fully claim"),
  INVITATION_CODE_IS_INVALID(
      400, "INVITATION_CODE_IS_INVALID", "Invitation code is invalid"),
  INVITATION_CODE_IS_UNAVAILABLE(
      400, "INVITATION_CODE_IS_UNAVAILABLE", "Invitation code is unavailable"),
  INVITATION_CODE_MAX_CANNOT_BE_NULL(400, "INVITATION_CODE_MAX_CANNOT_BE_NULL",
      "Invitation code max cannot be null"),
  INVITATION_CODE_MAX_MUST_BE_GREATER_THAN_USED(
      400,
      "INVITATION_CODE_MAX_MUST_BE_GREATER_THAN_USED",
      "Invitation code max must be greater than used"),
  ID_CANNOT_BE_NULL(400, "ID_CANNOT_BE_NULL", "Id cannot be null"),
  ID_IS_INVALID(400, "ID_IS_INVALID", "Id is invalid"),
  IP_CANNOT_BE_NULL(400, "IP_CANNOT_BE_NULL", "IP cannot be null"),
  IP_FORMAT_IS_INVALID(400, "IP_FORMAT_IS_INVALID", "IP format is invalid"),
  IP_IS_UNAVAILABLE(400, "IP_IS_UNAVAILABLE", "IP is unavailable"),
  LANGUAGE_CANNOT_BE_NULL(
      400, "LANGUAGE_CANNOT_BE_NULL", "Language cannot be null"),
  MAX_CANNOT_BE_NULL(400, "MAX_CANNOT_BE_NULL", "Max cannot be null"),
  MESSAGE_CANNOT_BE_NULL(
      400, "MESSAGE_CANNOT_BE_NULL", "Message cannot be null"),
  NAME_CANNOT_BE_NULL(400, "NAME_CANNOT_BE_NULL", "Name cannot be null"),
  NAME_FORMAT_IS_INVALID(
      400, "NAME_FORMAT_IS_INVALID", "Name format is invalid"),
  NAME_IS_BANNED(400, "NAME_IS_BANNED", "Name is banned"),
  NAME_IS_UNAVAILABLE(400, "NAME_IS_UNAVAILABLE", "Name is unavailable"),
  NEW_PASSWORD_CANNOT_BE_NULL(
      400, "NEW_PASSWORD_CANNOT_BE_NULL", "New Password cannot be null"),
  NEW_PASSWORD_FORMAT_IS_INVALID(
      400, "NEW_PASSWORD_FORMAT_IS_INVALID", "New Password format is invalid"),
  NEW_PASSWORD_IS_INVALID(
      400, "NEW_PASSWORD_IS_INVALID", "Password is invalid"),
  OK(200, "OK", "OK"),
  OTP_CANNOT_BE_NULL(400, "OTP_CANNOT_BE_NULL", "OTP cannot be null"),
  OTP_FORMAT_IS_INVALID(400, "OTP_FORMAT_IS_INVALID", "OTP format is invalid"),
  OTP_IS_INVALID(400, "OTP_IS_INVALID", "OTP is invalid"),
  OTP_NOT_FOUND(400, "OTP_NOT_FOUND", "OTP not found"),
  PASSWORD_CANNOT_BE_NULL(
      400, "PASSWORD_CANNOT_BE_NULL", "Password cannot be null"),
  PASSWORD_FORMAT_IS_INVALID(
      400, "PASSWORD_FORMAT_IS_INVALID", "Password format is invalid"),
  PASSWORD_IS_INVALID(400, "PASSWORD_IS_INVALID", "Password is invalid"),
  PATH_CANNOT_BE_NULL(400, "PATH_CANNOT_BE_NULL", "Path cannot be null"),
  PATH_FORMAT_IS_INVALID(
      400, "PATH_FORMAT_IS_INVALID", "Path format is invalid"),
  PATH_IS_UNAVAILABLE(400, "PATH_IS_UNAVAILABLE", "Path is unavailable"),
  PHONE_CANNOT_BE_NULL(400, "PHONE_CANNOT_BE_NULL", "Phone cannot be null"),
  PHONE_FORMAT_IS_INVALID(
      400, "PHONE_FORMAT_IS_INVALID", "Phone format is invalid"),
  PHONE_IS_INVALID(400, "PHONE_IS_INVALID", "Phone is invalid"),
  PHONE_IS_UNAVAILABLE(400, "PHONE_IS_UNAVAILABLE", "Phone is unavailable"),
  POLICY_TYPE_IS_INVALID(
      400, "POLICY_TYPE_IS_INVALID", "Policy type is invalid"),
  POLICY_VERSION_IS_INVALID(
      400, "POLICY_VERSION_IS_INVALID", "Policy version is invalid"),
  TENANT_ID_CANNOT_BE_NULL(
      400, "TENANT_ID_CANNOT_BE_NULL", "Tenant id cannot be null"),
  TENANT_ID_IS_INVALID(400, "TENANT_ID_IS_INVALID", "Tenant id is invalid"),
  TENANT_NAME_CANNOT_BE_NULL(
      400, "TENANT_NAME_CANNOT_BE_NULL", "Tenant id cannot be null"),
  TENANT_NAME_IS_INVALID(400, "TENANT_NAME_IS_INVALID", "Tenant id is invalid"),
  TENANT_NOT_FOUND(400, "TENANT_NOT_FOUND", "Tenant not found"),
  TENANT_SERVICE_MAP_NOT_FOUND(
      400, "TENANT_SERVICE_MAP_NOT_FOUND", "Tenant service map not found"),
  TENANT_SERVICE_NOT_FOUND(
      400, "TENANT_SERVICE_NOT_FOUND", "Tenant service {} not found"),
  TENANT_SERVICE_URL_CANNOT_BE_NULL(400, "TENANT_SERVICE_URL_CANNOT_BE_NULL",
      "Tenant service url cannot be null"),
  TENANT_SERVICE_URL_IS_NULL(
      400, "TENANT_SERVICE_URL_IS_NULL", "Tenant service url {} is null"),
  TYPE_CANNOT_BE_NULL(400, "TYPE_CANNOT_BE_NULL", "Type cannot be null"),
  TYPE_IS_INVALID(400, "TYPE_IS_INVALID", "Type is invalid"),
  STATUS_CANNOT_BE_NULL(400, "STATUS_CANNOT_BE_NULL", "Status cannot be null"),
  STATUS_IS_DELETED(400, "STATUS_IS_DELETED", "Status is deleted"),
  STATUS_IS_INVALID(400, "STATUS_IS_INVALID", "Status is invalid"),
  STATUS_IS_INACTIVE(400, "STATUS_IS_INACTIVE", "Status is inactive"),
  UNAUTHORIZED_ACCESS(
      400, "UNAUTHORIZED_ACCESS", "You are not authorized to access this API"),
  UNKNOWN_ERROR(400, "UNKNOWN_ERROR", "Unknown error"),
  URL_CANNOT_BE_NULL(400, "URL_CANNOT_BE_NULL", "URL cannot be null"),
  URL_FORMAT_IS_INVALID(400, "URL_FORMAT_IS_INVALID", "URL format is invalid"),
  URL_IS_UNAVAILABLE(400, "URL_IS_UNAVAILABLE", "URL is unavailable"),
  USED_CANNOT_BE_NULL(400, "USED_CANNOT_BE_NULL", "Used cannot be null"),
  USER_IS_DELETED(400, "USER_IS_DELETED", "User is deleted"),
  USER_IS_INACTIVE(400, "USER_IS_INACTIVE", "User is inactive"),
  USER_IS_INVALID(400, "USER_IS_INVALID", "User is invalid"),
  USERNAME_CANNOT_BE_NULL(
      400, "USERNAME_CANNOT_BE_NULL", "Username cannot be null"),
  USERNAME_FORMAT_IS_INVALID(
      400, "USERNAME_FORMAT_IS_INVALID", "Username format is invalid"),
  USERNAME_IS_UNAVAILABLE(
      400, "USERNAME_IS_UNAVAILABLE", "Username is unavailable");

  final int statusCode;
  final String errorCode;
  final String errorMsg;

  const StatusCode(this.statusCode, this.errorCode, this.errorMsg);

  @override
  String toString() {
    return 'ErrorType(statusCode: $statusCode, errorCode: $errorCode, description: $errorMsg)';
  }

  static void checkErrorCode(String errorCode, Function(String? errorMsg) callback) {
    final statusCode = StatusCode.values
        .firstWhereOrNull((element) => element.errorCode == errorCode);

    callback(statusCode?.errorMsg);
  }
}
