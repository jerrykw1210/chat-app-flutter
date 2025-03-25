import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:protech_mobile_chat_stream/constants/storagekey_constants.dart';
import 'package:protech_mobile_chat_stream/utils/bottom_sheet_manager.dart';
import 'package:protech_mobile_chat_stream/utils/colors.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewScreen extends StatefulWidget {
  const WebviewScreen({super.key});

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen>
    with AutomaticKeepAliveClientMixin {
  late final WebViewController _controller;
  final TextEditingController _urlController = TextEditingController();
  bool isDoneLoading = false;
  String finishedUrl = "";
  final FocusNode _focusNode = FocusNode();
  bool _isTextFieldFocused = false;
  final storage = sl<GetStorage>();

  bool isMinimized = false;

  @override
  bool get wantKeepAlive => true;

  void _navigateToUrl(String url) {
    if (url.isEmpty) return;

    final Uri? parsedUri = Uri.tryParse(url);
    if (parsedUri == null ||
        (!parsedUri.hasScheme && !parsedUri.host.isNotEmpty)) {
      url = 'https://www.google.com/search?q=$url';
    }

    _controller.loadRequest(Uri.parse(url));
  }

  Future<void> writeHistory(
      {required String url,
      required DateTime timestamp,
      required String name}) async {
    String keys = StoragekeyConstants.browserHistoryKey;
    final history = storage.read(keys);

    Map<String, dynamic> newHistory = {};
    newHistory["timestamp"] = timestamp.toIso8601String();
    newHistory["url"] = url;
    newHistory["name"] = name;

    if (history == null) {
      List<Map<String, dynamic>> historyList = [];
      historyList.add(newHistory);
      storage.write(keys, jsonEncode(historyList));
      return;
    }

    List<dynamic> historyList = jsonDecode(history);
    historyList.add(newHistory);
    storage.write(keys, jsonEncode(historyList));
    return;
  }

  Future<String> lastHistory() async {
    String keys = StoragekeyConstants.browserHistoryKey;
    final history = await storage.read(keys);

    if (history == null) {
      return "https://google.com";
    }

    final historyList = jsonDecode(history);

    if ((historyList as List).isEmpty) {
      return "https://google.com";
    }

    return (historyList).last["url"];
  }

  bool isFABVisible = true; // Tracks FAB visibility
  Offset fabPosition = const Offset(20, 20); // Initial position of the FAB

  Future<void> writeBookmark(
      {required String url,
      required DateTime timestamp,
      required String name}) async {
    String keys = StoragekeyConstants.browserBookmarkKey;
    final bookmarks = storage.read(keys);

    Map<String, dynamic> newBookmark = {};
    newBookmark["name"] = name;
    newBookmark["timestamp"] = timestamp.toIso8601String();
    newBookmark["url"] = url;

    if (bookmarks == null) {
      List<Map<String, dynamic>> bookmarkList = [];
      bookmarkList.add(newBookmark);
      storage.write(keys, jsonEncode(bookmarkList));
      return;
    }

    List<dynamic> bookmarkList = jsonDecode(bookmarks);
    final existBookmark = bookmarkList
        .firstWhere((bookmark) => bookmark["url"] == url, orElse: () => null);

    if (existBookmark != null) {
      log("bookmark exist");
      return;
    }

    bookmarkList.add(newBookmark);
    storage.write(keys, jsonEncode(bookmarkList));
    return;
  }

  Future<void> _addToBookmark(BuildContext context) async {
    String url = await _controller.currentUrl() ?? "";
    DateTime timestamp = DateTime.now();
    if (url.isNotEmpty) {
      String name = await _controller.getTitle() ?? "";
      writeBookmark(url: url, timestamp: timestamp, name: name);
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isTextFieldFocused = _focusNode.hasFocus;
      });
    });
    late final PlatformWebViewControllerCreationParams params;
    // if (WebViewPlatform.instance is WebKitWebViewPlatform) {
    //   params = WebKitWebViewControllerCreationParams(
    //     allowsInlineMediaPlayback: true,
    //     mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
    //   );
    // } else {
    //   params = const PlatformWebViewControllerCreationParams();
    // }
    // _controller = WebViewController.fromPlatformCreationParams(params);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(onProgress: (int progress) {
          log("Web view is loading $progress%");
        }, onPageFinished: (String url) async {
          if (finishedUrl != url) {
            String name = await _controller.getTitle() ?? "";
            if (name.trim().isEmpty) {
              name = url;
            }
            writeHistory(url: url, timestamp: DateTime.now(), name: name);
            _urlController.value = TextEditingValue(text: url);

            setState(() {
              isDoneLoading = true;
              finishedUrl = url;
            });
          }
        }, onNavigationRequest: (NavigationRequest request) {
          return NavigationDecision.navigate;
        }, onHttpError: (HttpResponseError error) {
          debugPrint('Error occurred on page: ${error.response?.statusCode}');
        }, onUrlChange: (UrlChange change) {
          debugPrint('url change to ${change.url}');
        }, onWebResourceError: (WebResourceError error) {
          //EasyLoading.dismiss();
          setState(() {
            isDoneLoading = true;
          });
        }
            // onHttpAuthRequest: (HttpAuthRequest request) {
            //   openDialog(request);
            // },
            ),
      );

    _controller.currentUrl().then((url) {
      if (url == null) {
        lastHistory().then((url) {
          _controller.loadRequest(Uri.parse(url));
          return;
        });
        return;
      }

      // _controller.loadRequest(Uri.parse(url));
    });
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    _urlController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorLight,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isTextFieldFocused
                    ? MediaQuery.of(context).size.width
                    : 200, // Full width when focused
                child: TextField(
                    focusNode: _focusNode,
                    controller: _urlController,
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (value) {
                      _navigateToUrl(value);
                    },
                    decoration: const InputDecoration(
                        hintText: 'Enter URL',
                        hintStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false)),
              ),
            ),
          ],
        ),
        actions: _isTextFieldFocused
            ? [
                IconButton(
                  icon: const Icon(Icons.navigate_next),
                  onPressed: () {
                    _navigateToUrl(_urlController.text);
                    _focusNode.unfocus();
                  },
                ),
              ] // No actions when focused
            : [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () async {
                    if (await _controller.canGoBack()) {
                      _controller.goBack();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () async {
                    if (await _controller.canGoForward()) {
                      _controller.goForward();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    _controller.reload();
                    setState(() {
                      finishedUrl = "";
                    });
                  },
                ),
                IconButton(
                    icon: const Icon(Icons.book),
                    onPressed: () => _addToBookmark(context)),
                SampleMenu(webViewController: _controller)
              ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

enum MenuOptions {
  showHistory,
  showUserAgent,
  addToBookmark,
  showBookmarks,
  listCookies,
  clearCookies,
  addToCache,
  listCache,
  clearCache,
  navigationDelegate,
  doPostRequest,
  loadLocalFile,
  loadFlutterAsset,
  loadHtmlString,
  transparentBackground,
  setCookie,
  logExample,
  basicAuthentication,
}

class SampleMenu extends StatelessWidget {
  SampleMenu({
    super.key,
    required this.webViewController,
  });

  final WebViewController webViewController;

  late final WebViewCookieManager cookieManager = WebViewCookieManager();

  final storage = sl<GetStorage>();

  Future<void> clearHistory() async {
    String keys = StoragekeyConstants.browserHistoryKey;
    // final history = storage.read(keys);
    storage.write(keys, jsonEncode([]));
    return;
  }

  Future<void> clearBookmark() async {
    String keys = StoragekeyConstants.browserBookmarkKey;
    // final history = storage.read(keys);
    storage.write(keys, jsonEncode([]));
    return;
  }

  @override
  Widget build(BuildContext context) {
    // return PopupMenuButton<MenuOptions>(
    //   key: const ValueKey<String>('ShowPopupMenu'),
    //   icon: const Icon(Icons.more_vert),
    //   useRootNavigator: true,
    //   position: PopupMenuPosition.over,
    //   onSelected: (MenuOptions value) {
    //     switch (value) {
    //       case MenuOptions.showHistory:
    //         _onShowHistory(context);
    //       case MenuOptions.addToBookmark:
    //         _addToBookmark(context);
    //       case MenuOptions.showBookmarks:
    //         _showBookmark(context);
    //       default:
    //         return;
    //     }
    //   },
    //   itemBuilder: (BuildContext context) => <PopupMenuItem<MenuOptions>>[
    //     const PopupMenuItem<MenuOptions>(
    //       value: MenuOptions.showHistory,
    //       child: Text('Show History'),
    //     ),
    //     const PopupMenuItem<MenuOptions>(
    //       value: MenuOptions.showBookmarks,
    //       child: Text('Show bookmarks'),
    //     ),
    //     const PopupMenuItem<MenuOptions>(
    //       value: MenuOptions.addToBookmark,
    //       child: Text('Add to bookmark'),
    //     ),
    //   ],
    // );
    return MenuAnchor(
        builder:
            (BuildContext context, MenuController controller, Widget? widget) {
          return IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
          );
        },
        menuChildren: [
          MenuItemButton(
            onPressed: () {
              _onShowHistory(context);
            },
            child: const Text("Show History"),
          ),
          MenuItemButton(
            onPressed: () {
              _showBookmark(context);
            },
            child: const Text("Show Bookmarks"),
          ),
          MenuItemButton(
            onPressed: () {
              _addToBookmark(context);
            },
            child: const Text("Add to Bookmark"),
          ),
        ]);
  }

  bool isSpecialCharacter(String text) {
    return RegExp(r'[!@#$%^&*()_+{}\[\]:;<>,.?~]').hasMatch(text);
  }

  bool isSameDay(DateTime dateA, DateTime dateB) {
    return dateA.year == dateB.year &&
        dateA.month == dateB.month &&
        dateA.day == dateB.day;
  }

  Future<void> writeBookmark(
      {required String url,
      required DateTime timestamp,
      required String name}) async {
    String keys = StoragekeyConstants.browserBookmarkKey;
    final bookmarks = storage.read(keys);

    Map<String, dynamic> newBookmark = {};
    newBookmark["name"] = name;
    newBookmark["timestamp"] = timestamp.toIso8601String();
    newBookmark["url"] = url;

    if (bookmarks == null) {
      List<Map<String, dynamic>> bookmarkList = [];
      bookmarkList.add(newBookmark);
      storage.write(keys, jsonEncode(bookmarkList));
      return;
    }

    List<dynamic> bookmarkList = jsonDecode(bookmarks);
    final existBookmark = bookmarkList
        .firstWhere((bookmark) => bookmark["url"] == url, orElse: () => null);

    if (existBookmark != null) {
      log("bookmark exist");
      return;
    }

    bookmarkList.add(newBookmark);
    storage.write(keys, jsonEncode(bookmarkList));
    return;
  }

  Future<void> _addToBookmark(BuildContext context) async {
    String url = await webViewController.currentUrl() ?? "";
    DateTime timestamp = DateTime.now();
    if (url.isNotEmpty) {
      String name = await webViewController.getTitle() ?? "";
      writeBookmark(url: url, timestamp: timestamp, name: name);
    }
  }

  Future<void> _showBookmark(BuildContext context) async {
    final storage = sl<GetStorage>();
    String keys = StoragekeyConstants.browserBookmarkKey;
    final bookmarks = storage.read(keys);

    List<dynamic> bookmarkList = [];
    String query = "";

    if (bookmarks != null) {
      bookmarkList = jsonDecode(bookmarks);
    }

    log("browsing history $bookmarks");

    // showModalBottomSheet(
    //     context: NavigationService.navigatorKey.currentContext!,
    //     isScrollControlled: true,
    //     useSafeArea: true,
    //     clipBehavior: Clip.hardEdge,
    //     useRootNavigator: true,
    //     builder: (context) {

    //     });

    BottomSheetManager.showCustomBottomSheet(builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 50,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Expanded(child: SizedBox()),
                  const Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("Bookmark",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Expanded(
                      child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: TextButton(
                          onPressed: () {
                            // Navigator.of(context).pop();
                            BottomSheetManager.close();
                          },
                          child: const Text("Done")),
                    ),
                  ))
                ],
              ),
            ),
            SizedBox(
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: 15, top: 5, left: 15, right: 15),
                child: TextField(
                  style: const TextStyle(fontSize: 13),
                  textAlignVertical: TextAlignVertical.center,
                  onChanged: (value) {
                    setState(() {
                      query = value;
                      if (query.isBlank) {
                        if (bookmarks != null) {
                          bookmarkList = jsonDecode(bookmarks);
                        }
                      }

                      final filteredBookmarkList = bookmarkList.where((data) {
                        return (data["name"] as String)
                            .toLowerCase()
                            .contains(query.toLowerCase());
                      }).toList();

                      bookmarkList = filteredBookmarkList;
                    });
                  },
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 5),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                      fillColor: Color.fromARGB(255, 233, 233, 233),
                      filled: true,
                      label: Text("Search Bookmark"),
                      labelStyle: TextStyle(fontSize: 13),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(10)))),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Stack(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6 - 75,
                        child: bookmarkList.isEmpty
                            ? const Align(
                                alignment: Alignment.center,
                                child: Text("Nothing here yet",
                                    style: TextStyle(color: Colors.black)))
                            : GroupedListView(
                                padding: EdgeInsets.zero,
                                elements: bookmarkList,
                                emptyPlaceholder: const Align(
                                    alignment: Alignment.center,
                                    child: Text("Nothing here yet",
                                        style: TextStyle(color: Colors.black))),
                                groupBy: (bookmark) => DateTime(
                                    DateTime.parse(bookmark["timestamp"]).year,
                                    DateTime.parse(bookmark["timestamp"]).month,
                                    DateTime.parse(bookmark["timestamp"]).day),
                                shrinkWrap: true,
                                order: GroupedListOrder.DESC,
                                groupSeparatorBuilder: (timestamp) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 30),
                                    decoration: const BoxDecoration(
                                        color: AppColor.greyBackgroundColor),
                                    child: Text(
                                        isSameDay(timestamp, DateTime.now())
                                            ? "Today"
                                            : DateFormat('yyyy-MM-dd')
                                                .format(timestamp)),
                                  );
                                },
                                separator: const Divider(thickness: 0.5),
                                itemBuilder: (context, bookmark) {
                                  return GestureDetector(
                                    onTap: () {
                                      webViewController.loadRequest(
                                          Uri.parse(bookmark["url"]));
                                      BottomSheetManager.close();
                                    },
                                    child: ListTile(
                                      dense: true,
                                      visualDensity:
                                          const VisualDensity(vertical: -1),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 28),
                                      title: Text(bookmark["name"]),
                                      subtitle: Text(bookmark["url"],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 75)
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 75,
                      width: MediaQuery.of(context).size.width,
                      color: const Color.fromARGB(255, 219, 219, 219),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: TextButton(
                            onPressed: () {
                              clearBookmark();
                              setState(() => bookmarkList = []);
                            },
                            child: const Text("Clear")),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _onShowHistory(BuildContext context) async {
    final storage = sl<GetStorage>();
    String keys = StoragekeyConstants.browserHistoryKey;
    final history = storage.read(keys);

    List<dynamic> historyList = [];
    String query = "";

    if (history != null) {
      historyList = jsonDecode(history);
    }

    log("browsing history $history");

    // showModalBottomSheet(
    //     context: context,
    //     isScrollControlled: true,
    //     useSafeArea: true,
    //     clipBehavior: Clip.hardEdge,
    //     builder: (context) {
    //       return
    //     });

    BottomSheetManager.showCustomBottomSheet(builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 50,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Expanded(child: SizedBox()),
                  const Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("History",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Expanded(
                      child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: TextButton(
                          onPressed: () {
                            BottomSheetManager.close();
                          },
                          child: const Text("Done")),
                    ),
                  ))
                ],
              ),
            ),
            SizedBox(
              height: 60,
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: 15, top: 5, left: 15, right: 15),
                child: TextField(
                  style: const TextStyle(fontSize: 13),
                  onChanged: (value) {
                    setState(() {
                      query = value;
                      if (query.isBlank) {
                        if (history != null) {
                          historyList = jsonDecode(history);
                        }
                      }

                      final filteredHistoryList = historyList.where((data) {
                        return (data["name"] as String)
                            .toLowerCase()
                            .contains(query.toLowerCase());
                      }).toList();

                      historyList = filteredHistoryList;
                    });
                  },
                  textAlignVertical: TextAlignVertical.center,
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 5),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                      fillColor: Color.fromARGB(255, 233, 233, 233),
                      filled: true,
                      label: Text("Search History"),
                      labelStyle: TextStyle(fontSize: 13),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(10)))),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6 - 75,
                        child: historyList.isEmpty
                            ? const Align(
                                alignment: Alignment.center,
                                child: Text("Nothing here yet",
                                    style: TextStyle(color: Colors.black)))
                            : GroupedListView(
                                padding: EdgeInsets.zero,
                                elements: historyList,
                                emptyPlaceholder: const Align(
                                    alignment: Alignment.center,
                                    child: Text("Nothing here yet",
                                        style: TextStyle(color: Colors.black))),
                                groupBy: (history) => DateTime(
                                    DateTime.parse(history["timestamp"]).year,
                                    DateTime.parse(history["timestamp"]).month,
                                    DateTime.parse(history["timestamp"]).day),
                                shrinkWrap: true,
                                order: GroupedListOrder.DESC,
                                groupSeparatorBuilder: (timestamp) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 30),
                                    decoration: const BoxDecoration(
                                        color: AppColor.greyBackgroundColor),
                                    child: Text(
                                        isSameDay(timestamp, DateTime.now())
                                            ? "Today"
                                            : DateFormat('yyyy-MM-dd')
                                                .format(timestamp)),
                                  );
                                },
                                separator: const Divider(thickness: 0.5),
                                itemBuilder: (context, history) {
                                  return GestureDetector(
                                    onTap: () {
                                      webViewController.loadRequest(
                                          Uri.parse(history["url"]));
                                      BottomSheetManager.close();
                                    },
                                    child: ListTile(
                                      dense: true,
                                      visualDensity:
                                          const VisualDensity(vertical: -1),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 28),
                                      title: Text(history.containsKey("name")
                                          ? history["name"]
                                          : history["url"]),
                                      subtitle: Text(history["url"],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 75)
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 75,
                      width: MediaQuery.of(context).size.width,
                      color: const Color.fromARGB(255, 219, 219, 219),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: TextButton(
                            onPressed: () {
                              clearHistory();
                              setState(() => historyList = []);
                            },
                            child: const Text("Clear")),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _promptForUrl(BuildContext context) {
    final TextEditingController urlTextController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Input URL to visit'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'URL'),
            autofocus: true,
            controller: urlTextController,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (urlTextController.text.isNotEmpty) {
                  final Uri? uri = Uri.tryParse(urlTextController.text);
                  if (uri != null && uri.scheme.isNotEmpty) {
                    webViewController.loadRequest(uri);
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Visit'),
            ),
          ],
        );
      },
    );
  }
}
