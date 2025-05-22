import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:event_app/lang/app_localizations.dart';
import 'package:event_app/partial/logo.dart';
import 'package:event_app/providers/appbar_provider.dart';
import 'package:event_app/providers/locale_provider.dart';
import 'package:event_app/providers/theme_provider.dart';

import '../providers/route_provider.dart';
import '../providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Hàm chuyển đổi URL
String convertLocalhostUrl(String url) {
  if (url.contains('localhost')) {
    return url.replaceAll('localhost', '10.0.2.2');
  }
  if (url.contains('127.0.0.1')) {
    return url.replaceAll('127.0.0.1', '10.0.2.2');
  }
  return url;
}

class CustomAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  final double screenWidth;
  final Function(String) onSearch; // Hàm callback xử lý tìm kiếm

  const CustomAppBar(
      {Key? key, required this.screenWidth, required this.onSearch})
      : super(key: key);

  @override
  ConsumerState<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(screenWidth > 750 ? 80.0 : 60.0);
}

class _CustomAppBarState extends ConsumerState<CustomAppBar> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged(String query) {
    // Hủy timer cũ nếu có
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Tạo timer mới
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      widget.onSearch(query);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarState = ref.watch(appBarProvider);

    final theme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final isDarkMode = theme.themeMode == ThemeMode.dark;
    final localeNotifier = ref.read(localeProvider.notifier);
    final title = AppLocalizations.of(context)
        .translate(appBarState.appTitle ?? 'default_title');
    final subtitle = AppLocalizations.of(context)
        .translate(appBarState.subtitle ?? 'default_subtitle');
    final routeState = ref.watch(routeProvider);
    return AppBar(
      toolbarHeight: widget.screenWidth > 750 ? 80.0 : 60.0,
      title: _isSearching
          ? AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: MediaQuery.of(context).size.width * 0.7,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.pink),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none, // Ẩn viền mặc định
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            )
          : Row(
              children: [
                (routeState.currentRoute != '/')
                    ? GestureDetector(
                        onTap: () {
                          // Chuyển về trang chủ khi bấm vào icon
                          final routeNotifier =
                              ref.read(routeProvider.notifier);
                          routeNotifier.updateRoute('/');
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/', (route) => false);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.primaryColor
                                .withOpacity(0.1), // Nền với màu nhạt
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                                offset:
                                    const Offset(0, 3), // Đổ bóng xuống dưới
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.home,
                            color: theme.primaryColor,
                            size: 28,
                          ),
                        ),
                      )
                    : Container(),
                LogoWidget(
                  primaryTitle: title,
                  subTitle: subtitle,
                  primaryColor: theme.primaryColor,
                  textHead1Color: theme.primaryColor,
                  width: widget.screenWidth > 750 ? 80.0 : 60.0,
                  font_size: 20,
                ),
              ],
            ),
      actions: [
        // Kiểm tra kích thước màn hình
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                widget.onSearch(''); // Xóa kết quả tìm kiếm khi đóng tìm kiếm
              }
            });
          },
        ),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (widget.screenWidth > 750) {
              // Màn hình rộng, hiển thị icon trực tiếp
              return Row(
                children: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.language),
                    tooltip: '',
                    onSelected: (String value) {
                      // Cập nhật ngôn ngữ trong Riverpod hoặc setState
                      if (value == 'en') {
                        localeNotifier.setLocale(const Locale('en', ''));
                      } else if (value == 'vi') {
                        localeNotifier.setLocale(const Locale('vi', ''));
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                          value: 'en',
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/svg/en.svg', // Đường dẫn file SVG Tiếng Việt
                                width: 16,
                                height: 16,
                              ),
                              const SizedBox(width: 10),
                              Text('English'),
                            ],
                          )),
                      PopupMenuItem(
                          value: 'vi',
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/svg/vi.svg', // Đường dẫn file SVG Tiếng Việt
                                width: 16,
                                height: 16,
                              ),
                              const SizedBox(width: 10),
                              Text('Tiếng Việt'),
                            ],
                          )),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    tooltip: 'Chuyển đổi chế độ sáng/tối',
                    onPressed: () {
                      themeNotifier.toggleTheme();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.color_lens),
                    tooltip: 'Đổi màu giao diện',
                    onPressed: () {
                      // TODO: Implement theme color change
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.alarm),
                    tooltip: 'Nhắc nhở',
                    onPressed: () {
                      print('Nhắc nhở được chọn');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.monitor_weight),
                    tooltip: 'Tính BMI',
                    onPressed: () {
                      print('Tính BMI được chọn');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    tooltip: 'Thông báo',
                    onPressed: () {
                      print('Clicked on Notifications');
                    },
                  ),
                ],
              );
            } else {
              // Màn hình hẹp, gom lại thành menu
              return Row(
                children: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (String value) {
                      switch (value) {
                        case 'ToggleDarkMode':
                          themeNotifier.toggleTheme();
                          break;
                        case 'ChangeColor':
                          // TODO: Implement theme color change
                          break;
                        case 'Reminder':
                          print('Nhắc nhở được chọn');
                          break;
                        case 'BMI':
                          print('Tính BMI được chọn');
                          break;
                        case 'Notification':
                          print('Thông báo');
                          break;
                        case 'en':
                          localeNotifier.setLocale(const Locale('en', ''));
                        case 'vi':
                          localeNotifier.setLocale(const Locale('vi', ''));
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'ToggleDarkMode',
                        child: Row(
                          children: [
                            Icon(
                              isDarkMode ? Icons.light_mode : Icons.dark_mode,
                              color: theme.primaryColor,
                            ),
                            const SizedBox(width: 10),
                            Text(isDarkMode ? 'Chế độ Sáng' : 'Chế độ Tối'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'ChangeColor',
                        child: Row(
                          children: [
                            Icon(Icons.color_lens, color: theme.primaryColor),
                            const SizedBox(width: 10),
                            const Text('Đổi màu giao diện'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'Reminder',
                        child: Row(
                          children: [
                            Icon(Icons.alarm, color: theme.primaryColor),
                            const SizedBox(width: 10),
                            const Text('Nhắc nhở'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'BMI',
                        child: Row(
                          children: [
                            Icon(Icons.monitor_weight,
                                color: theme.primaryColor),
                            const SizedBox(width: 10),
                            const Text('Tính BMI'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'Notification',
                        child: Row(
                          children: [
                            Icon(Icons.color_lens, color: theme.primaryColor),
                            const SizedBox(width: 10),
                            const Text('Thông báo'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'en',
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/svg/en.svg', // Đường dẫn file SVG English
                              width: 10,
                              height: 12,
                            ),
                            const SizedBox(width: 10),
                            const Text('English'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'vi',
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/svg/vi.svg', // Đường dẫn file SVG Tiếng Việt
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(width: 10),
                            const Text('Tiếng Việt'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
        // Avatar người dùng
        AvatarWithNotification()
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        widget.screenWidth > 750 ? 80.0 : 60.0,
      );
}

class AvatarWithNotification extends ConsumerWidget {
  const AvatarWithNotification({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider); // Lấy thông tin người dùng
    final hasNotification =
        user != null; // Giả lập: Có thông báo nếu đã đăng nhập
    final routeState = ref.watch(routeProvider);
    final routeNotifier = ref.read(routeProvider.notifier);
    return Stack(
      clipBehavior: Clip.none, // Hiển thị widget ngoài phạm vi
      children: [
        IconButton(
          icon: CircleAvatar(
            radius: 20,
            backgroundImage: user?.photo != null
                ? NetworkImage(
                    convertLocalhostUrl(user!.photo!)) // Hình tải từ internet
                : const AssetImage('assets/listen.png')
                    as ImageProvider, // Hình mặc định
          ),
          tooltip: user != null ? 'Hồ sơ của tôi' : 'Mời đăng nhập',
          onPressed: () async {
            if (user != null) {
              if (routeState.currentRoute != '/myspace') {
                routeNotifier.updateRoute('/myspace');
                Navigator.pushReplacementNamed(context, '/myspace');
              }
            } else {
              if (routeState.currentRoute != '/login') {
                routeNotifier.updateRoute('/login');
                Navigator.pushNamed(context, '/login');
              }
            }

            SharedPreferences prefs = await SharedPreferences.getInstance();
            print('isLoggedIn: ${prefs.getBool('isLoggedIn')}');
            print('token: ${prefs.getString('token')}');
            print('role: ${prefs.getString('role')}');

            await prefs.setBool('isLoggedIn', true);
            await prefs.setString('token', prefs.getString('token') ?? '');
            await prefs.setString('role', prefs.getString('role') ?? '');

            print('Current route: ${ModalRoute.of(context)?.settings.name}');
            print('Navigation stack: ${Navigator.of(context).widget.pages}');
          },
        ),
        if (hasNotification) // Hiển thị thông báo nếu đã đăng nhập
          Positioned(
            right: 4, // Đặt thông báo bên phải avatar
            top: 4, // Đặt thông báo ở phía trên avatar
            child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(user!.notification_count)),
          ),
      ],
    );
  }
}
