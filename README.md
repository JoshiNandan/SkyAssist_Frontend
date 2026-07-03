# SkyAssist – Self-Service Flight Recovery Platform

SkyAssist is a **self-service flight disruption recovery platform** designed to help airline passengers manage disrupted journeys without depending entirely on airport support counters or call centers.

The platform allows passengers to:
- **lookup their disrupted booking** using **PNR + last name**
- **view journey / disruption status**
- complete **OTP verification**
- choose an appropriate recovery path:
  - **Rebook**
  - **Refund**
  - **Contact Support**
- receive a **recovery slip / reference** for the action performed

SkyAssist is built as a **product-engineering style solution** for airline irregular operations, focusing on **usability, business value, clean recovery workflows, and engineering clarity**.

---

# Table of Contents

- [1. Problem Statement](#1-problem-statement)
- [2. Solution Overview](#2-solution-overview)
- [3. Key Features](#3-key-features)
- [4. User Journey](#4-user-journey)
- [5. Tech Stack](#5-tech-stack)
- [6. System Architecture](#6-system-architecture)
- [7. Repository Structure](#7-repository-structure)
- [8. API Overview](#8-api-overview)
- [9. Database / Data Model Overview](#9-database--data-model-overview)
- [10. Demo / Hosted Deployment](#10-demo--hosted-deployment)
- [11. Test Data / Demo Credentials](#11-test-data--demo-credentials)
- [12. Setup Instructions](#12-setup-instructions)
- [13. Build Instructions](#13-build-instructions)
- [14. Assumptions](#14-assumptions)
- [15. Known Limitations](#15-known-limitations)
- [16. Future Enhancements](#16-future-enhancements)
- [17. Screenshots](#17-screenshots)
- [18. AI Tools Used](#18-ai-tools-used)

---

# 1. Problem Statement

Flight disruptions such as **cancellations**, **delays**, and **operational changes** create significant stress for passengers and increase the workload on airline support teams. In many cases, passengers must stand in long airport queues or call support just to perform basic recovery actions such as:

- checking whether their booking is affected
- rebooking to an alternate flight
- requesting a refund
- raising a support request

This creates friction for both the **passenger** and the **airline**.

## Goal of SkyAssist
SkyAssist aims to provide a **self-service recovery experience** where a passenger can independently complete the most common disruption recovery actions in a guided, secure, and trackable way.

---

# 2. Solution Overview

SkyAssist is a **mobile-first flight recovery platform** built using **Flutter** for the frontend and **Node.js + Express + MongoDB** for the backend.

The app supports a passenger-facing workflow where the user:

1. enters **PNR + last name**
2. retrieves the disrupted booking
3. views booking and disruption details
4. selects a recovery option based on eligibility
5. completes **OTP verification**
6. finishes the chosen recovery action
7. receives a **slip / reference summary** for the request

The current implementation focuses on **three primary recovery paths**:

- **Refund**
- **Support Request**
- **Rebooking to alternate flights**

---

# 3. Key Features

## Passenger Booking Lookup
- Lookup booking using **PNR + last name**
- View booking details and disruption status
- Recent search support for quicker access

## Journey Status / Disruption Awareness
- Displays the passenger’s booking and recovery-relevant details
- Supports different booking scenarios such as:
  - cancelled flight
  - delayed flight
  - on-time booking

## OTP Verification Flow
- Recovery actions are protected using OTP verification
- OTP is requested and then verified before sensitive actions proceed

## Refund Flow
- Passenger can request a refund for eligible disrupted bookings
- Refund response generates a **recovery slip / reference**

## Contact Support Flow
- Passenger can raise a support request with a reason
- Support request also generates a **recovery slip / reference**

## Rebooking Flow
- Passenger can view alternate flight options
- Rebooking logic supports **fare-aware recovery handling**
- Covers scenarios such as:
  - lower fare / direct rebook
  - equal fare / direct rebook
  - higher fare / pending fare adjustment flow

## Recovery Slip / Reference Generation
For recovery actions, the system generates a **slip / reference object** containing request details so the passenger has a record of the action taken.

---

# 4. User Journey

The intended passenger journey in SkyAssist is:

1. **Launch app**
2. **Enter booking details**
   - PNR
   - last name
3. **Lookup disrupted booking**
4. **View booking / journey status**
5. **Choose recovery option**
   - Refund
   - Contact Support
   - Rebook
6. **Verify OTP**
7. **Complete selected action**
8. **View recovery result + generated slip/reference**

---

# 5. Tech Stack

## Frontend
- **Flutter**
- **Dart**
- **Provider** for state management
- **SharedPreferences** / local persistence for recent searches

## Backend
- **Node.js**
- **Express.js**
- **MongoDB Atlas**
- **Mongoose**

## Deployment / Infrastructure
- **Render** for backend hosting
- **MongoDB Atlas** for cloud database hosting

## API Style
- **REST APIs**
- JSON request / response structure

---

# 6. System Architecture

SkyAssist follows a simple mobile + API + database architecture.

## High-level architecture
- **Flutter Mobile App**
  - booking lookup UI
  - recovery flow UI
  - OTP verification UI
  - slip / success screens

- **Express Backend**
  - booking lookup APIs
  - alternate flight APIs
  - OTP request / verify APIs
  - refund / support / rebook APIs
  - recovery slip generation logic

- **MongoDB Atlas**
  - booking data
  - alternate flight data
  - recovery request data

## Architecture diagram
<img width="1536" height="1024" alt="ChatGPT Image Jul 3, 2026, 07_42_56 AM" src="https://github.com/user-attachments/assets/8ef1bb36-914f-4f94-a570-451f4fd4dd8b" />


---

# 7. Repository Structure


## Frontend (Flutter)
```text
skyassist-frontend/
├─ lib/
│  ├─ constants/
│  │  └─ api_constants.dart
│  ├─ models/
│  │  ├─ booking_model.dart
│  │  ├─ alternate_flight_model.dart
│  │  └─ recent_search_model.dart
│  ├─ providers/
│  │  └─ recovery_provider.dart
│  ├─ screens/
│  │  ├─ booking_lookup_screen.dart
│  │  ├─ journey_status_screen.dart
│  │  ├─ otp_verification_screen.dart
│  │  ├─ alternate_flights_screen.dart
│  │  ├─ recovery_success_screen.dart
│  │  └─ ...
│  ├─ services/
│  │  ├─ api_service.dart
│  │  └─ local_storage_service.dart
│  └─ main.dart
├─ android/
├─ pubspec.yaml
└─ README.md
```


## Backend(Node.js / Express)
```text
skyassist-backend/
├─ src/
│  ├─ controllers/
│  │  ├─ bookingController.js
│  │  └─ recoveryController.js
│  ├─ models/
│  │  ├─ Booking.js
│  │  ├─ AlternateFlight.js
│  │  └─ RecoveryRequest.js
│  ├─ routes/
│  │  ├─ bookingRoutes.js
│  │  └─ recoveryRoutes.js
│  ├─ seed/
│  │  └─ seedData.js
│  ├─ config/
│  │  └─ db.js
│  └─ server.js
├─ package.json
└─ README.md
```

---

# 8. API Overview

## Booking Lookup
  POST base_url/api/bookings/lookup
  
  Used to retrieve a booking using:
  pnr
  lastName

## Alternate Flights
  GET base_url/api/recovery/:bookingId/alternatives
  
  Returns alternate flight options for eligible rebooking scenarios.

## OTP
  POST base_url/api/recovery/request-otp
  
  Requests an OTP for a booking recovery action.

  POST base_url/api/recovery/verify-otp
  
  Verifies the OTP entered by the user.

## Refund
  POST base_url/api/recovery/refund
  
  Creates a refund recovery request for an eligible booking.

## Support
  POST base_url/api/recovery/support
  
  Creates a support request for an eligible booking.

## Rebook
  POST base_url/api/recovery/rebook
  
  Attempts to rebook the passenger to a selected alternate flight.

(base_url will be in section 10)

---

# 9. Database / Data Model Overview

SkyAssist currently uses a MongoDB-based design with three primary data entities.

## Booking

### Represents a passenger booking and stores:

booking ID

PNR

passenger last name

flight / journey details

disruption status

recovery eligibility information

OTP-related verification state

recovery status metadata

## AlternateFlight

### Represents alternate flights offered to a disrupted booking:

alternate flight ID

route / timing details

fare details

fare comparison data

## RecoveryRequest

### Represents a passenger recovery action such as:

refund request

support request

rebooking request

slip / reference tracking metadata


<img width="1536" height="1024" alt="ChatGPT Image Jul 3, 2026, 07_56_05 AM" src="https://github.com/user-attachments/assets/e7067ef2-ef8f-4b8b-8d36-f878f24a1889" />

---

# 10. Demo / Hosted Deployment

## Hosted Backend
SkyAssist backend is deployed on Render:

### Base URL

https://skyassist-gwfb.onrender.com

Note: On free / sleeping infrastructure, the first request may take slightly longer if the service is waking up.

---

# 11. Test Data / Demo Credentials

## The application contains seeded demo bookings for evaluation.

### Cancelled Booking

#### Use this to test:

booking lookup

refund flow

support flow

rebooking flow

slip generation

-PNR: SJ784P

-Last Name: Joshi

### Delayed Booking:
   
#### Use this to test:

booking lookup

journey status

eligibility / ineligible recovery behavior depending on flow rules

-PNR: SJ555D

-Last Name: Sharma

### On-Time Booking

#### Use this to test:

booking lookup

ineligible recovery handling for non-disrupted journeys

-PNR: SJ111N

-Last Name: Patel

---

# 12. Setup Instructions

A) Backend Setup
1. Clone the backend repository
git clone <backend-repo-url>
cd skyassist-backend

2. Install dependencies
npm install

3. Create .env
Create a .env file in the backend root and add the required variables:

PORT=5000

MONGODB_URI=<your_mongodb_connection_string>

4. Seed sample data
If the project includes a seed script, run the seed command as per your backend configuration.
Example:

npm run seed

6. Start backend
npm start
If using development mode:

npm run dev

B) Frontend Setup

1. Clone the frontend repository
git clone <frontend-repo-url>
cd skyassist-frontend

2. Install dependencies
flutter pub get

3. Configure backend URL
Open:
lib/constants/api_constants.dart

Set:
static const String baseUrl = 'https://skyassist-gwfb.onrender.com';
For local backend testing, you can change this to your local backend URL.

4. Run Flutter app
flutter run

---

# 13. Build Instructions

-Android APK

flutter clean

flutter pub get

flutter build apk --release

-Generated APK location:

build/app/outputs/flutter-apk/app-release.apk

-Windows Desktop Build

flutter config --enable-windows-desktop

flutter clean

flutter pub get

flutter build windows --release


-Generated desktop build location:

build/windows/x64/runner/Release

---

# 14. Assumptions

The current implementation makes the following assumptions for the challenge/demo environment:

1. Booking data is seeded / simulated for evaluation purposes rather than integrated with a live airline reservation system.
2. OTP flow is demo-oriented and not connected to a real telecom/SMS/email gateway.
3. Recovery eligibility logic is based on the current mocked booking/disruption scenarios.
4. Fare comparison for rebooking is handled within the current project scope and does not integrate with a live airline pricing / revenue management engine.
5. Slip / reference generation is implemented as an application-level recovery confirmation artifact for the demo workflow.
6. Payment collection for higher-fare rebooking is represented as a recovery workflow state rather than a real payment gateway integration.

---

# 15. Known Limitations
1. The current project uses demo / seeded booking data rather than a production airline inventory or PSS integration.
2. OTP verification is implemented for the challenge workflow and does not currently connect to a real communication provider.
3. The app is focused on core recovery journeys and does not yet include a full passenger profile, wallet, loyalty, or ticket history system.
4. Higher-fare rebooking is represented as a workflow / slip state and not as a full payment collection module.
5. The backend is hosted on Render, so on free infrastructure the first request may be slower if the service is sleeping.
6. The project currently focuses on the passenger self-service layer and does not yet include an airline staff / admin operations dashboard.

---

# 16. Future Enhancements

SkyAssist can be extended in several ways to become a more enterprise-grade airline recovery platform.

## Product Enhancements
1. real airline reservation / PSS integration
2. real-time flight status and disruption feeds
3. multilingual support
4. personalized recovery recommendations
5. push notifications / SMS / email updates
6. airport / support desk assisted handoff flow

## Engineering Enhancements
1. real OTP delivery integration
2. payment integration for higher-fare rebooking
3. improved recovery rules engine
4. admin / airline operations dashboard
5. audit logs and analytics
6. CI/CD pipeline and automated test coverage expansion
7. role-based internal support tooling
8. web version for desktop/browser-based passenger access

---

# 17. Screenshots

Keep these placeholders empty for now and insert screenshots later.

1. Splash / App Entry

<img width="680" height="1400" alt="image" src="https://github.com/user-attachments/assets/721fcc66-6b06-4a2a-933d-eef2c38ade3e" />


2. Booking Lookup Screen

<img width="420" height="1000" alt="image" src="https://github.com/user-attachments/assets/57290788-0ec8-4853-8c44-bc0c526a8d86" />

<img width="420" height="1000" alt="image" src="https://github.com/user-attachments/assets/b7a7d88d-23e0-49ae-aec0-a7e1f3215a0c" />

3. Journey Status Screen

-Flight Cancelled:

<img width="438" height="880" alt="image" src="https://github.com/user-attachments/assets/9de3c593-0e30-40ff-a9ab-2d7a9e97b198" />

-Flight Delayed:

<img width="438" height="880" alt="image" src="https://github.com/user-attachments/assets/d46112f7-41c1-48a2-9c4a-018e0f0e9534" />

-Flight on time:

<img width="438" height="880" alt="image" src="https://github.com/user-attachments/assets/54d30121-b81a-4e1e-a843-d552662775fc" />

4. OTP Verification Screen

<img width="680" height="1400" alt="image" src="https://github.com/user-attachments/assets/70e04f22-939b-4135-9568-ab50a8e3d0c4" />

5. Alternate Flights / Rebook Screen

<img width="420" height="1000" alt="image" src="https://github.com/user-attachments/assets/14484cb2-c591-4873-a4d2-05a0b5e91293" />

<img width="420" height="1000" alt="image" src="https://github.com/user-attachments/assets/b584f49a-375d-45ff-b262-6e56a47bb2d5" />

6. Refund Success / Slip

<img width="420" height="1000" alt="image" src="https://github.com/user-attachments/assets/be2b4a72-86b9-4ceb-9598-a71a7b562438" />

<img width="680" height="1400" alt="image" src="https://github.com/user-attachments/assets/a0a4d8c8-0a29-4026-920b-a2be7610cf16" />

<img width="374" height="1080" alt="image" src="https://github.com/user-attachments/assets/65e08623-f751-4065-baa3-e0a1c4186ec6" />

7. Support Success / Slip

<img width="420" height="1000" alt="image" src="https://github.com/user-attachments/assets/16c8dd01-3402-4449-a076-ca9f08cffa27" />

<img width="680" height="1400" alt="image" src="https://github.com/user-attachments/assets/f8f2ce2e-e0db-4885-a005-a7f0f300cf33" />

<img width="374" height="1080" alt="image" src="https://github.com/user-attachments/assets/b5227ac9-ec04-43b7-be9b-777b4874bd3f" />


8. Rebook Success / Slip

<img width="420" height="1000" alt="image" src="https://github.com/user-attachments/assets/33161f15-30a4-484d-9168-4be707801578" />

<img width="357" height="1080" alt="image" src="https://github.com/user-attachments/assets/ac9a5c8c-700d-487f-9272-ba37fdb3ac52" />

---


# 18. AI Tools Used
The following AI-assisted engineering tools were used during the development of SkyAssist:
ChatGPT
Claude / Antigravity
Amazon Q

These tools were used to assist with:

brainstorming architecture and recovery flows
refining UI / UX prompts
generating implementation guidance
debugging integration issues
improving documentation structure

All final implementation decisions, integration, testing, and submission preparation were performed as part of the project workflow.
