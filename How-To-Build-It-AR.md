<div dir="rtl" align="right">

# 🛠️ دليلك الشامل لبناء مشروع مشابه (من الصفر للاحتراف)

هذا الملف مش مجرد خطوات عادية، ده **دليل تفصيلي جداً** بيشرحلك إزاي تعمل بورتفوليو احترافي بنفس المعمارية اللي استخدمناها (بدون سيرفرات، استضافة على Cloud، ونشر تلقائي). لو إنت عايز تستخدم نفس شكل الموقع بتاعي وتعدل عليه لنفسك، هنا هتلاقي كل التفاصيل.

---

## 📋 أولاً: إيه المطلوب منك في البداية؟ (المتطلبات المسبقة)

قبل ما تبدأ تعدل في أي كود، لازم تكون مجهز الحاجات دي:

1. **حسابات أساسية:**
   - **AWS Account:** حساب على منصة أمازون السحابية (عشان نرفع عليه ملفات الموقع ونستخدم الـ CDN).
   - **Firebase Account:** حساب جوجل عادي هتدخل بيه على `console.firebase.google.com` (عشان نعمل الداتا بيز اللي هتحفظ مهاراتك ومشاريعك).
   - **GitHub Account:** عشان نرفع عليه الكود ونعمل النشر التلقائي (CI/CD).

2. **برامج لازم تتسطب على جهازك:**
   - برنامج **Git**: عشان ترفع الكود لجيت هاب.
   - برنامج **Terraform**: عشان نكتب كود يبني البنية التحتية أوتوماتيك (IaC).
   - برنامج **AWS CLI**: عشان تقدر تتحكم في حساب AWS بتاعك من الـ Terminal.

3. **إعداد جهازك:**
   - بعد ما تسطب `AWS CLI`، افتح الـ Terminal واكتب `aws configure`.
   - هيطلب منك الـ `Access Key` والـ `Secret Key` بتوع حسابك (هتجيبهم من Security Credentials في AWS)، وكمان الـ `Region` (اكتب `us-east-1`).

---

## 🎨 ثانياً: إزاي تستخدم نفس شكل الموقع وتعدل عليه؟

