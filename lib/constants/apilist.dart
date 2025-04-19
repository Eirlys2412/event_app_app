import '../models/profile.dart';

const String base = 'http://127.0.0.1:8000/api/v1';
// final String base = 'http://localhost:8000/api/v1';
// final String base = 'http://10.0.2.2:8000/api/v1';
// const String base = 'http://192.168.88.162:8000/api/v1';
// const String base = 'http://10.55.64.59:8080/api/v1';
const String url_image = 'http://192.168.1.5:8000/';

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
String api_event_detail(int eventId) => "$base/events/$eventId"; //chi tiet ska2
String api_listuser(int eventId) => "$base/event-users?event_id=$eventId"; //list user
const String api_event_register = "$base/event-registrations"; //đk sk

// qr
const String api_qr = "$base/check-in/{eventId}";
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
