part of 'language_cubit.dart';

enum LanguageStatus { initial, loaded, loading, failed }

enum DownloadLanguageStatus { initial, downloaded, downloading, failed }

class LanguageState extends Equatable {
  final LanguageStatus languageStatus;
  final DownloadLanguageStatus downloadLanguageStatus;
  final String languageError;
  final List<Locale> languages;
  final List<Language> languageList;
  final String languageCode;

  const LanguageState({
    this.languageStatus = LanguageStatus.initial,
    this.downloadLanguageStatus = DownloadLanguageStatus.initial,
    this.languageError = "",
    this.languages = const [],
    this.languageList = const [],
    this.languageCode = "",
  });

  LanguageState copyWith(
      {LanguageStatus? languageStatus,
      DownloadLanguageStatus? downloadLanguageStatus,
      String? languageError,
      List<Locale>? languages,
      List<Language>? languageList,
      String? languageCode}) {
    return LanguageState(
      languageStatus: languageStatus ?? this.languageStatus,
      downloadLanguageStatus:
          downloadLanguageStatus ?? this.downloadLanguageStatus,
      languageError: languageError ?? this.languageError,
      languages: languages ?? this.languages,
      languageList: languageList ?? this.languageList,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  @override
  List<Object?> get props =>
      [downloadLanguageStatus, languageStatus, languageError, languages, languageList, languageCode];
}