لو عاجبك التصميم وعايز تستخدمه لنفسك:
1. اعمل `Clone` أو نزل الكود ده عندك على الجهاز.
2. كل الصور بتاعتك (زي صورتك الشخصية)، ارفعها على [Google Drive](https://drive.google.com) أو أي موقع رفع صور وخد اللينك المباشر بتاعها، أو ممكن ترفعها في نفس الفولدر وتكتب اسمها في الـ Admin.
3. ملف `index.html` هو واجهة الموقع، و `admin.html` هي لوحة التحكم. كل الداتا اللي بتتعرض في الموقع (كلام، مشاريع، مهارات، لينكات) **مش محتاج تعدلها من الكود**! هتقدر تعدلها من لوحة التحكم (Admin Panel) زي ما هنشرح قدام.

---

## 🔥 ثالثاً: إعداد الداتا بيز ولوحة التحكم (Firebase)

إحنا مش بنستخدم سيرفر، بنستخدم `Firebase` كـ Backend.

1. ادخل على **Firebase Console** واعمل مشروع جديد `Add Project`.
2. من القائمة الجانبية اختار **Firestore Database** واضغط `Create Database`. اختار `Production mode`.
3. عشان نحمي الداتا بتاعتك من إن أي حد يعدلها، روح لتاب الـ **Rules** واكتب الكود ده (استبدل الإيميل بإيميلك الحقيقي):
<div dir="ltr" align="left">

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /portfolio/{document} {
      allow read: if true; // أي حد يقدر يشوف الموقع
      // إنت بس اللي تقدر تعدل الداتا
      allow write: if request.auth != null && request.auth.token.email == "YOUR_EMAIL@gmail.com";
    }
  }
}
```
</div>

4. من القائمة الجانبية اختار **Authentication** واعمل تفعيل لـ `Email/Password`.
5. روح لتاب `Users` جوة الـ Authentication واعمل `Add User` واكتب إيميلك وباسوردك (دول اللي هتدخل بيهم لوحة التحكم).
6. روح لإعدادات المشروع `Project Settings` (علامة الترس)، انزل تحت واعمل تسجيل لتطبيق ويب `Web App` `</>`.
7. هيطلعلك كود فيه `firebaseConfig` (فيه الـ API Key وغيرها).
8. افتح ملف `index.html` وملف `admin.html` في الكود عندك، وانزل تحت خالص هتلاقي متغير اسمه `firebaseConfig`، بدله بالكود بتاعك.

---

## ☁️ رابعاً: بناء البنية التحتية (Terraform & AWS)

بدل ما نفتح موقع AWS ونعمل الـ Bucket بإيدينا، هنخلي Terraform يعملها:

1. ادخل جوة فولدر `infra` في المشروع.
2. افتح ملف `main.tf` وغير اسم الـ `bucket` لأي اسم مميز جداً بتاعك.
3. افتح الـ Terminal في فولدر `infra` واكتب:
<div dir="ltr" align="left">

```bash
terraform init
terraform plan
terraform apply
```
</div>
4. اكتب `yes` لما يسألك. بعد ما يخلص، هيطلعلك رابط الـ `CloudFront`، ده الرابط النهائي لموقعك!

---

## 🔐 خامساً: إعداد النشر التلقائي الآمن (OIDC & GitHub Actions)

عشان لما تعدل كود وترفعه على جيت هاب ينزل أوتوماتيك على الموقع من غير ما تدي جيت هاب الباسوردات بتاعتك:

1. افتح **AWS Console** وروح لخدمة **IAM** > **Identity Providers** واعمل `Add Provider`.
2. اختار **OpenID Connect** واكتب:
   - Provider URL: `https://token.actions.githubusercontent.com`
   - Audience: `sts.amazonaws.com`
3. من `IAM` روح لـ **Roles** واعمل `Create Role`، اختار `Web Identity` واختار الـ Provider اللي لسه عامله.
4. اربط الـ Role بصلاحيات تسمحله يرفع ملفات للـ S3 Bucket بتاعك ويعمل Invalidation للـ CloudFront.
5. انسخ الـ `Role ARN` (بيكون شكله كده: `arn:aws:iam::1234567890:role/YourRoleName`).
6. افتح المستودع بتاعك على GitHub > `Settings` > `Secrets and variables` > `Actions` > `New repository secret`.
7. سمي الـ Secret باسم `AWS_ROLE_ARN` وحط الـ ARN اللي نسخته.
8. في ملف `.github/workflows/deploy.yml`، غير اسم الـ S3 Bucket والـ CloudFront ID للبيانات بتاعتك.

---

## 🚀 سادساً: تشغيل المشروع وتعديل بياناتك

1. ارفع كل الكود ده على الـ `main` branch في GitHub:
<div dir="ltr" align="left">

```bash
git add .
git commit -m "First release"
git push origin main
```
</div>

2. الـ GitHub Actions هيشتغل أوتوماتيك ويرفع الموقع لـ AWS.
3. افتح رابط الموقع بتاعك اللي طالع من CloudFront.
4. عشان تعدل الداتا بتاعتك وتضيف مشاريعك:
   - زود `/admin.html` في آخر رابط الموقع.
   - سجل دخول بالإيميل والباسورد اللي عملتهم في `Firebase`.
   - هتقدر تعدل (صورتك، المهارات، المشاريع، الشهادات، آراء العملاء، ولينك الـ CV).
   - بمجرد ما تدوس `Save`، الموقع الرئيسي هيتحدث في نفس الثانية قدام كل الزوار!

🎉 مبروك! إنت دلوقتي عندك بورتفوليو احترافي جداً مبني بأحدث تقنيات الـ DevOps.

</div>
