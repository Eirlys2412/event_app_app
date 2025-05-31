import '../models/profile.dart';

// Sử dụng IP của máy tính chạy server
//const String base =    'http://192.168.94.41:8000/api/v1'; // Thay đổi IP này thành IP của máy tính của bạn
const String base = 'http://10.0.2.2:8000/api/v1'; // Cho emulator

//const String url_image =    'http://192.168.94.41:8000/'; // Thay đổi IP này thành IP của máy tính của bạn
const String url_image = 'http://10.0.2.2:8000/'; // Cho emulator

//------Đăng nhập, đăng ký------//
const String api_register = "$base/register";
const String api_login = "$base/login";
const String api_logout = "$base/logout";
const String api_student = "$base/student";
const String api_teacher = "$base/teacher";
const String api_eventmember = "$base/event-members";
const String api_eventmanager = "$base/event-managers";

var api_loginGoogle = "$base/login/google";

//------Profile------------//
const String api_profile = "$base/profile";
const String api_updateprofile = "$base/updateprofile";

//------UniverInfo------------//
const String api_nganhs = "$base/nganhs";
const String api_donvi = "$base/donvi";
const String api_chuyenNganh = "$base/chuyenNganh";

//event
const String api_event = "$base/events"; //list sk
String api_event_detail(int eventId) => "$base/event/$eventId"; //chi tiet sk
String api_listuser(int eventId) =>
    "$base/event/$eventId/participants"; //list user
const String api_event_register = "$base/event_registrations"; //đk sk
String api_profile_user(int userId) =>
    "$base/users/$userId"; // xem chi tiết 1 người tha gia sự kiện
var api_join =
    "$base/event_registrations/my-registrations"; // ds sự kiện chờ duyệt
String api_userevent(userId) => "$base/event-users/user/userId";

//tym
String api_like_image(int resourceId) =>
    "$base/event-images/$resourceId/toggle-like";

String api_like_blog(int blogId) => "$base/blogs/$blogId/toggle-like";
//action
const String api_action = "$base/actions"; //list action
String api_action_detail(int actionId) =>
    "$base/actions/$actionId"; //chi tiet action
const String api_action_create = "$base/actions"; //tạo action
const String api_action_update = "$base/actions/{actionId}"; //cập nhật action
const String api_action_delete = "$base/actions/{actionId}"; //xóa action

// 🔥 Like
const String api_like_toggle = "$base/likes/toggle"; // POST toggle like
String api_rating_event(int eventId) =>
    "$base/event/$eventId/rate"; // đánh giá sự kiện
// 🔥 Vote
const String api_vote = "$base/like"; // POST vote
const String api_vote_average = "$base/vote"; // /{type}/{id}
//tag
const String api_tag = "$base/tags"; //list tag
String api_tag_detail(int tagId) => "$base/tags/$tagId"; //chi tiet tag
const String api_tag_create = "$base/tags"; //tạo tag
const String api_tag_update = "$base/tags/{tagId}"; //cập nhật tag
const String api_tag_delete = "$base/tags/{tagId}"; //xóa tag

final String api_create_event_payment = base + "/events/payment/create";
final String api_process_event_payment = base + "/events/payment/process";
final String api_get_my_tickets = base + "/events/my-tickets"; //
// qr
const String api_qr = "$base/check-in/{eventId}"; //check mã qr

var api_createPost = base + "/create-post";
var api_getPost = base + "/get-post";
var api_updatePost = base + "/update-post";
var api_deletePost = base + "/delete-post";
//comment
final String api_getComment = "$base/comments"; // GET danh sách bình luận
final String api_createComment = "$base/comments"; // POST tạo bình luận
String api_updateComment(int id) =>
    "$base/comments/$id"; // PUT cập nhật bình luận
String api_deleteComment(int id) => "$base/comments/$id";
String api_replycomment(int id) =>
    "$base/comments/{id}/reply"; // POST trả lời bình luận
String api_likecomment(int id) =>
    "$base/comments/{id}/toggle-like"; // POST like bình luận

var api_getresources = base + "/resources/{id}";
var api_getblogcat = base + "/blogcat"; // GET danh sách thể loại blog
var api_getblogcatid = base + "/blogcat/"; // GET chi tiết thể loại blog
var api_getblogsearch = base + "/blogs/search"; // GET tìm kiếm blog
var api_getblog = base + "/blogs/approved"; // GET danh sách blog đã duyệt
var api_getblogidslug = base + "/blog"; // GET chi tiết blog slug,id
var api_getblogtagds =
    base + "/blogs/filter"; // GET danh sách blog theo tag, danh mục
var api_postblog = base + "/blog/store"; // POST tạo blog
String api_putblog(int id) => base + "/blog/$id"; // PUT cập nhật blog
String api_deleteblog(int id) => base + "/blog/$id"; // DELETE xóa blog
var api_myblog = base + "/my-blogs"; // GET danh sách blog của tôi
String api_dsblog(int userId) =>
    base + "/blogs/user/$userId"; // GET danh sách blog người dùng

String api_upload_image(int eventId) =>
    base + "/events/$eventId/images"; // POST upload image
String api_delete_image(int eventId, int resourceId) =>
    base + "/events/$eventId/images/$resourceId"; // DELETE xóa image

var api_getaction = base + "/getaction";
var api_like = base + "/like";
var api_share = base + "/share";
var api_votee = "$base/vote";
var api_savecomment = base + "/savecomment"; // POST lưu bình luận
var api_updatecomment = base + "/updatecomment"; // PUT cập nhật bình luận
var api_deletecomment = base + "/deletecomment"; // DELETE xóa bình luận
var app_type = "web";
var g_token = "";
var g_tags = [];
//-------Error-------//
const String severError = "Sever Error";
const String unauthorized = "Unauthorized";
const String somethingWentWrong = "Something went wrong";

Profile initialProfile = const Profile(
    full_name: '',
    username: '',
    phone: '',
    address: '',
    photo: '',
    role: '',
    email: '',
    id: 0);

var api_statistics_top = base + "/statistics/top";
