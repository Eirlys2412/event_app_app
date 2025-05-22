// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:event_app/models/comment.dart';
// import 'package:event_app/models/user.dart';
// import 'package:event_app/providers/comment_provider.dart';
// import 'package:event_app/providers/user_provider.dart';
// import 'package:event_app/repositories/comment_repository.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class CommentScreen extends ConsumerStatefulWidget {
//   final int blogId;
//   final String itemCode;

//   const CommentScreen({Key? key, required this.blogId, this.itemCode = 'blog'})
//       : super(key: key);

//   @override
//   _CommentScreenState createState() => _CommentScreenState();
// }

// class ImageDetailScreen extends StatelessWidget {
//   final String imageUrl;

//   const ImageDetailScreen({Key? key, required this.imageUrl}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         iconTheme: const IconThemeData(color: Color(0xFFF5E050)),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.download, color: Color(0xFFF5E050)),
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('Tính năng đang phát triển')),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: InteractiveViewer(
//           minScale: 0.5,
//           maxScale: 4.0,
//           child: Hero(
//             tag: imageUrl,
//             child: CachedNetworkImage(
//               imageUrl: imageUrl,
//               fit: BoxFit.contain,
//               placeholder: (context, url) => const Center(
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C4B4)),
//                 ),
//               ),
//               errorWidget: (context, url, error) {
//                 print('Image detail load error: $error');
//                 return Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.error, color: Colors.red, size: 48),
//                     SizedBox(height: 16),
//                     Text(
//                       'Không thể tải ảnh',
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class UserProfileScreen extends StatelessWidget {
//   final User user;

//   const UserProfileScreen({Key? key, required this.user}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Xác định ký tự hiển thị trong avatar
//     String displayInitial =
//         'U'; // Giá trị mặc định nếu cả full_name và username đều rỗng
//     if (user.full_name.isNotEmpty) {
//       displayInitial = user.full_name[0].toUpperCase();
//     } else if (user.username.isNotEmpty) {
//       displayInitial = user.username[0].toUpperCase();
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           user.full_name.isNotEmpty
//               ? user.full_name
//               : user.username.isNotEmpty
//                   ? user.username
//                   : 'Người dùng',
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 24,
//             color: Color(0xFFF5E050),
//           ),
//         ),
//         backgroundColor: const Color(0xFF1A1A2E),
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Color(0xFFF5E050)),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Color(0xFF0F0C29), Color(0xFF302B63)],
//           ),
//         ),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: const Color(0xFFF5E050),
//                     width: 3,
//                   ),
//                 ),
//                 child: CircleAvatar(
//                   radius: 60,
//                   backgroundColor: const Color(0xFF24243E),
//                   child: ClipOval(
//                     child: user.photo.isNotEmpty
//                         ? CachedNetworkImage(
//                             imageUrl: user.photo,
//                             width: 120,
//                             height: 120,
//                             fit: BoxFit.cover,
//                             placeholder: (context, url) =>
//                                 const CircularProgressIndicator(),
//                             errorWidget: (context, url, error) => Text(
//                               displayInitial,
//                               style: const TextStyle(
//                                 color: Color(0xFFF5E050),
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 40,
//                               ),
//                             ),
//                           )
//                         : Text(
//                             displayInitial,
//                             style: const TextStyle(
//                               color: Color(0xFFF5E050),
//                               fontWeight: FontWeight.bold,
//                               fontSize: 40,
//                             ),
//                           ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               _buildProfileInfoTile('Tên đầy đủ', user.full_name),
//               _buildProfileInfoTile('Tên người dùng', user.username),
//               _buildProfileInfoTile('Email', user.email),
//               _buildProfileInfoTile('Số điện thoại', user.phone),
//               _buildProfileInfoTile('Địa chỉ', user.address),
//               _buildProfileInfoTile('Mô tả', user.description),             
//               _buildProfileInfoTile('Tổng điểm', user.totalpoint.toString()),            
//               _buildProfileInfoTile('Trạng thái', user.status),
//               _buildProfileInfoTile('Số thông báo', user.notification_count),
//               _buildProfileInfoTile('Ngày sinh', user.birthday),
//               _buildProfileInfoTile('Giới tính', user.gender),
//               _buildProfileInfoTile('Vai trò', user.role),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileInfoTile(String label, String? value) {
//     if (value == null || value.isEmpty) return const SizedBox.shrink();
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: const Color(0xFF302B63),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: const Color(0xFFF5E050).withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Color(0xFFF5E050),
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Flexible(
//               child: Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: Colors.white,
//                 ),
//                 textAlign: TextAlign.end,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class EmojiPicker extends StatefulWidget {
//   final TextEditingController controller;

//   const EmojiPicker({required this.controller});

//   @override
//   _EmojiPickerState createState() => _EmojiPickerState();
// }

// class _EmojiPickerState extends State<EmojiPicker> {
//   final TextEditingController _searchController = TextEditingController();
//   int _selectedCategory = 0;

//   final List<Map<String, dynamic>> categories = [
//     {
//       'name': 'Faces',
//       'icon': '😊',
//       'range': [0x1F600, 0x1F64F]
//     },
//     {
//       'name': 'Animals',
//       'icon': '🐱',
//       'range': [0x1F400, 0x1F4FF]
//     },
//     {
//       'name': 'Food',
//       'icon': '🍔',
//       'range': [0x1F32D, 0x1F37F]
//     },
//     {
//       'name': 'Objects',
//       'icon': '⚽',
//       'range': [0x1F300, 0x1F5FF]
//     },
//     {
//       'name': 'Symbols',
//       'icon': '❤️',
//       'range': [0x1F900, 0x1FAFF]
//     },
//   ];

//   List<String> getEmojisForCategory(int categoryIndex) {
//     List<String> emojis = [];
//     var range = categories[categoryIndex]['range'];
//     for (int i = range[0]; i <= range[1]; i++) {
//       emojis.add(String.fromCharCode(i));
//     }
//     return emojis;
//   }

//   List<String> getFilteredEmojis() {
//     if (_searchController.text.isEmpty) {
//       return getEmojisForCategory(_selectedCategory);
//     }
//     List<String> allEmojis = [];
//     for (var category in categories) {
//       allEmojis.addAll(getEmojisForCategory(categories.indexOf(category)));
//     }
//     return allEmojis
//         .where((emoji) => emoji.contains(_searchController.text))
//         .toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 220,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: const Color(0xFF1A1A2E),
//         borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(8, 4, 8, 2),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Tìm kiếm emoji',
//                 hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
//                 prefixIcon:
//                     Icon(Icons.search, color: Colors.grey[400], size: 18),
//                 filled: true,
//                 fillColor: Colors.white.withOpacity(0.1),
//                 contentPadding: EdgeInsets.symmetric(vertical: 6),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//               style: TextStyle(color: Colors.white, fontSize: 14),
//               onChanged: (value) => setState(() {}),
//             ),
//           ),
//           Expanded(
//             child: Column(
//               children: [
//                 Container(
//                   height: 36,
//                   padding: EdgeInsets.symmetric(horizontal: 4),
//                   margin: EdgeInsets.zero,
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Row(
//                       children: categories.map((category) {
//                         int index = categories.indexOf(category);
//                         bool isSelected = _selectedCategory == index;
//                         return GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               _selectedCategory = index;
//                               _searchController.clear();
//                             });
//                           },
//                           child: Container(
//                             margin: EdgeInsets.symmetric(horizontal: 2),
//                             padding: EdgeInsets.all(4),
//                             decoration: BoxDecoration(
//                               color: isSelected
//                                   ? Color(0xFFF5E050).withOpacity(0.2)
//                                   : Colors.transparent,
//                               borderRadius: BorderRadius.circular(6),
//                               border: isSelected
//                                   ? Border.all(
//                                       color: Color(0xFFF5E050), width: 1)
//                                   : null,
//                             ),
//                             child: Text(
//                               category['icon'],
//                               style: TextStyle(
//                                 fontSize: 22,
//                                 color: isSelected
//                                     ? Color(0xFFF5E050)
//                                     : Colors.white,
//                               ),
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
//                     child: GridView.builder(
//                       padding: EdgeInsets.zero,
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 8,
//                         crossAxisSpacing: 2,
//                         mainAxisSpacing: 2,
//                       ),
//                       itemCount: getFilteredEmojis().length,
//                       itemBuilder: (context, index) {
//                         final emoji = getFilteredEmojis()[index];
//                         return GestureDetector(
//                           onTap: () {
//                             widget.controller.text += emoji;
//                           },
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.grey.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 emoji,
//                                 style: TextStyle(fontSize: 20),
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _CommentScreenState extends ConsumerState<CommentScreen>
//     with SingleTickerProviderStateMixin {
//   List<Comment> comments = [];
//   bool isLoading = true;
//   final TextEditingController _commentController = TextEditingController();
//   late AnimationController _animationController;
//   bool _showEmojiPicker = false;
//   File? _selectedImage;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       fetchComments();
//     });
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _commentController.dispose();
//     super.dispose();
//   }

//   Future<void> fetchComments() async {
//     final currentUser = ref.read(userProvider);
//     if (currentUser != null) {
//       try {
//         final commentRepository = ref.read(commentRepositoryProvider);
//         final fetchedComments = await commentRepository.getComments(
//           itemId: widget.blogId,
//           itemCode: widget.itemCode,
//         );

//         // Lấy danh sách ID bình luận mà người dùng đã thích từ SharedPreferences
//         final likedCommentIds =
//             await commentRepository.getLikedCommentIds(currentUser.id);

//         setState(() {
//           comments = fetchedComments ?? [];
//           for (var comment in comments) {
//             // Kiểm tra xem bình luận có trong danh sách đã thích không
//             comment.isLiked = likedCommentIds.contains(comment.id);
//             print(
//                 'Bình luận: ${comment.content}, Bởi: ${comment.user.username}, Đã thích: ${comment.isLiked}');
//             for (var reply in comment.replies) {
//               print(
//                   'Phản hồi: ${reply.content}, Bởi: ${reply.user?.username ?? "Không có user"}');
//               if (reply.user == null) {
//                 print('CẢNH BÁO: reply.user là null');
//               }
//             }
//           }
//           isLoading = false;
//         });
//       } catch (error) {
//         setState(() {
//           isLoading = false;
//         });
//         print('Lỗi khi lấy bình luận: $error');
//       }
//     } else {
//       // Xử lý trường hợp không có người dùng hiện tại
//     }
//   }

//   Future<void> createComment(String content, {int? parentId}) async {
//     try {
//       final commentRepository = ref.read(commentRepositoryProvider);
//       await commentRepository.createComment(
//         itemId: widget.blogId,
//         itemCode: widget.itemCode,
//         content: content,
//         parentId: parentId,
//         commentResources: _selectedImage?.path,
//       );
//       _commentController.clear();
//       setState(() {
//         _selectedImage = null;
//         _showEmojiPicker = false;
//       });
//       await fetchComments();
//     } catch (error) {
//       print('Lỗi khi đăng bình luận/phản hồi: $error');
//     }
//   }

//   void toggleLike(Comment comment) {
//     final currentUser = ref.read(userProvider);
//     if (currentUser != null) {
//       // Thay đổi trạng thái "thích" cục bộ
//       setState(() {
//         comment.isLiked = !comment.isLiked;
//         comment.likes += comment.isLiked ? 1 : -1;
//         if (comment.likes < 0) comment.likes = 0; // Đảm bảo không có số âm
//       });

//       // Bạn có thể thêm logic để gửi yêu cầu cập nhật lên server nếu cần
//       // Ví dụ:
//       // if (comment.isLiked) {
//       //   await commentRepository.likeComment(comment.id);
//       // } else {
//       //   await commentRepository.unlikeComment(comment.id);
//       // }

//       // Hiệu ứng animation khi thích
//       _animationController.forward(from: 0);
//     } else {
//       // Thông báo rằng người dùng cần đăng nhập
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Bạn cần đăng nhập để thích bình luận!')));
//     }
//   }

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentUser = ref.watch(userProvider);
//     return GestureDetector(
//       onTap: () {
//         FocusScope.of(context).unfocus();
//         setState(() => _showEmojiPicker = false);
//       },
//       child: Scaffold(
//         extendBodyBehindAppBar: false,
//         appBar: AppBar(
//           title: const Text(
//             'Bình Luận',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 24,
//               color: Color(0xFFF5E050),
//             ),
//           ),
//           backgroundColor: const Color(0xFF1A1A2E),
//           elevation: 0,
//           iconTheme: const IconThemeData(color: Color(0xFFF5E050)),
//         ),
//         body: SafeArea(
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Color(0xFF0F0C29), Color(0xFF302B63)],
//               ),
//             ),
//             child: Column(
//               children: [
//                 Expanded(
//                   child: isLoading
//                       ? const Center(
//                           child: CircularProgressIndicator(
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                                 Color(0xFF00C4B4)),
//                             strokeWidth: 6,
//                           ),
//                         )
//                       : comments.isEmpty
//                           ? Center(
//                               child: Text(
//                                 'Chưa có bình luận nào',
//                                 style: TextStyle(
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.bold,
//                                   color: const Color(0xFFF5E050),
//                                 ),
//                               ),
//                             )
//                           : ListView.builder(
//                               padding: EdgeInsets.all(16).copyWith(bottom: 60),
//                               physics: const AlwaysScrollableScrollPhysics(),
//                               keyboardDismissBehavior:
//                                   ScrollViewKeyboardDismissBehavior.onDrag,
//                               itemCount: comments.length,
//                               itemBuilder: (context, index) {
//                                 final comment = comments[index];
//                                 return _buildCommentCard(comment, currentUser);
//                               },
//                             ),
//                 ),
//                 Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     _buildCommentInput(currentUser),
//                     if (_showEmojiPicker)
//                       EmojiPicker(controller: _commentController),
//                   ],
//                 ),
//                 SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCommentCard(Comment comment, User? currentUser) {
//     final TextEditingController _replyController = TextEditingController();
//     final displayName = currentUser != null && currentUser.id == comment.userId
//         ? (currentUser.username.isNotEmpty
//             ? currentUser.username
//             : currentUser.full_name.isNotEmpty
//                 ? currentUser.full_name
//                 : 'Người chơi')
//         : (comment.user.username.isNotEmpty
//             ? comment.user.username
//             : comment.user.full_name.isNotEmpty
//                 ? comment.user.full_name
//                 : 'Người chơi');

