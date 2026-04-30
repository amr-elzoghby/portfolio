# 🛠️ Comprehensive Guide: How To Build This Portfolio

This guide is not just a quick overview. It is a **highly detailed, step-by-step manual** explaining exactly how to build, deploy, and manage a professional serverless portfolio using the exact same architecture we used (Serverless backend, Cloud hosting, and CI/CD). 

If you want to use this UI design and architecture for yourself, follow this guide carefully.

---

## 📋 Step 1: Prerequisites & Initial Setup

Before modifying any code, you need to prepare your accounts and local environment.

1. **Required Accounts:**
   - **AWS Account:** To host the static files (S3) and distribute them globally (CloudFront CDN).
   - **Firebase Account:** A free Google account to access `console.firebase.google.com` (Used as our serverless database to store skills, projects, and your CV link).
   - **GitHub Account:** To store the code and run automated deployments (CI/CD).

2. **Required Local Tools:**
   - **Git:** To push your code to GitHub.
   - **Terraform CLI:** To provision the AWS infrastructure automatically (Infrastructure as Code).
   - **AWS CLI:** To interact with your AWS account from your terminal.

3. **Local Machine Setup:**
   - After installing the AWS CLI, open your terminal and run `aws configure`.
   - Provide your `AWS Access Key ID`, `AWS Secret Access Key` (obtainable from IAM Security Credentials in AWS), and set your default region (e.g., `us-east-1`).

---

## 🎨 Step 2: Customizing The Code & Design

If you like the design and want to use it for yourself:
1. `Clone` or download this repository to your local machine.
2. The portfolio is powered by two main files: `index.html` (the public-facing site) and `admin.html` (the dashboard).
3. **You DO NOT need to hardcode your data in the HTML.** All your text, projects, skills, and links are managed dynamically via the Admin Panel. 
4. For images (like your profile picture or project thumbnails), you can upload them to Google Drive (make sure the link is set to "Anyone with the link can view") and paste the link into the Admin Panel.

---

## 🔥 Step 3: Serverless Backend & Admin Panel (Firebase)

We don't use a traditional server. We use `Firebase` as our serverless backend.

1. Go to the **Firebase Console** and click `Add Project`.
2. From the left menu, select **Firestore Database** and click `Create Database`. Choose `Production mode`.
3. To secure your database so nobody else can edit your portfolio, go to the **Rules** tab and paste this code (Replace the email with your actual email):
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /portfolio/{document} {
         allow read: if true; // Public can see your portfolio
         // Only YOU can edit the data
         allow write: if request.auth != null && request.auth.token.email == "YOUR_EMAIL@gmail.com";
       }
     }
   }
   ```
4. From the left menu, select **Authentication** and enable `Email/Password`.
5. Go to the `Users` tab in Authentication, click `Add User`, and type your email and a strong password. (These are your Admin Panel login credentials).
6. Go to **Project Settings** (the gear icon), scroll down, and register a `Web App` `</>`.
7. You will be provided with a `firebaseConfig` object containing your API key.
8. Open `index.html` and `admin.html` in your code editor. Scroll to the bottom of both files, find the `firebaseConfig` variable, and replace it with your new configuration.

---

## ☁️ Step 4: Infrastructure Provisioning (Terraform & AWS)

Instead of manually creating AWS buckets, we use Terraform to build it:

1. Open your terminal and navigate to the `infra` folder inside the project.
2. Open `main.tf` and change the `bucket` name to something globally unique (e.g., `yourname-portfolio-bucket-2026`).
3. Run the following commands in the terminal:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```
4. Type `yes` when prompted. When finished, Terraform will output your `CloudFront Distribution URL`. This is your live website link!

---

## 🔐 Step 5: Secure CI/CD Automation (OIDC & GitHub Actions)

To automatically deploy code changes to AWS without storing passwords in GitHub:

1. Open the **AWS Console**, go to **IAM** > **Identity Providers** and click `Add Provider`.
2. Select **OpenID Connect** and enter:
   - Provider URL: `https://token.actions.githubusercontent.com`
   - Audience: `sts.amazonaws.com`
3. Still in `IAM`, go to **Roles** > `Create Role`. Select `Web Identity`, choose the provider you just created, and restrict it to your GitHub username and repository name.
4. Attach an inline permissions policy to this Role to allow `s3:Sync` on your bucket and `cloudfront:CreateInvalidation` on your distribution.
5. Copy the **Role ARN** (looks like `arn:aws:iam::1234567890:role/YourRoleName`).
6. Go to your GitHub Repository > `Settings` > `Secrets and variables` > `Actions` > `New repository secret`.
7. Name it `AWS_ROLE_ARN` and paste the ARN.
8. Open `.github/workflows/deploy.yml` in your code editor and replace the S3 Bucket name and CloudFront Distribution ID with yours.

---

## 🚀 Step 6: Go Live and Manage Content

1. Push all your configured code to the `main` branch on GitHub:
   ```bash
   git add .
   git commit -m "Initial portfolio setup"
   git push origin main
   ```
2. GitHub Actions will trigger automatically, authenticate with AWS securely via OIDC, and deploy your site.
3. Open your CloudFront URL to see your live site.
4. To add your data (Projects, Skills, CV, Testimonials):
   - Add `/admin.html` to the end of your URL.
   - Log in with your Firebase Email and Password.
   - Fill in your details.
   - Click `Save`. The main website will update instantly for all visitors!

🎉 Congratulations! You have successfully deployed a highly scalable, serverless portfolio using industry-standard DevOps practices.
