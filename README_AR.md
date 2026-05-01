# تطبيق Cosmic Messenger 🚀

تطبيق مراسلة فضائي غامر يعمل بدون إنترنت عبر الشبكة المحلية (WiFi)

## الميزات ✨

✅ **تسجيل حساب وتسجيل دخول محلي**
- إنشاء حسابات جديدة
- تسجيل دخول آمن

✅ **نظام الرسائل الفورية**
- إرسال واستقبال الرسائل بين المستخدمين
- سجل محادثات محلي

✅ **قائمة الأصدقاء**
- إضافة وإزالة الأصدقاء
- البحث عن المستخدمين
- عرض حالة الاتصال (أونلاين/أوفلاين)

✅ **الملف الشخصي**
- صورة بروفايل قابلة للتعديل
- سيرة ذاتية شخصية
- معلومات المستخدم

✅ **الإشعارات**
- إشعارات داخلية للرسائل الجديدة
- إشعارات طلبات الصداقة

✅ **التصميم الفضائي**
- خلفية متدرجة (أزرق ليلي - بنفسجي)
- نجوم متناثرة
- توهجات سيان
- تأثيرات سديم ناعمة

## المتطلبات 📋

- **Flutter 3.41.9** أو أحدث
- **Dart 3.11.5** أو أحدث
- **Android SDK** (لبناء APK)
- **Java JDK 11** أو أحدث

## التثبيت والتشغيل 🛠️

### 1. تثبيت Flutter
إذا لم تكن قد ثبتت Flutter بعد:
```bash
# من https://flutter.dev/docs/get-started/install
```

### 2. استنساخ/فك ضغط المشروع
```bash
# إذا كان لديك الملف المضغوط
unzip cosmic_messenger.zip
cd cosmic_messenger
```

### 3. تثبيت المكتبات
```bash
flutter pub get
```

### 4. تشغيل التطبيق على محاكي أو جهاز فعلي
```bash
# على محاكي
flutter run

# أو على جهاز فعلي متصل
flutter run -d <device_id>
```

### 5. بناء APK للإصدار
```bash
flutter build apk --release
```

سيتم إنشاء APK في:
```
build/app/outputs/flutter-apk/app-release.apk
```

## البنية الأساسية 📁

```
cosmic_messenger/
├── lib/
│   ├── main.dart                 # نقطة الدخول الرئيسية
│   ├── theme/
│   │   └── app_theme.dart       # الألوان والتصميم
│   ├── models/
│   │   ├── user_model.dart      # نموذج المستخدم
│   │   └── message_model.dart   # نموذج الرسالة
│   ├── services/
│   │   └── database_service.dart # خدمة قاعدة البيانات
│   ├── providers/
│   │   ├── auth_provider.dart   # إدارة المصادقة
│   │   ├── chat_provider.dart   # إدارة الرسائل
│   │   └── friends_provider.dart # إدارة الأصدقاء
│   └── screens/
│       ├── splash_screen.dart   # شاشة البداية
│       ├── login_screen.dart    # تسجيل الدخول
│       ├── home_screen.dart     # الشاشة الرئيسية
│       ├── chat_screen.dart     # شاشة المحادثة
│       ├── friends_screen.dart  # قائمة الأصدقاء
│       └── profile_screen.dart  # الملف الشخصي
├── android/                      # ملفات Android
├── ios/                         # ملفات iOS
├── pubspec.yaml                 # المكتبات والإعدادات
└── README_AR.md                 # هذا الملف
```

## المكتبات المستخدمة 📚

| المكتبة | الإصدار | الاستخدام |
|--------|--------|----------|
| sqflite | ^2.3.0 | قاعدة بيانات SQLite محلية |
| provider | ^6.1.0 | إدارة الحالة |
| image_picker | ^1.0.7 | اختيار الصور |
| shared_preferences | ^2.2.2 | التخزين المحلي |
| uuid | ^4.0.0 | توليد معرّفات فريدة |
| connectivity_plus | ^5.0.2 | التحقق من الاتصال |
| animations | ^2.0.11 | التأثيرات والحركات |

## كيفية الاستخدام 🎮

### تسجيل حساب جديد
1. اضغط على "إنشاء حساب"
2. أدخل اسم المستخدم والبريد الإلكتروني
3. اضغط "إنشاء حساب"

### تسجيل الدخول
1. أدخل اسم المستخدم
2. اضغط "دخول"

### إضافة صديق
1. انتقل إلى تبويب "الأصدقاء"
2. ابحث عن المستخدم
3. اضغط "إضافة"

### إرسال رسالة
1. اختر صديق من القائمة
2. اكتب الرسالة
3. اضغط زر الإرسال

### تعديل الملف الشخصي
1. اضغط على أيقونة الملف الشخصي
2. عدّل الصورة والسيرة الذاتية
3. احفظ التغييرات

## قاعدة البيانات 🗄️

التطبيق يستخدم SQLite مع الجداول التالية:

### جدول المستخدمين (users)
```sql
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  username TEXT NOT NULL UNIQUE,
  email TEXT NOT NULL UNIQUE,
  profileImagePath TEXT,
  bio TEXT,
  isOnline INTEGER DEFAULT 0,
  createdAt TEXT NOT NULL
)
```

### جدول الرسائل (messages)
```sql
CREATE TABLE messages (
  id TEXT PRIMARY KEY,
  senderId TEXT NOT NULL,
  receiverId TEXT NOT NULL,
  content TEXT NOT NULL,
  timestamp TEXT NOT NULL,
  isRead INTEGER DEFAULT 0
)
```

### جدول الأصدقاء (friends)
```sql
CREATE TABLE friends (
  id TEXT PRIMARY KEY,
  userId TEXT NOT NULL,
  friendId TEXT NOT NULL,
  addedAt TEXT NOT NULL,
  UNIQUE(userId, friendId)
)
```

### جدول الإشعارات (notifications)
```sql
CREATE TABLE notifications (
  id TEXT PRIMARY KEY,
  userId TEXT NOT NULL,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  isRead INTEGER DEFAULT 0,
  createdAt TEXT NOT NULL
)
```

## حل المشاكل 🔧

### المشكلة: "No Android SDK found"
**الحل:**
```bash
flutter config --android-sdk /path/to/android/sdk
```

### المشكلة: الرسائل لا تظهر
**الحل:**
- تأكد من أن كلا المستخدمين متصلين بنفس الشبكة المحلية
- أعد تشغيل التطبيق

### المشكلة: الصور لا تحفظ
**الحل:**
- تأكد من أن التطبيق لديه صلاحيات الوصول إلى المعرض
- جرب صورة أخرى

## التطوير المستقبلي 🚀

- [ ] دعم المجموعات
- [ ] الرسائل الصوتية
- [ ] مشاركة الملفات
- [ ] التشفير end-to-end
- [ ] النسخ الاحتياطي السحابي
- [ ] الوضع الليلي/النهاري

## الترخيص 📄

هذا المشروع مفتوح المصدر ومتاح للاستخدام الحر.

## التواصل 📧

للأسئلة والاقتراحات، يمكنك التواصل معنا.

---

**استمتع بتطبيق Cosmic Messenger! 🌌✨**
