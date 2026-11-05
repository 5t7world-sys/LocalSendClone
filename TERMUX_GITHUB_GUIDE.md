# 📱 Termux से GitHub Repository Update करने का Complete Guide

## 🎯 Overview

Aap Termux से directly apni GitHub repository ko update kar sakte ho. Main aapko **step-by-step** bataunga kaise karna hai.

---

## ✅ Prerequisites Check

Pehle check karo ki ye sab installed hai:

```bash
# Termux version check
termux-info

# Git installed hai?
git --version

# GitHub CLI installed hai? (optional but helpful)
gh --version
```

Agar git nahi hai to install karo:
```bash
pkg update
pkg install git
```

---

## 📂 Step 1: Repository Clone/Setup

### **Option A: Fresh Clone (Recommended)**

```bash
# 1. Home directory mein jao
cd ~

# 2. Repository clone karo
git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git

# Example:
# git clone https://github.com/johndoe/localsend-clone.git

# 3. Repository folder mein enter karo
cd YOUR_REPO_NAME
```

### **Option B: Existing Folder ko Git Repository banao**

Agar aapke paas already LocalSendClone folder hai:

```bash
# 1. Apne project folder mein jao
cd /storage/emulated/0/MT2/apks/LocalSendClone

# 2. Git initialize karo (agar pehle se nahi hai)
git init

# 3. GitHub remote add karo
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git

# 4. Current files track karo
git add .
git commit -m "Initial commit"

# 5. Push karo (pehli baar)
git branch -M main
git push -u origin main
```

---

## 🔐 Step 2: GitHub Authentication Setup

GitHub par push karne ke liye authentication chahiye:

### **Method 1: Personal Access Token (PAT) - Recommended**

```bash
# 1. GitHub par jao: Settings → Developer settings → Personal access tokens → Tokens (classic)
# 2. "Generate new token" click karo
# 3. Scopes select karo: repo (full control)
# 4. Token copy karo (ghp_xxxxxxxxxxxx jaisa)

# 5. Git config set karo
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 6. Credential helper setup (token save karne ke liye)
git config --global credential.helper store
```

**First push ke time token use karo:**
```bash
git push origin main

# Username: your_github_username
# Password: ghp_your_personal_access_token  (yahan token paste karo)
```

Token ek baar save ho jayega, phir dubara nahi puchega.

---

## 📝 Step 3: Files Update Karna

Ab main aapko **har file update karne ka exact method** batata hoon:

---

### 📄 **File 1: android/build.gradle**

```bash
# 1. Directory structure create karo (agar nahi hai)
mkdir -p android

# 2. File create/edit karo
nano android/build.gradle

# 3. Nano editor mein ye code paste karo:
# (Ctrl+O se save, Enter press, Ctrl+X se exit)
```

**File content:**
```gradle
buildscript {
    ext.kotlin_version = '1.9.22'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.4'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = '../build'
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
    project.evaluationDependsOn(':app')
}

tasks.register("clean", Delete) {
    delete rootProject.buildDir
}
```

**Save kaise kare:**
- `Ctrl + O` (write Out)
- `Enter` (confirm filename)
- `Ctrl + X` (exit)

---

### 📄 **File 2: android/settings.gradle**

```bash
# File create karo
nano android/settings.gradle
```

**File content:**
```gradle
pluginManagement {
    def flutterSdkPath = {
        def properties = new Properties()
        file("local.properties").withInputStream { properties.load(it) }
        def flutterSdkPath = properties.getProperty("flutter.sdk")
        assert flutterSdkPath != null, "flutter.sdk not set in local.properties"
        return flutterSdkPath
    }
    settings.ext.flutterSdkPath = flutterSdkPath()

    includeBuild("${settings.ext.flutterSdkPath}/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    plugins {
        id "dev.flutter.flutter-gradle-plugin" version "1.0.0" apply false
    }
}

plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.1.4" apply false
    id "org.jetbrains.kotlin.android" version "1.9.22" apply false
}

include ":app"
```

---

### 📄 **File 3: android/gradle.properties**

```bash
nano android/gradle.properties
```

**File content:**
```properties
org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=1G -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
android.enableJetifier=true
android.enableR8.fullMode=true
org.gradle.daemon=true
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.configureondemand=true
```

---

### 📄 **File 4: android/gradle/wrapper/gradle-wrapper.properties**

```bash
# Directory banao
mkdir -p android/gradle/wrapper

# File create karo
nano android/gradle/wrapper/gradle-wrapper.properties
```

**File content:**
```properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.3-all.zip
```

---

### 📄 **File 5: android/app/build.gradle**

```bash
# Directory banao
mkdir -p android/app

# File edit karo
nano android/app/build.gradle
```

**File content:** (Bahut badi hai, isliye alternative method use karenge)

---

## 🚀 **Smart Method: Script se Files Create Karo**

Typing kam karne ke liye, main aapko ek script dunga jo sab files automatically create kar dega:

```bash
# 1. Script file banao
nano create_android_files.sh

# 2. Niche diya hua script paste karo
# 3. Save karo (Ctrl+O, Enter, Ctrl+X)

# 4. Script ko executable banao
chmod +x create_android_files.sh

# 5. Script run karo
./create_android_files.sh
```

---

### 📜 **Complete Automation Script**

**File:** `create_android_files.sh`

Main aapko ek complete script provide karunga jo sab files create kar degi.

Kyunki files bahut lambi hain, main aapko **better approach** suggest karta hoon:

---

## 💡 **Best Method: Direct Copy from Current Location**

