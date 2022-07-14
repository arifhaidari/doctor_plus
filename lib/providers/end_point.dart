// ignore_for_file: constant_identifier_names, prefer_adjacent_string_concatenation

const String NO_INTERNET_CONNECTION = "no_internet_connection";
const String CONNECTIVITY_ENDPOINT = "www.google.com";
// network
// const String BASE_URL = "http://192.168.0.136:8000/api/"; // for netwo rk
// const String MEDIA_LINK = "http://192.168.0.136:8000/media/";
// const String MEDIA_LINK_NO_SLASH = "http://192.168.0.136:8000";
// const String CHAT_SOCKET_LINK = 'ws://192.168.0.136:8000/' + "ws/chat/"; //Simulator
// simulator
// const String BASE_URL = "http://127.0.0.1:8000/api/"; // for simulator
// const String MEDIA_LINK = "http://127.0.0.1:8000/media/";
// const String MEDIA_LINK_NO_SLASH = "http://127.0.0.1:8000";
// const String CHAT_SOCKET_LINK = 'ws://127.0.0.1:8000/' + "ws/chat/"; //Simulator
// emulator
const String BASE_URL = "http://10.0.2.2:8000/api/"; // for emulator
const String MEDIA_LINK = "http://10.0.2.2:8000/media/";
const String MEDIA_LINK_NO_SLASH = "http://10.0.2.2:8000";
const String CHAT_SOCKET_LINK = 'ws://10.0.2.2:8000/' + "ws/chat/"; //emulator

// Patient USER URL
const String LOGIN_URL = BASE_URL + "token/patient/";
const String REGISTER_URL = BASE_URL + "user/register/";
const String USER_BASIC_INFO = BASE_URL + "patient/basic/info/";
const String VIEW_DOCTOR_PROFILE_PLUS = BASE_URL + "patient/view/doctor/profile/";
const String APPT_CREATE_LIST = BASE_URL + "patient/appt/create/list/"; // pagination
const String FAVORITE_DOCTOR_CREATE_LIST = BASE_URL + "patient/favorite/create/list/";
const String ALL_MEDICAL_RECORD = BASE_URL + "patient/medical/create/list/";
const String MEDICAL_RECORD_DETAIL = BASE_URL + "patient/medical/detail/";
const String MEDICAL_RECORD_SHARE_HANDLER = BASE_URL + "patient/medical/share/";
const String MEDICAL_RECORD_GENERAL_SHARE_HANDLER = BASE_URL + "patient/medical/general/share/";
const String CREATE_MEDICAL_RECORD_DATA = BASE_URL + "patient/medical/create/data/";
const String PATIENT_RELATIVE_PROFILE = BASE_URL + "patient/relative/profile/"; // pagiantaion
const String FAMILY_MEMBER_TILE = BASE_URL + "patient/family/list/";
const String DOCTOR_APPT_LIST = BASE_URL + "patient/doctor/appt/";
const String APPT_DETAIL_CANCEL = BASE_URL + "patient/appt/detail/";
const String PATIENT_PROFILE_SETTING = BASE_URL + "patient/profile/setting/";
const String PATIENT_DISTRICT_LIST = BASE_URL + "patient/district/list/";
const String PATIENT_RELATIVE_LIST = BASE_URL + "patient/relative/list/";
const String PATIENT_RELATIVE_INITIAL_PLUS = BASE_URL + "patient/relative/initial/";
// without authentication
const String FIND_DOCTOR_DATA = BASE_URL + "patient/find-doctor/";
const String SEARCH_DOCTOR = BASE_URL + "patient/search/doctor/";
const String OPT_VERIFICATION = BASE_URL + "user/otp/";

// PUBLIC URL
const String CITY_URL = BASE_URL + "public/city/";
const String DISTRICT_URL = BASE_URL + "public/district/";
const String CARE_SERVICE_LIST = BASE_URL + "public/care/service/";
const String CITY_DISTRICT_LIST = BASE_URL + "public/city/district/list/";
const String EDUCATION_SUB_LIST = BASE_URL + "public/education/sub/list/";

// Both in doctor and patient
const String NOTE_GET = BASE_URL + "doctor/note/list/";
const String NOTE_DETAIL = BASE_URL + "doctor/note/";
const String CHANGE_PASS = BASE_URL + "doctor/change/pass/";

// Chat
const String CHAT_GET_POST = BASE_URL + "chat/";
const String CHAT_USER_LIST = BASE_URL + "chat/user/list/"; // pagination