//     // Xác định ký tự hiển thị trong avatar
//     String displayInitial = 'U'; // Giá trị mặc định
//     if (displayName.isNotEmpty) {
//       displayInitial = displayName[0].toUpperCase();
//     }

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Avatar với GestureDetector để xem profile
//           GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => UserProfileScreen(user: comment.user),
//                 ),
//               );
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: const Color(0xFFF5E050), width: 2),
//               ),
//               child: CircleAvatar(
//                 radius: 20,
//                 backgroundColor: const Color(0xFF24243E),
//                 child: ClipOval(
//                   child: comment.user.photo.isNotEmpty
//                       ? CachedNetworkImage(
//                           imageUrl: comment.user.photo,
//                           width: 40,
//                           height: 40,
//                           fit: BoxFit.cover,
//                           placeholder: (context, url) =>
//                               const CircularProgressIndicator(),
//                           errorWidget: (context, url, error) => Text(
//                             displayInitial,
//                             style: const TextStyle(
//                               color: Color(0xFFF5E050),
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18,
//                             ),
//                           ),
//                         )
//                       : Text(
//                           displayInitial,
//                           style: const TextStyle(
//                             color: Color(0xFFF5E050),
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF302B63),
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.2),
//                         blurRadius: 8,
//                         offset: Offset(0, 4),
//                       ),
//                     ],
//                     border: Border.all(
//                       color: const Color(0xFFF5E050).withOpacity(0.3),
//                       width: 1,
//                     ),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         displayName,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                           color: Color(0xFFF5E050),
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         comment.content.isNotEmpty
//                             ? comment.content
//                             : 'Không có nội dung',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.white,
//                           height: 1.4,
//                         ),
//                         maxLines: 3,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       if (comment.commentResourcesUrl != null)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 8),
//                           child: GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => ImageDetailScreen(
//                                     imageUrl: comment.commentResourcesUrl!,
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: Hero(
//                               tag: comment.commentResourcesUrl!,
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(8),
//                                 child: CachedNetworkImage(
//                                   imageUrl: comment.commentResourcesUrl!,
//                                   width: 100,
//                                   height: 100,
//                                   fit: BoxFit.cover,
//                                   placeholder: (context, url) =>
//                                       const CircularProgressIndicator(),
//                                   errorWidget: (context, url, error) =>
//                                       Container(
//                                     width: 100,
//                                     height: 100,
//                                     color: Colors.grey[800],
//                                     child: Icon(Icons.error, color: Colors.red),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Wrap(
//                   spacing: 16,
//                   children: [
//                     GestureDetector(
//                       onTap: () => toggleLike(comment),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           AnimatedScale(
//                             scale: comment.isLiked ? 1.2 : 1.0,
//                             duration: const Duration(milliseconds: 200),
//                             child: Icon(
//                               comment.isLiked
//                                   ? Icons.favorite
//                                   : Icons.favorite_border,
//                               size: 20,
//                               color: comment.isLiked
//                                   ? const Color(0xFFFF4081)
//                                   : const Color(0xFFB0B3B8),
//                             ),
//                           ),
//                           const SizedBox(width: 6),
//                           Text(
//                             'Thích (${comment.likes})',
//                             style: TextStyle(
//                               color: comment.isLiked
//                                   ? const Color(0xFFFF4081)
//                                   : const Color(0xFFB0B3B8),
//                               fontSize: 14,
//                               fontWeight: comment.isLiked
//                                   ? FontWeight.bold
//                                   : FontWeight.normal,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         showModalBottomSheet(
//                           context: context,
//                           isScrollControlled: true,
//                           backgroundColor: Colors.transparent,
//                           builder: (context) => Padding(
//                             padding: EdgeInsets.only(
//                                 bottom:
//                                     MediaQuery.of(context).viewInsets.bottom),
//                             child: _buildReplyInput(comment.id,
//                                 TextEditingController(), currentUser),
//                           ),
//                         );
//                       },
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(Icons.reply,
//                               size: 20, color: Color(0xFFB0B3B8)),
//                           const SizedBox(width: 6),
//                           Text(
//                             'Phản hồi (${comment.replies.length})',
//                             style: const TextStyle(
//                                 color: Color(0xFFB0B3B8), fontSize: 14),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Text(
//                       _timeAgo(comment.createdAt),
//                       style: const TextStyle(
//                           fontSize: 12, color: Color(0xFFB0B3B8)),
//                     ),
//                   ],
//                 ),
//                 if (comment.replies.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(left: 36),
//                     child: CustomPaint(
//                       painter: ReplyLinePainter(),
//                       child: Column(
//                         children: comment.replies.map((reply) {
//                           return _buildReplyCard(
//                               reply, currentUser, comment.user);
//                         }).toList(),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildReplyCard(Comment reply, User? currentUser, User commentUser) {
//     final displayName = currentUser != null && currentUser.id == reply.userId
//         ? (currentUser.username.isNotEmpty
//             ? currentUser.username
//             : currentUser.full_name.isNotEmpty
//                 ? currentUser.full_name
//                 : 'Bạn')
//         : (commentUser.username.isNotEmpty
//             ? commentUser.username
//             : commentUser.full_name.isNotEmpty
//                 ? commentUser.full_name
//                 : 'Bạn');

//     // Xác định ký tự hiển thị trong avatar
//     String displayInitial = 'U'; // Giá trị mặc định
//     if (displayName.isNotEmpty) {
//       displayInitial = displayName[0].toUpperCase();
//     }

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Avatar với GestureDetector để xem profile (sử dụng commentUser)
//               GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           UserProfileScreen(user: commentUser),
//                     ),
//                   );
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: const Color(0xFFF5E050),
//                       width: 1.5,
//                     ),
//                   ),
//                   child: CircleAvatar(
//                     radius: 16,
//                     backgroundColor: const Color(0xFF24243E),
//                     child: ClipOval(
//                       child: commentUser.photo.isNotEmpty
//                           ? CachedNetworkImage(
//                               imageUrl: commentUser.photo,
//                               width: 32,
//                               height: 32,
//                               fit: BoxFit.cover,
//                               placeholder: (context, url) =>
//                                   const CircularProgressIndicator(),
//                               errorWidget: (context, url, error) => Text(
//                                 displayInitial,
//                                 style: const TextStyle(
//                                   color: Color(0xFFF5E050),
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             )
//                           : Text(
//                               displayInitial,
//                               style: const TextStyle(
//                                 color: Color(0xFFF5E050),
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                               ),
//                             ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF302B63),
//                     borderRadius: BorderRadius.circular(10),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 6,
//                         offset: Offset(0, 2),
//                       ),
//                     ],
//                     border: Border.all(
//                       color: const Color(0xFFF5E050).withOpacity(0.2),
//                       width: 1,
//                     ),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         displayName,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                           color: Color(0xFFF5E050),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         reply.content.isNotEmpty
//                             ? reply.content
//                             : 'Nội dung trống',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.white,
//                         ),
//                       ),
//                       if (reply.commentResourcesUrl != null)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 6),
//                           child: GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => ImageDetailScreen(
//                                     imageUrl: reply.commentResourcesUrl!,
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: Hero(
//                               tag: reply.commentResourcesUrl!,
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(6),
//                                 child: CachedNetworkImage(
//                                   imageUrl: reply.commentResourcesUrl!,
//                                   width: 80,
//                                   height: 80,
//                                   fit: BoxFit.cover,
//                                   placeholder: (context, url) =>
//                                       const CircularProgressIndicator(),
//                                   errorWidget: (context, url, error) {
//                                     print('Reply image load error: $error');
//                                     return Container(
//                                       width: 80,
//                                       height: 80,
//                                       color: Colors.grey[800],
//                                       child:
//                                           Icon(Icons.error, color: Colors.red),
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           // Hiển thị các phản hồi con (nếu có)
//           if (reply.replies.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.only(left: 36),
//               child: CustomPaint(
//                 painter: ReplyLinePainter(),
//                 child: Column(
//                   children: reply.replies.map((childReply) {
//                     return _buildReplyCard(
//                         childReply, currentUser, commentUser);
//                   }).toList(),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCommentInput(User? currentUser) {
//     String displayInitial = 'U';
//     if (currentUser != null) {
//       if (currentUser.username.isNotEmpty) {
//         displayInitial = currentUser.username[0].toUpperCase();
//       } else if (currentUser.full_name.isNotEmpty) {
//         displayInitial = currentUser.full_name[0].toUpperCase();
//       }
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         color: const Color(0xFF1A1A2E),
//         borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 10,
//             offset: Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (_selectedImage != null)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 8),
//               child: Stack(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.file(
//                       _selectedImage!,
//                       width: 100,
//                       height: 100,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   Positioned(
//                     right: 0,
//                     top: 0,
//                     child: IconButton(
//                       icon: const Icon(Icons.close, color: Colors.red),
//                       onPressed: () => setState(() => _selectedImage = null),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           Row(
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: const Color(0xFFF5E050),
//                     width: 1.5,
//                   ),
//                 ),
//                 child: CircleAvatar(
//                   radius: 18,
//                   backgroundColor: const Color(0xFF24243E),
//                   child: ClipOval(
//                     child: currentUser != null && currentUser.photo.isNotEmpty
//                         ? CachedNetworkImage(
//                             imageUrl: currentUser.photo,
//                             width: 36,
//                             height: 36,
//                             fit: BoxFit.cover,
//                             placeholder: (context, url) =>
//                                 const CircularProgressIndicator(),
//                             errorWidget: (context, url, error) => Text(
//                               displayInitial,
//                               style: const TextStyle(
//                                 color: Color(0xFFF5E050),
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           )
//                         : Text(
//                             displayInitial,
//                             style: const TextStyle(
//                               color: Color(0xFFF5E050),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: TextField(
//                   controller: _commentController,
//                   style: const TextStyle(color: Colors.white),
//                   decoration: InputDecoration(
//                     hintText: 'Viết bình luận...',
//                     hintStyle: const TextStyle(color: Color(0xFFB0B3B8)),
//                     filled: true,
//                     fillColor: const Color(0xFF302B63),
//                     contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 16, vertical: 12),
//                     prefixIcon: IconButton(
//                       icon: const Icon(
//                         Icons.camera_alt,
//                         color: Color(0xFFB0B3B8),
//                         size: 24,
//                       ),
//                       onPressed: _pickImage,
//                     ),
//                     suffixIcon: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: const Icon(
//                             Icons.emoji_emotions_outlined,
//                             color: Color(0xFFB0B3B8),
//                             size: 24,
//                           ),
//                           onPressed: () {
//                             setState(
//                                 () => _showEmojiPicker = !_showEmojiPicker);
//                           },
//                         ),
//                         IconButton(
//                           icon: const Icon(
//                             Icons.send,
//                             color: Color(0xFF00C4B4),
//                             size: 24,
//                           ),
//                           onPressed: () {
//                             if (_commentController.text.trim().isNotEmpty ||
//                                 _selectedImage != null) {
//                               createComment(_commentController.text);
//                             }
//                           },
//                         ),
//                       ],
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30),
//                       borderSide: BorderSide(
//                         color: const Color(0xFFF5E050).withOpacity(0.3),
//                         width: 1,
//                       ),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30),
//                       borderSide: BorderSide(
//                         color: const Color(0xFFF5E050).withOpacity(0.3),
//                         width: 1,
//                       ),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30),
//                       borderSide: const BorderSide(
//                         color: Color(0xFFF5E050),
//                         width: 2,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildReplyInput(
//       int parentId, TextEditingController controller, User? currentUser) {
//     File? replyImage;