Aapke LocalSendClone folder mein already sab files create ho chuki hain! Unhe simply GitHub repo mein copy karo:

```bash
# 1. Apne GitHub repo folder mein jao
cd ~/YOUR_REPO_NAME

# 2. Android folder ko copy karo
cp -r /storage/emulated/0/MT2/apks/LocalSendClone/android ./

# 3. Verify karo files copy hui ya nahi
ls -la android/
ls -la android/app/

# 4. Git mein add karo
git add android/

# 5. Changes dekho
git status

# 6. Commit karo
git commit -m "Android Embedding v2: Complete configuration

- Updated Gradle to 8.1.4
- Updated Kotlin to 1.9.22
- Added Java 17 support
- Implemented FlutterActivity
- Fixed all plugin compatibility issues
- Added AndroidX dependencies"

# 7. GitHub par push karo
git push origin main
```

---

## 🔍 Step 4: Verify Upload

Upload ke baad verify karo:

```bash
# Git log dekho
git log --oneline -5

# Remote status check karo
git remote -v

# Branch check karo
git branch -a
```

GitHub website par jao aur verify karo ki files update hui hain:
- Go to: `https://github.com/YOUR_USERNAME/YOUR_REPO_NAME`
- Check: `android/` folder
- Verify: All 8 files present

---

## 📋 Individual File Update Commands

Agar aapko sirf kuch specific files update karni hain:

### **Single File Update:**

```bash
# 1. File edit karo
nano android/app/build.gradle

# 2. Changes karo

# 3. Save karo (Ctrl+O, Enter, Ctrl+X)

# 4. Git add karo
git add android/app/build.gradle

# 5. Commit karo
git commit -m "Update app build.gradle"

# 6. Push karo
git push origin main
```

---

## 🎯 **Recommended Full Workflow**

Complete process ek saath:

```bash
# ========================================
# COMPLETE GITHUB UPDATE WORKFLOW
# ========================================

# Step 1: Navigate to your local project
cd /storage/emulated/0/MT2/apks/LocalSendClone

# Step 2: Initialize git (if not already done)
git init

# Step 3: Configure git
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Step 4: Add remote
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git

# Step 5: Add all files
git add .

# Step 6: Commit
git commit -m "LocalSend Clone - Complete implementation with Android Embedding v2"

# Step 7: Set branch
git branch -M main

# Step 8: Push (first time)
git push -u origin main

# It will ask:
# Username: your_github_username
# Password: ghp_your_token_here (paste your PAT)
```

---

## 🔄 **Future Updates (Quick Commands)**

Agle baar se sirf ye commands use karo:

```bash
# 1. Changes check karo
git status

# 2. Modified files add karo
git add .

# 3. Commit karo with message
git commit -m "Your update message"

# 4. Push karo
git push origin main
```

---

## 📱 **Termux Helpful Commands**

### **File Navigation:**
```bash
# Current directory
pwd

# List files
ls -la

# Change directory
cd folder_name

# Go back
cd ..

# Go to home
cd ~
```

### **File Editing:**
```bash
# Nano editor (easy)
nano filename

# View file content
cat filename

# View file with pagination
less filename
```

### **Git Commands:**
```bash
# Status check
git status

# View changes
git diff

# View commit history
git log --oneline

# Undo changes (before commit)
git checkout -- filename

# Pull latest changes
git pull origin main
```

---

## 🛠️ **Troubleshooting**

### **Problem 1: Permission Denied**
```bash
# Solution: Storage permission de do
termux-setup-storage

# Phir access karo
cd /storage/emulated/0/
```

### **Problem 2: Git Push Failed**
```bash
# Solution: Force push (careful!)
git push -f origin main

# Ya phir pull karo pehle
git pull origin main --rebase
git push origin main
```

### **Problem 3: Merge Conflicts**
```bash
# Status dekho
git status

# Conflicted files edit karo
nano conflicted_file

# Markers (<<<<, ====, >>>>) remove karo
# Correct code rakho

# Add karo
git add conflicted_file

# Commit karo
git commit -m "Resolve merge conflict"

# Push karo
git push origin main
```

### **Problem 4: Authentication Failed**
```bash
# New token banao GitHub par
# Credential helper clear karo
git config --global --unset credential.helper

# Dubara push karo
git push origin main
# Naya token enter karo
```

---

## ✅ **Complete Checklist**

- [ ] Termux installed
- [ ] Git installed (`pkg install git`)
- [ ] Storage permission granted (`termux-setup-storage`)
- [ ] Git configured (name, email)
- [ ] GitHub PAT created
- [ ] Repository cloned/initialized
- [ ] Files updated
- [ ] Changes committed
- [ ] Pushed to GitHub
- [ ] Verified on GitHub website

---

## 📝 **Quick Reference Card**

```bash
# Essential Commands (Save ye!)

# Setup (one time)
pkg install git
git config --global user.name "Name"
git config --global user.email "email"
git clone https://github.com/username/repo.git

# Daily workflow
cd ~/repo_folder
git status
git add .
git commit -m "message"
git push origin main

# View & Edit
ls -la
nano filename
cat filename

# Navigation
cd folder_name
cd ..
pwd
```

---

## 🎊 **Ready to Go!**

Ab aap Termux se apni puri GitHub repository manage kar sakte ho!

**Next Steps:**
1. Repository clone/setup karo
2. Android files copy karo
3. Commit aur push karo
4. GitHub par verify karo

**Status:** ✅ **Complete Guide Ready!**

Happy Coding from Termux! 📱🚀
