<div align="center">
  <h1>🚧 Facial Recognition Missing Person Finder</h1>
</div>

> An intelligent tool leveraging **facial recognition** to locate missing persons.

<div align="center">
  <img src="face_id.jfif" alt="recognizing face image" width="300">
</div>


> **Final Year Project** | Software Engineering at AASTU

This project aims to help in **search and rescue operations** by leveraging **facial recognition technology** to assist in finding missing persons. The system supports **image-based searches**, filtering, and real-time notifications.

---

## 📑 Table of Contents

[🧐 About](#-about)

[✨ Key Features](#-key-features)

[💻 Technologies Used](#-technologies-used)

[⚙ Getting Started](#-getting-started)

[🚀 Usage](#-usage)

[🤝 Contributing](#-contributing)

[📜 License](#-license)

---

## 🧐 About

This repository contains the source code and documentation for the **Facial Recognition Missing Person Finder**, a tool developed as part of the final year project for a Bachelor's degree in Software Engineering at **AASTU**.

The goal is to leverage advanced **facial recognition** and **text matching** to locate missing individuals. It serves as a valuable tool for **search and rescue teams**, enhancing their efficiency and outreach.

---

## ✨ Key Features

**📄 Submit Missing Person Posts**: Easily create a post about a missing person, visible to everyone.

**💬 Profile Chatting**: Message the person who posted the missing case directly from the profile.

**🔍 Image & Feature-Based Search**: Search for missing persons using **image recognition** or by filtering based on age, name, gender, and more.

**🎛 Filtering Options**: Narrow down your search by specifying features such as age, weight, gender, and skin color.

**🔗 Matching**: Input individual descriptions to receive possible matches with a confidence score based on database entries.

**⚙️ Case Management**: Keep track of all the cases you’ve posted and update them as necessary.

**📬 Notifications**: Receive real-time updates when new cases are added, or statuses change.

**🛠 Admin Dashboard**: Allows admins to manage users, monitor cases, and review logs.

---

## 💻 Technologies Used

**Frontend**:

🟦 React

🎨 Tailwind CSS

📱 Flutter

🔥 Firebase

**Backend**:


🟩 Node.js

🍃 MongoDB

**Facial Recognition**:

🖼 Open-source `face-api.js` for facial recognition

**Description Matching**:

📝 Transformers for text and description matching

---

## ⚙ Getting Started

Here’s how to get a local copy of the project running on your machine.

### Prerequisites

Ensure you have the following installed:
- [Node.js](https://nodejs.org/)
- [MongoDB](https://www.mongodb.com/)
- [Flutter SDK](https://flutter.dev/docs/get-started/install)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/CapStoneProject-Missing-People/Missing-individual.git
   cd Missing-individual
   ```

2. **Backend Setup**:

   - Navigate to `missingFeature`:
     ```bash
     cd missingFeature
     npm install
     ```

   - Create a `.env` file with the following:
     ```
     dbUri=your-mongodb-connection-string
     PORT=4000
     PRIV_KEY=your-private-key-for-jwt
     ACCESS_TOKEN_SECRET=your-access-token-secret
     ```

   - Start the backend server:
     ```bash
     npm start
     ```

   - Open a new terminal and navigate to `face-recognition/`:
     ```bash
     cd face-recognition
     npm install
     ```

   - Create another `.env` file:
     ```
     dbUri=your-mongodb-connection-string
     PORT=6000
     ```

   - Start the face recognition service:
     ```bash
     npm start
     ```

3. **Frontend Setup**:

   - Navigate to the Flutter app directory:
     ```bash
     cd Frontend/missingpersonapp
     flutter pub clean
     flutter pub get
     ```

   - In `Frontend/missingpersonapp/lib/features/authentication/utils/constants.dart`, add:
     ```dart
     const String postUri = 'http://localhost:4000';
     const String faceApi = 'http://localhost:6000';
     const String wsUri = 'localhost:4000';
     ```

   - Run the Flutter app:
     ```bash
     flutter run
     ```

> **Note**: If using a physical device, ensure it is connected to the same Wi-Fi as the server and replace `localhost` with your machine’s IP address.

---

## 🚀 Usage

### How to Use the App

1. **Post a Case**: Navigate to the **Post Case** section, upload a photo and enter the missing person's details.
2. **Search for a Missing Person**: Search by uploading a photo or entering details like name, age, and gender.
3. **Receive Notifications**: Get notifications on case updates or status changes.

---

## 🤝 Contributing

We welcome contributions! Feel free to **open issues** or submit **pull requests** to improve this project.

---

**Screenshots and Demo**

<!-- Add images or GIF/video demo here -->
<table align="center">
  <tr>
  <td><img src="https://ucb5ccbda82bc976eb7d38f9fa00.previews.dropboxusercontent.com/p/thumb/ACZ9zAdZ0gp7QTskPuLXKKcQCiEpd_YorEoijv-iHV4uHj8iepxlW-qWMabxuizG1KbeKS4ZEa_PHpLZ94PPdMzx8S7nq-GPZl-adf1FI4wL4R12bdmG90QsYB-OwjJCRXBaCe98sZX9i2uoy0ZmUCvGp2_cZU7o1r3nvIvIxqikTiGC_IkdaRomxTW8g5lxfvIun1o7NiRCs_ez74akzqiiM9qGTbfj3_6lHcpfYX_y-TgaLBkwdltfQgDJwcuGwW4T-RRuW_2rxerb15ciljqref6RLDIsgjUpR-ftECCwCbb_tdJg-xgyHpq1zGttrRacb3DTGLoCdRmP0ow3_tiPw-6013lerTrVcBtwT4FJTsu0XviLst_8ez9UZ5pJBmxsDHCfiSI3-cF0o8rZkgKV/p.jpeg?is_prewarmed=true" alt="Add Post Page" width="300"/></td>
  <td><img src="https://ucca51228b7d74b178cc096db352.previews.dropboxusercontent.com/p/thumb/ACZAQzchFT2jbAByOfzUxnIl5vcoCzDjIPIhA_z44QhO4e-vRJrirG0K_pxOKwfKjCRHvY4keFlLW9gZF0lf2hxcILThfnWDnvMMx1icV--VnUBaTJ04ia6jAp6ICrk9o7XoI-cFxx0qqorFcvmWWC__x7qs5nBgyzQaWPWXTJJL16lCJa_U7-Em49dI14lKRsbwAl0kIRaoQmrcg4a8aFG0hxz1lDKVvE4bB88rhPzhET7Zig3w-NKhjD1RsxrjI1ub9kDwXoMZKIG2j8XZoz5VIAP9qOPZ676bMzo-UnSX4in-W6T3GtaVnnXf0WhwPgsBIPaIEFqsEGWOnkdlNntgniG9i2l7dQp6ruv7POqTYVH-sDLRVdnnHh4bMn-6pM4shsXlb7PfUIYkj2z_F5vK/p.jpeg?is_prewarmed=true" alt="Notification page" width="300"/></td>
</tr>
</table>

---

### 🎥 Watch the demo on Youtube:

> **Note**: If you'd like to open the video or link in a new tab, you can right-click the link and select **"Open link in new tab"**, or use **Ctrl + Click** (on Windows/Linux) or **Cmd + Click** (on macOS).

<a href="https://www.youtube.com/watch?v=pBoSRwMv704" target="_blank">
  click here
  <img width=300 src="https://img.youtube.com/vi/pBoSRwMv704/0.jpg" alt="Watch the video" />
</a>

---

**Contact**: [Leulseged B. Ayalew](mailto:leulbekele191@gmail.com)

---

## 📜 License
Apache-2.0 license

