<div dir="rtl" align="right">

# 🚀 الدليل الشامل لبناء بورتفوليو ديناميكي بالكامل (DevOps & Serverless)

هذا الدليل مخصص لأي مهندس أو مطور يريد بناء نفس البنية التحتية لهذا المشروع خطوة بخطوة. المشروع عبارة عن بورتفوليو ديناميكي لا يعتمد على خوادم تقليدية، بل يعتمد على تقنيات السحابة (Cloud) وأتمتة النشر (CI/CD).

---

## 🛠 التقنيات المستخدمة

- **الاستضافة:** `AWS S3` و `AWS CloudFront` (لتوزيع المحتوى بسرعة حول العالم وتفعيل `HTTPS`).
- **البنية التحتية ككود (IaC):** `Terraform`.
- **قاعدة البيانات والمصادقة:** `Firebase Firestore` لتخزين البيانات، و `Firebase Auth` لحماية لوحة التحكم.
- **الأتمتة (CI/CD):** `GitHub Actions`.
- **الأمان:** `OIDC (OpenID Connect)` لربط `GitHub Actions` مع `AWS` بدون أي مفاتيح سرية ثابتة.

---

## 📝 الخطوة الأولى: إعداد قاعدة البيانات (Firebase)

لتخزين محتوى الموقع (المشاريع، المهارات، الشهادات) بشكل ديناميكي، نستخدم `Firebase`.

1. اذهب إلى [Firebase Console](https://console.firebase.google.com/) وقم بإنشاء مشروع جديد.
2. قم بتفعيل **Firestore Database** في وضع الإنتاج (`Production Mode`).
3. اذهب إلى علامة التبويب **Rules** وضع القواعد التالية لضمان أن الزوار يمكنهم القراءة فقط، بينما يمكن للـ `Admin` فقط التعديل:

<div dir="ltr" align="left">

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /portfolio/{document} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.email == "YOUR_EMAIL@gmail.com";
    }
  }
}
```
</div>

4. قم بتفعيل **Authentication** واختر طريقة الدخول باستخدام `Email/Password` وقم بإنشاء حساب للأدمن من هناك.
5. من إعدادات المشروع `Project Settings`، احصل على كود التكوين `firebaseConfig` لتضعه لاحقاً في ملفات الكود الخاصة بك.

---

## ☁️ الخطوة الثانية: بناء البنية التحتية (AWS & Terraform)

نستخدم `Terraform` لإنشاء الـ `Bucket` الخاص بالاستضافة وربطه بـ `CloudFront`.

1. قم بتثبيت `Terraform` و `AWS CLI` على جهازك وقم بتسجيل الدخول باستخدام حساب `AWS`.
2. داخل مجلد المشروع، أنشئ مجلداً باسم `infra`.
3. اكتب كود `Terraform` لإنشاء `S3 Bucket` و `CloudFront Distribution` (يمكنك استخدام ملف `main.tf` الموجود في هذا المستودع كمثال).
4. نفذ الأوامر التالية بالترتيب لبناء البنية التحتية:

<div dir="ltr" align="left">

```bash
cd infra
terraform init
terraform plan
terraform apply
```
</div>

بعد الانتهاء، سيعطيك `Terraform` رابط `CloudFront` الخاص بموقعك.

---

## 🔐 الخطوة الثالثة: إعداد الأمان المتقدم (OIDC)

لكي نجعل `GitHub Actions` قادراً على رفع الملفات إلى `AWS` بدون كتابة مفاتيح أمان ثابتة (`Access Keys`)، سنستخدم `OIDC`.

1. من لوحة تحكم `AWS`، اذهب إلى `IAM` ثم `Identity Providers` وأضف مزود `OpenID Connect` خاص بـ `GitHub Actions`.
2. قم بإنشاء `IAM Role` جديد واربطه بـ `Trust Policy` تسمح للمستودع (`Repository`) الخاص بك فقط باستخدام هذا الـ `Role`.
3. أعطِ هذا الـ `Role` صلاحيات رفع الملفات إلى `S3 Bucket` المخصص، وصلاحية عمل `Invalidation` لـ `CloudFront`.
4. انسخ الـ `Role ARN` واذهب إلى إعدادات المستودع في `GitHub` -> `Settings` -> `Secrets and variables` -> `Actions` وأضفه باسم `AWS_ROLE_ARN`.

---

## ⚙️ الخطوة الرابعة: إعداد النشر التلقائي (CI/CD)

في هذه الخطوة، سنجعل أي تغيير نرفعه إلى `GitHub` ينعكس فوراً على الموقع الحي.

1. قم بإنشاء ملف في المسار التالى داخل مشروعك: `.github/workflows/deploy.yml`.
2. ضع فيه الكود التالي (لا تنسَ تغيير القيم بما يتناسب مع مشروعك):

<div dir="ltr" align="left">

```yaml
name: Deploy Portfolio

on:
  push:
    branches: [ main ]

permissions:
  id-token: write   # مطلوب من أجل OIDC
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: us-east-1

      - name: Sync Files to S3
        run: |
          aws s3 sync . s3://YOUR-BUCKET-NAME \
            --delete \
            --exclude "infra/*" \
            --exclude ".git/*" \
            --exclude ".github/*"

      - name: Invalidate CloudFront Cache
        run: |
          aws cloudfront create-invalidation \
            --distribution-id YOUR-CLOUDFRONT-ID \
            --paths "/*"
```
</div>

---

## 💻 الخطوة الخامسة: تشغيل لوحة التحكم والموقع

الآن وبعد إعداد كل شيء، أصبحت البنية التحتية جاهزة:
1. اذهب إلى رابط الموقع الخاص بك (الذي حصلت عليه من `CloudFront`).
2. لإضافة بياناتك (المشاريع، المهارات، الـ `CV`)، أضف `/admin.html` إلى نهاية الرابط.
3. قم بتسجيل الدخول باستخدام الإيميل والباسورد اللذين أنشأتهما في `Firebase`.
4. يمكنك الآن تعديل أي جزء في الموقع وسيتم حفظه في `Firestore` وظهوره فوراً على الموقع الرئيسي بدون الحاجة لإعادة رفع الكود.

🎉 **بهذه الطريقة أنت تمتلك نظاماً متكاملاً واحترافياً يدار بالكامل من خلال الحوسبة السحابية والأتمتة!**

</div>
