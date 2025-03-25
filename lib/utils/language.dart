import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';

class LanguageClass extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    try {
      final filePath =
          '$path/${locale.languageCode}-${locale.countryCode?.toLowerCase()}.json';
      final file = File(filePath);
      log("message file path $filePath");
      if (await file.exists()) {
        log("file language exost");
        String jsonContent = await file.readAsString();
        return json.decode(jsonContent)['mobile'];
      } else {
        return {};
        // return dio.download(
        //     "https://ohio.stream-io-cdn.com/1338860/attachments/f2b200b2-ac0e-4372-9097-79b4c3035279.ms.json?Key-Pair-Id=APKAIHG36VEWPDULE23Q&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9vaGlvLnN0cmVhbS1pby1jZG4uY29tLzEzMzg4NjAvYXR0YWNobWVudHMvZjJiMjAwYjItYWMwZS00MzcyLTkwOTctNzliNGMzMDM1Mjc5Lm1zLmpzb24qIiwiQ29uZGl0aW9uIjp7IkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNzMwMTg3ODAzfX19XX0_&Signature=YntqvLJObzKl7PTtRrfQSU8QeMs~c5KPOqzZC4hh34UYXTPZBqHE1o6LFS35gO4~itG9qP8E17Nny2ZJiyHyHCuCrfWkm35hj2blFeHpoCp~2eNdBO9SiYtlRVQUCxjHgA0a5CGyjhKqlXqwuut82uW0YP~qk3jZ-8phS1Cq1IljhM~zj97zZ792t96v3MbUXWzTH8q8NiUjkTfYN220XgvnPJuVkaXgXADoZInJ8NmDc5sqeLl6oROeYLWCMYJy6KV4tgi4byxjvgF14Ch2R5oL-Gw-lPwXUpVHy2DfK039qFhknDetp2viNtdX2Yl06puXIZzaLkuig1gzRxMhOA__",
        //     filePath, onReceiveProgress: (rcv, total) {
        //   log('received: ${rcv.toStringAsFixed(0)} out of total: ${total.toStringAsFixed(0)}');
        // }, deleteOnError: true).then((res) async {
        //   log("path language ${res.data}");

        //   String jsonContent = await file.readAsString();
        //   log("json content language ${jsonDecode(jsonContent)}");
        //   return json.decode(jsonContent);
        // });
      }
      // final url =
      //     '$translationBaseUrl/${locale.languageCode}-${locale.countryCode}.json';
      // return Dio()
      //     .get(url)
      //     .then((response) => jsonDecode(response.data.toString()));
    } catch (e) {
      log("error language $e");
      return {};
    }
  }
}
