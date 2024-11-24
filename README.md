

### **BuildArc Onboarding Instructions**

**Overview**  
BuildArc is a proof of concept (PoC) for a construction drawing management system. It serves as a lightweight alternative to off-the-shelf solutions like **ACC Build**, **Procore**, and **Fieldwire**.

This PoC includes features such as:
- **Drawing Catalog Management**
- **Detailed Annotation and Collaboration**
- **Offline Mode with Sync Support**

The system leverages Firestore as the backend database, providing robust offline capabilities and seamless synchronization across devices.

---

### **Prerequisites**
These instructions assume you are a senior developer familiar with essential tools and workflows. For example, before cloning the repository, ensure your GitHub public key is added. If you're unsure about generating or adding SSH keys, consult resources like Google or GPT.

---

### **Step-by-Step Instructions**

#### **1. Clone the Repository**
1. Visit the repository on GitHub:  
   [BuildArc Repository](https://github.com/ripplearc/buildarc)
2. Clone the repository using SSH (preferred):
   ```bash
   git clone git@github.com:ripplearc/buildarc.git
   ```  
    - **Note:** The clone process may take time, as it includes files for the Firebase Storage Emulator.

---

#### **2. Install Dependencies**
Make sure the following dependencies are installed:
1. **CocoaPods** (for iOS development):
   ```bash
   brew install cocoapods
   ```  
2. **Flutter SDK:**  
   Follow the official [Flutter installation guide](https://flutter.dev/docs/get-started/install) for your platform.
3. **Firebase Tools:**  
   Install globally via npm:
   ```bash
   npm install -g firebase-tools
   ```

---

#### **3. Configure Firebase**
1. **Login to Firebase:**
   ```bash
   firebase login
   ```  
2. **Initialize Firebase in the Project:**  
   From the project directory:
   ```bash
   firebase init
   ```  
    - **When prompted for emulator option, select the following tools:**
        - Authentication
        - Firestore
        - Storage
        - Hosting
    - After setup, discard any changes made to `firebase.json`

---

#### **4. Set Up Firebase Emulator**
1. Add the following shortcut to your terminal configuration file (e.g., `.zshrc` or `.bashrc`):
   ```bash
   alias start_firebase_emulator='firebase emulators:start --import=.firebase/emulator/export --export-on-exit'
   ```  
    - This ensures a smoother workflow for starting the emulator.

2. Reload your terminal configuration:
   ```bash
   source ~/.zshrc
   ```  

3. Start the Firebase Emulator:
   ```bash
   start_firebase_emulator
   ```  

4. Open the Emulator UI to browse Firestore or Storage content.

---

#### **5. Run the Flutter App**
1. Run the Flutter app:
   ```bash
   flutter run
   ```  

2. Select **Chrome** when prompted to choose a device.

---

#### **6. Access the App**
- **Credentials:**
    - **Username:** `construculator@gmail.com`
    - **Password:** `123456`

---