//     String displayInitial = 'U';
//     if (currentUser != null) {
//       if (currentUser.username.isNotEmpty) {
//         displayInitial = currentUser.username[0].toUpperCase();
//       } else if (currentUser.full_name.isNotEmpty) {
//         displayInitial = currentUser.full_name[0].toUpperCase();
//       }
//     }

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: const BoxDecoration(
//         color: Color(0xFF1A1A2E),
//         borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (replyImage != null)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 8),
//               child: Stack(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.file(
//                       replyImage,
//                       width: 100,
//                       height: 100,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   Positioned(
//                     right: 0,
//                     top: 0,
//                     child: IconButton(
//                       icon: const Icon(Icons.close, color: Colors.red),
//                       onPressed: () => setState(() => replyImage = null),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           Row(
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: const Color(0xFFF5E050),
//                     width: 1.5,
//                   ),
//                 ),
//                 child: CircleAvatar(
//                   radius: 18,
//                   backgroundColor: const Color(0xFF24243E),
//                   child: ClipOval(
//                     child: currentUser != null && currentUser.photo.isNotEmpty
//                         ? CachedNetworkImage(
//                             imageUrl: currentUser.photo,
//                             width: 36,
//                             height: 36,
//                             fit: BoxFit.cover,
//                             placeholder: (context, url) =>
//                                 const CircularProgressIndicator(),
//                             errorWidget: (context, url, error) => Text(
//                               displayInitial,
//                               style: const TextStyle(
//                                 color: Color(0xFFF5E050),
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           )
//                         : Text(
//                             displayInitial,
//                             style: const TextStyle(
//                               color: Color(0xFFF5E050),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: TextField(
//                   controller: controller,
//                   style: const TextStyle(color: Colors.white),
//                   decoration: InputDecoration(
//                     hintText: 'Viết phản hồi...',
//                     hintStyle: const TextStyle(color: Color(0xFFB0B3B8)),
//                     filled: true,
//                     fillColor: const Color(0xFF302B63),
//                     contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 16, vertical: 12),
//                     prefixIcon: IconButton(
//                       icon: const Icon(
//                         Icons.camera_alt,
//                         color: Color(0xFFB0B3B8),
//                         size: 24,
//                       ),
//                       onPressed: () async {
//                         final picker = ImagePicker();
//                         final pickedFile =
//                             await picker.pickImage(source: ImageSource.gallery);
//                         if (pickedFile != null) {
//                           setState(() => replyImage = File(pickedFile.path));
//                         }
//                       },
//                     ),
//                     suffixIcon: IconButton(
//                       icon: const Icon(
//                         Icons.send,
//                         color: Color(0xFF00C4B4),
//                         size: 24,
//                       ),
//                       onPressed: () {
//                         if (controller.text.trim().isNotEmpty ||
//                             replyImage != null) {
//                           createComment(controller.text, parentId: parentId);
//                           Navigator.pop(context);
//                         }
//                       },
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30),
//                       borderSide: BorderSide(
//                         color: const Color(0xFFF5E050).withOpacity(0.3),
//                         width: 1,
//                       ),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30),
//                       borderSide: BorderSide(
//                         color: const Color(0xFFF5E050).withOpacity(0.3),
//                         width: 1,
//                       ),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30),
//                       borderSide: const BorderSide(
//                         color: Color(0xFFF5E050),
//                         width: 2,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   String _timeAgo(String createdAt) {
//     try {
//       final DateTime commentTime = DateTime.parse(createdAt);
//       final DateTime now = DateTime.now();
//       final difference = now.difference(commentTime);

//       if (difference.inDays > 0) {
//         return '${difference.inDays}d';
//       } else if (difference.inHours > 0) {
//         return '${difference.inHours}h';
//       } else if (difference.inMinutes > 0) {
//         return '${difference.inMinutes}m';
//       } else {
//         return 'Vừa xong';
//       }
//     } catch (e) {
//       return '';
//     }
//   }
// }

// class ReplyLinePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint paint = Paint()
//       ..color = const Color(0xFFF5E050).withOpacity(0.3)
//       ..strokeWidth = 2
//       ..style = PaintingStyle.stroke;

//     final Path path = Path();
//     path.moveTo(14, 0);
//     path.quadraticBezierTo(14, 20, 28, 20);
//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
