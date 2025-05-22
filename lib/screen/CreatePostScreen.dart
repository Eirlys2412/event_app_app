import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../repositories/blog_repository.dart';
import '../providers/blog_provider.dart';
import '../providers/theme_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _contentController = TextEditingController();

  XFile? _selectedImage;
  String? _selectedCategory;
  String? _selectedStatus = 'pending';
  List<Map<String, dynamic>> _selectedTags = [];
  List<Map<String, dynamic>> _tags = [];
  List<Map<String, dynamic>> _categories = [];

  final _statuses = ['pending'];
  bool _isLoading = true;
  String? _error;

  late final BlogRepository _blogRepository;

  @override
  void initState() {
    super.initState();
    _blogRepository = ref.read(blogRepositoryProvider);
    _loadData();
  }

  Future<void> _loadData() async {
    print('Starting _loadData()'); // Debug log
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final categories = await _blogRepository.getCategories();
      print('Loaded categories: $categories'); // Debug log

      final tags = await _blogRepository.getTags();
      print('Loaded tags: $tags'); // Debug log

      if (mounted) {
        setState(() {
          _categories = categories;
          _tags = tags;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error in _loadData: $e'); // Debug log
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        print('Selected image path: ${image.path}'); // Debug log
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      print('Error picking image: $e'); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi chọn ảnh: ${e.toString()}')),
      );
    }
  }

  Future<String?> _getImageBase64() async {
    try {
      if (_selectedImage == null) return null;

      final bytes = await _selectedImage!.readAsBytes();
      if (bytes.isEmpty) return null;

      return base64Encode(bytes);
    } catch (e) {
      print('Error encoding image: $e');
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Chuẩn bị dữ liệu cơ bản
      final postData = {
        'title': _titleController.text,
        'content': _contentController.text,
        'category_id': _selectedCategory,
        'summary':
            _summaryController.text.isEmpty ? null : _summaryController.text,
        'status': _selectedStatus ?? 'pending',
      };

      // Thêm tags nếu có
      if (_selectedTags.isNotEmpty) {
        final tagsList = _selectedTags
            .map((tag) => {
                  'id': tag['id'].toString(),
                  'title': tag['title'].toString(),
                  'isNew': tag['isNew'] ?? false,
                })
            .toList();
        postData['tags'] = json.encode(tagsList);
      }

      // Xử lý ảnh - chỉ thêm ảnh nếu người dùng đã chọn
      if (_selectedImage != null) {
        try {
          final bytes = await _selectedImage!.readAsBytes();
          if (bytes.isNotEmpty) {
            final base64Image = base64Encode(bytes);
            if (base64Image.isNotEmpty) {
              postData['image'] = base64Image;
            }
          }
        } catch (e) {
          print('Error processing image: $e');
          // Không thêm ảnh nếu xử lý thất bại
        }
      }

      print('Submitting post data: $postData'); // Debug log

      await _blogRepository.createPost(postData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng bài thành công!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error submitting form: $e'); // Debug log
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Widget _buildTagSelector(ThemeState themeState) {
    print('Building tag selector with tags: $_tags');

    final validTags = _tags.where((tag) {
      final isValid = tag != null &&
          tag['id'] != null &&
          tag['title'] != null &&
          tag['id'].toString().isNotEmpty &&
          tag['title'].toString().isNotEmpty;
      return isValid;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: themeState.primaryColor.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: MultiSelectDialogField<Map<String, dynamic>>(
            items: validTags
                .map((tag) => MultiSelectItem<Map<String, dynamic>>(
                      tag,
                      tag['title'].toString(),
                    ))
                .toList(),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Chọn tags'),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Tạo mới'),
                    onPressed: () async {
                      final newTagTitle = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          final controller = TextEditingController();
                          return AlertDialog(
                            title: const Text('Tạo tag mới'),
                            content: TextField(
                              controller: controller,
                              autofocus: true,
                              decoration: const InputDecoration(
                                labelText: 'Tên tag',
                                hintText: 'Nhập tên tag mới',
                              ),
                              onSubmitted: (value) {
                                if (value.isNotEmpty) {
                                  Navigator.of(context).pop(value);
                                }
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () {
                                  final text = controller.text;
                                  if (text.isNotEmpty) {
                                    Navigator.of(context).pop(text);
                                  }
                                },
                                child: const Text('Tạo'),
                              ),
                            ],
                          );
                        },
                      );

                      if (newTagTitle != null && newTagTitle.isNotEmpty) {
                        setState(() {
                          final newTag = {
                            'id':
                                'new_${DateTime.now().millisecondsSinceEpoch}',
                            'title': newTagTitle,
                            'isNew': true,
                          };
                          _tags.add(newTag);
                          _selectedTags.add(newTag);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            selectedColor: themeState.primaryColor,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            buttonIcon: const Icon(Icons.arrow_drop_down),
            buttonText: Text(
              'Chọn tags',
              style: TextStyle(color: themeState.primaryTextColor),
            ),
            searchable: true,
            onConfirm: (values) {
              setState(() {
                _selectedTags = values.where((v) => v != null).toList();
              });
            },
            chipDisplay: MultiSelectChipDisplay<Map<String, dynamic>>(
              onTap: (value) {
                if (value != null) {
                  setState(() {
                    _selectedTags.remove(value);
                  });
                }
              },
              chipColor: themeState.primaryColor.withOpacity(0.1),
              textStyle: TextStyle(color: themeState.primaryTextColor),
            ),
          ),
        ),
        if (_selectedTags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _selectedTags.map((tag) {
                return Chip(
                  label: Text(
                    tag['title'].toString(),
                    style: TextStyle(color: themeState.primaryTextColor),
                  ),
                  backgroundColor: themeState.primaryColor.withOpacity(0.1),
                  onDeleted: () {
                    setState(() {
                      _selectedTags.remove(tag);
                    });
                  },
                  deleteIconColor: themeState.primaryColor,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Tạo bài viết mới',
            style: TextStyle(color: themeState.appBarTextColor),
          ),
          backgroundColor: themeState.appBarColor,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Tạo bài viết mới',
            style: TextStyle(color: themeState.appBarTextColor),
          ),
          backgroundColor: themeState.appBarColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: TextStyle(color: themeState.errorColor)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tạo bài viết mới',
          style: TextStyle(color: themeState.appBarTextColor),
        ),
        backgroundColor: themeState.appBarColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Tiêu đề
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Tiêu đề *',
                  labelStyle: TextStyle(color: themeState.secondaryTextColor),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: themeState.primaryColor.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: themeState.primaryColor),
                  ),
                ),
                style: TextStyle(color: themeState.primaryTextColor),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Vui lòng nhập tiêu đề'
                    : null,
              ),
              const SizedBox(height: 12),

              // Ảnh
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: themeState.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: themeState.primaryColor.withOpacity(0.5),
                    ),
                  ),
                  child: _selectedImage == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                color: themeState.secondaryTextColor,
                                size: 48,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Chọn ảnh',
                                style: TextStyle(
                                    color: themeState.secondaryTextColor),
                              ),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: kIsWeb
                              ? Image.network(_selectedImage!.path,
                                  fit: BoxFit.cover)
                              : Image.file(File(_selectedImage!.path),
                                  fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(height: 12),

              // Mô tả ngắn
              TextFormField(
                controller: _summaryController,
                decoration: InputDecoration(
                  labelText: 'Mô tả ngắn',
                  labelStyle: TextStyle(color: themeState.secondaryTextColor),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: themeState.primaryColor.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: themeState.primaryColor),
                  ),
                ),
                style: TextStyle(color: themeState.primaryTextColor),
              ),
              const SizedBox(height: 12),

              // Nội dung bài viết
              TextFormField(
                controller: _contentController,
                maxLines: 10,
                decoration: InputDecoration(
                  labelText: 'Nội dung bài viết *',
                  labelStyle: TextStyle(color: themeState.secondaryTextColor),
                  alignLabelWithHint: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: themeState.primaryColor.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: themeState.primaryColor),
                  ),
                ),
                style: TextStyle(color: themeState.primaryTextColor),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Vui lòng nhập nội dung'
                    : null,
              ),
              const SizedBox(height: 12),

              // Danh mục
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Danh mục *',
                  labelStyle: TextStyle(color: themeState.secondaryTextColor),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: themeState.primaryColor.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: themeState.primaryColor),
                  ),
                ),
                style: TextStyle(color: themeState.primaryTextColor),
                items: _categories.map((cat) {
                  print(
                      'Creating category item - id: ${cat['id']}, title: ${cat['title']}'); // Debug log
                  return DropdownMenuItem(
                    value: cat['id']?.toString() ?? '',
                    child: Text(cat['title']?.toString() ?? ''),
                  );
                }).toList(),
                onChanged: (val) {
                  print('Selected category: $val'); // Debug log
                  setState(() => _selectedCategory = val);
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Vui lòng chọn danh mục'
                    : null,
              ),
              const SizedBox(height: 12),

              // Tags
              _buildTagSelector(themeState),
              const SizedBox(height: 12),

              // Trạng thái
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Trạng thái *',
                  labelStyle: TextStyle(color: themeState.secondaryTextColor),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: themeState.primaryColor.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: themeState.primaryColor),
                  ),
                ),
                style: TextStyle(color: themeState.primaryTextColor),
                items: _statuses
                    .map((st) => DropdownMenuItem(
                          value: st,
                          child: Text(st),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedStatus = val),
                validator: (value) =>
                    value == null ? 'Vui lòng chọn trạng thái' : null,
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitForm,
                icon: _isLoading
                    ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Icon(Icons.save, color: themeState.buttonTextColor),
                label: Text(
                  _isLoading ? 'Đang lưu...' : 'Lưu bài viết',
                  style: TextStyle(color: themeState.buttonTextColor),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeState.primaryColor,
                  minimumSize: const Size.fromHeight(50),
                  disabledBackgroundColor:
                      themeState.primaryColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
