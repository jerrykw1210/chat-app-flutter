import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protech_mobile_chat_stream/constants/storagekey_constants.dart';
import 'package:protech_mobile_chat_stream/module/language/model/language_model.dart';
import 'package:protech_mobile_chat_stream/module/language/repository/language_repository.dart';
import 'package:protech_mobile_chat_stream/service/response.dart';
import 'package:protech_mobile_chat_stream/utils/helper.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  final LanguageRepository languageRepository = sl<LanguageRepository>();
  LanguageCubit() : super(const LanguageState());
  void updateSupportedLocales(BuildContext context) {
    // If state.languages is empty or differs from context.supportedLocales
    if (state.languages.isEmpty ||
        state.languages == context.supportedLocales) {
      // Update state.languages with context.supportedLocales
      emit(state.copyWith(languages: context.supportedLocales.toList()));
    }
  }

  /// Downloads the language pack for the specified [langCode] and returns the
  /// language translations as a Map.
  ///
  /// If the language pack is already downloaded, the function will return the
  /// existing translations. Otherwise, it will download the language pack from
  /// the server and save it to the app's document directory.
  ///
  /// The function returns a Map containing the language translations, with the
  /// keys being the original English strings and the values being the translated
  /// strings in the specified language.
  ///
  /// If the download fails, the function will throw an exception.
  ///
  /// Note: This function is for testing purposes only, and should be replaced
  /// with a real API call to download the language pack from the server.
  ///
  Future<void> downloadLanguagePack(String fileName) async {
    final filePath = '${Helper.directory?.path}/$fileName';
    log("file path $filePath");
    final file = File(filePath);
    Dio dio = Dio();
    if (await file.exists()) {
      String jsonContent = await file.readAsString();
      log("file exist ${json.decode(jsonContent)}");
      emit(state.copyWith(
        downloadLanguageStatus: DownloadLanguageStatus.downloaded,
      ));
      return;
    } else {
      final res = await languageRepository.getLanguageFile(fileName);
      if (res is MapSuccessResponse) {
        emit(state.copyWith(
          downloadLanguageStatus: DownloadLanguageStatus.downloading,
        ));
        File(filePath).writeAsStringSync(jsonEncode(res.jsonRes));
        emit(state.copyWith(
            downloadLanguageStatus: DownloadLanguageStatus.downloaded,
            languageCode: fileName
                .split('.json')
                .first)); // String jsonContent = await file.readAsString();
        // log("language decode ${json.decode(jsonContent)}");

        // return json.decode(jsonContent);
      }

      //sample JSON (for testing purpose only)

      // save JSON to a file (for testing purpose only, use dio after getting api from backend)

      // dio.download("urlPath", filePath, onReceiveProgress: (rcv, total) {
      //   log('received: ${rcv.toStringAsFixed(0)} out of total: ${total.toStringAsFixed(0)}');
      //   emit(state.copyWith(
      //     downloadLanguageStatus: DownloadLanguageStatus.downloading,
      //   ));
      // }, deleteOnError: true).then((res) async {
      //   emit(state.copyWith(
      //     downloadLanguageStatus: DownloadLanguageStatus.downloaded,
      //   ));
      //   String jsonContent = await file.readAsString();
      //   return json.decode(jsonContent);
      // });
    }
  }

  Future<void> getLanguageFile(String path) async {
    try {
      final res = await languageRepository.getLanguageFile(path);
      if (res is MapSuccessResponse) {
        log("language file ${res.jsonRes}");
      }
    } catch (e) {
      log("get langugage error $e");
    }
  }

  Future<void> getLanguageList() async {
    try {
      final res = await languageRepository.getLanguageList();
      if (res is MapSuccessResponse) {
        List<Language> languageList =
            LanguageModel.fromJson(res.jsonRes['data'])
                .languageList
                .where((lang) => lang.status.name == "ACTIVE")
                .toList();

        final FlutterSecureStorage storage = sl<FlutterSecureStorage>();
        final storedCodes =
            await storage.read(key: StoragekeyConstants.languageKey);
        final languageCodes = storedCodes != null
            ? List<String>.from(jsonDecode(storedCodes))
            : <String>[];

        final newLangCodes = languageList
            .map((lang) => lang.code)
            .where((code) => !languageCodes.contains(code))
            .toList();

        if (newLangCodes.isNotEmpty) {
          languageCodes.addAll(newLangCodes);
          await storage.write(
            key: StoragekeyConstants.languageKey,
            value: jsonEncode(languageCodes),
          );
        }

        emit(state.copyWith(languageList: languageList));
        log("language list $languageList");
      }
    } catch (e) {
      log("get language list error $e");
    }
  }

  void resetLanguageStatus() {
    emit(state.copyWith(
        downloadLanguageStatus: DownloadLanguageStatus.initial,
        languageStatus: LanguageStatus.initial,
        languageCode: null));
  }
}
