# �️ Me Sofa - Personalized AI Sofa Design Platform

**Me Sofa** is an innovative Flutter-based mobile application that revolutionizes furniture shopping by combining AI-powered personalization, 3D visualization, and professional concierge services. Built with Firebase, GetX state management, and cutting-edge 3D rendering technology, Me Sofa offers users a completely personalized sofa customization experience.

## 🌟 What Makes Me Sofa Special

Me Sofa goes beyond traditional furniture shopping by understanding your emotional preferences, lifestyle needs, and space requirements to create the perfect sofa just for you. Our AI-powered personalization engine analyzes your responses and generates customized 3D models in real-time.

## ✨ Core Features

### 🎨 AI-Powered Personalization
- **Emotion-Based Color Selection**: Our AI analyzes your emotional preferences and recommends color palettes that match your mood and personality
- **Lifestyle Analysis**: 8-step personalization flow that understands your living space, family size, pets, and usage patterns
- **Smart Recommendations**: Intelligent fabric, pattern, and finish suggestions based on your lifestyle
- **Color Tone Detection**: Advanced algorithms detect and suggest complementary color tones for your space

### 🎯 3D Sofa Visualization
- **Real-Time 3D Models**: Interactive GLB (GL Transmission Format) models that you can rotate, zoom, and inspect
- **Fullscreen 3D View**: Immersive 3D viewing experience with gesture controls
- **Material Preview**: See exactly how different fabrics, patterns, and finishes look on your sofa
- **Dynamic Model Generation**: Sofa models are generated on-the-fly based on your selections
- **AR Preview**: (Coming Soon) Visualize your sofa in your actual space using augmented reality

### 🤖 AI Chatbot Assistant
- **24/7 Support**: Intelligent chatbot powered by AI to answer your questions anytime
- **Design Guidance**: Get expert advice on color combinations, fabric choices, and style recommendations
- **Order Assistance**: Help with order tracking, payment queries, and delivery information
- **Unread Message Tracking**: Never miss important updates from our support team

### � Professional Concierge Service
- **Personal Design Consultants**: Book appointments with expert interior designers
- **In-Home Visits**: Schedule consultants to visit your home for personalized recommendations
- **Virtual Consultations**: Connect via video call for remote design assistance
- **Appointment Management**: Easy booking, rescheduling, and tracking of concierge visits
- **QR Code Payment**: Secure payment verification with base64-encoded image storage
- **Real-Time Chat**: Direct messaging with your assigned concierge

### 🔐 Authentication & User Management
- **Firebase Authentication**: Secure email/password authentication
- **Profile Customization**: Update profile pictures, personal information, and preferences
- **Order History**: Track all your purchases and customization history
- **Address Management**: Save multiple delivery addresses for convenience

### 🛒 Shopping & Orders
- **Smart Cart**: Add personalized sofas to cart with all customization details preserved
- **Multiple Payment Options**: Flexible payment methods including QR code verification
- **Order Tracking**: Real-time order status updates and delivery tracking
- **Admin Dashboard**: Comprehensive order management system for administrators

### 🏠 Interior Renovation Section
- **Design Inspiration**: Browse curated interior design ideas and trends
- **Room Visualization**: See how different sofa styles fit various room aesthetics
- **Style Matching**: Find sofas that complement your existing interior design

### 🎨 Advanced Customization
- **Fabric Selection**: Choose from premium fabrics including velvet, linen, leather, and more
- **Pattern Options**: Apply patterns like chevron, herringbone, geometric, and floral
- **Finish Choices**: Select from wood finishes (walnut, oak, mahogany) and metal options
- **Leg Styles**: Customize sofa legs with different materials and designs
- **Color Palette**: Your personalized color recommendations based on emotional analysis

### 📱 User Experience
- **Smooth Animations**: Lottie animations for delightful loading experiences
- **Intuitive Navigation**: Custom curved bottom navigation bar with smooth transitions
- **Responsive Design**: Optimized for various screen sizes and devices
- **Offline Support**: Local caching for 3D models and user preferences
- **Push Notifications**: Firebase Cloud Messaging for order updates and offers

### � User Experience
- **Smooth Animations**: Lottie animations for delightful loading experiences
- **Intuitive Navigation**: Custom curved bottom navigation bar with smooth transitions
- **Responsive Design**: Optimized for various screen sizes and devices
- **Offline Support**: Local caching for 3D models and user preferences
- **Push Notifications**: Firebase Cloud Messaging for order updates and offers

## 🏗️ Technical Architecture

### Frontend
- **Framework**: Flutter (Dart)
- **State Management**: GetX
- **3D Rendering**: GLB model viewer with gesture controls
- **Animations**: Lottie animations
- **Image Handling**: Cached network images, base64 encoding for secure storage

### Backend & Services
- **Authentication**: Firebase Authentication
- **Database**: Cloud Firestore (NoSQL)
- **Storage**: Cloud Firestore (base64 encoding for images under 1MB)
- **Notifications**: Firebase Cloud Messaging (FCM)
- **Security**: Firestore Security Rules with granular permissions

### Key Technical Implementations
- **Lazy Loading**: 3D models and images loaded on-demand for performance
- **State Persistence**: User preferences and cart data cached locally
- **Service Initialization**: Smart GetX dependency injection with fallback mechanisms
- **Error Handling**: Comprehensive try-catch patterns for robust user experience
- **Image Compression**: Automatic image optimization before storage
- **Secure Data Storage**: Base64 encoding for payment verification images

## 🔌 Core Dependencies

| Package | Purpose | Version |
|---------|---------|---------|
| [**get**](https://pub.dev/packages/get) | State management, dependency injection, and routing | Latest |
| [**firebase_core**](https://pub.dev/packages/firebase_core) | Firebase SDK initialization | ^2.32.0 |
| [**firebase_auth**](https://pub.dev/packages/firebase_auth) | User authentication | ^4.20.0 |
| [**cloud_firestore**](https://pub.dev/packages/cloud_firestore) | NoSQL database | Latest |
| [**firebase_storage**](https://pub.dev/packages/firebase_storage) | Cloud file storage | ^11.7.7 |
| [**firebase_messaging**](https://pub.dev/packages/firebase_messaging) | Push notifications | ^14.9.4 |
| [**cached_network_image**](https://pub.dev/packages/cached_network_image) | Efficient image caching | Latest |
| [**lottie**](https://pub.dev/packages/lottie) | Beautiful animations | Latest |
| [**image_picker**](https://pub.dev/packages/image_picker) | Camera and gallery access | Latest |
| [**geolocator**](https://pub.dev/packages/geolocator) | Location services | Latest |
| [**google_maps_flutter**](https://pub.dev/packages/google_maps_flutter) | Map integration | Latest |
| [**url_launcher**](https://pub.dev/packages/url_launcher) | External URL handling | Latest |
| [**permission_handler**](https://pub.dev/packages/permission_handler) | Runtime permissions | Latest |
| [**webview_flutter**](https://pub.dev/packages/webview_flutter) | 3D model rendering | Latest |

## 📂 Project Structure

```
lib/
├── main.dart                          # App entry point
├── wrapper.dart                       # Authentication wrapper
├── constants.dart                     # Global constants
│
├── Admin/                             # Admin dashboard & management
│   ├── AdminDashboard.dart
│   ├── concierge_management.dart
│   └── controllers/
│
├── api/                               # API service layer
│   └── gemini_api.dart               # AI integration
│
├── bindings/                          # GetX dependency injection
│   ├── initial_binding.dart
│   └── home_binding.dart
│
├── chatbot/                           # AI chatbot feature
│   ├── screens/
│   ├── widgets/
│   └── controllers/
│
├── concierge_chat/                    # Concierge messaging
│   ├── controllers/
│   └── screens/
│
├── controllers/                       # Business logic controllers
│   ├── auth_controller.dart
│   ├── payment_controller.dart
│   ├── personalization_controller.dart
│   └── splash_controller.dart
│
├── core/                              # Core configurations
│   └── config/
│       └── sofa.json                 # Sofa configuration data
│
├── models/                            # Data models
│   └── sofa_config.dart
│
├── screens/                           # UI screens
│   ├── home.dart
│   ├── fullscreen_3d_view.dart
│   ├── concierge/                    # Concierge booking screens
│   ├── orders/                       # Order management screens
│   ├── personalization/              # 8-step personalization flow
│   └── profile/                      # User profile screens
│
├── services/                          # Service layer
│   ├── init_services.dart            # Service initialization
│   ├── order_service.dart
│   └── search_service.dart
│
├── utils/                             # Utility functions
│   ├── color_tone_detector.dart
│   └── emotion_color_picker.dart
│
├── widgets/                           # Reusable widgets
│   ├── glb_viewer.dart               # 3D model viewer
│   ├── input/
│   ├── sections/
│   └── tabbed/
│
└── Notification/                      # Push notification system
    ├── controllers/
    └── services/

assets/
├── 3dmodel/                           # GLB 3D models
├── fabrics/                           # Fabric textures
├── materials/                         # Material textures
│   ├── finish/
│   ├── legs/
│   ├── pattern/
│   └── stetching/
├── fonts/                             # Custom fonts
├── icons/                             # App icons
└── lottie/                            # Animation files
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Firebase account
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/DikshitBhatta/Personalized-Sofa.git
   cd Personalized-Sofa
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup** ⚠️ **IMPORTANT**
   
   Me Sofa requires Firebase configuration files that are **NOT** included in this repository for security reasons.
   
   Please follow the detailed instructions in [SECURITY_SETUP.md](SECURITY_SETUP.md) to:
   - Set up your Firebase project
   - Download and configure `google-services.json` (Android)
   - Download and configure `GoogleService-Info.plist` (iOS)
   - Set up `firebase_config.dart` for FCM
   - Configure Firestore security rules

4. **Run the app**
   ```bash
   # For development
   flutter run

   # For release build
   flutter build apk --release  # Android
   flutter build ios --release  # iOS
   ```

## 🔐 Security & Configuration

### Important Security Notes

⚠️ **NEVER commit these files to version control:**
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/core/config/firebase_config.dart`
- Any file containing API keys or secrets

### Setting Up Firebase (Required)

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication, Firestore, Storage, and Cloud Messaging
3. Download configuration files and place them in the correct locations
4. See [SECURITY_SETUP.md](SECURITY_SETUP.md) for detailed instructions

### Example Configuration Files

Example templates are provided:
- `android/app/google-services.json.example`
- `ios/Runner/GoogleService-Info.plist.example`
- `lib/core/config/firebase_config.dart.example`

Copy these files, remove the `.example` extension, and fill in your actual Firebase credentials.

## 📊 Database Schema

### Firestore Collections

- **users**: User profiles and preferences
- **orders**: Order history and status
- **concierge_bookings**: Concierge appointment details
- **concierge_chats**: Real-time chat messages
- **notifications**: User notifications
- **chatbot_conversations**: AI chatbot interaction history
- **sofa_configurations**: Saved sofa customizations

### Security Rules

Firestore security rules are defined in `firestore.rules` and include:
- User-specific data access
- Role-based permissions for admin
- Read/write restrictions based on authentication
- List permissions for queries

Deploy rules using:
```bash
firebase deploy --only firestore:rules
```

## 🎨 Personalization Flow

The app features an 8-step personalization journey:

1. **Welcome**: Introduction to the personalization process
2. **Lifestyle Analysis**: Understanding usage patterns (family, pets, frequency)
3. **Room Type**: Identifying the space (living room, bedroom, office)
4. **Emotion Selection**: Choosing desired emotional ambiance
5. **Color Preferences**: AI-powered color palette generation
6. **Fabric Selection**: Material choice based on lifestyle
7. **Pattern & Finish**: Detailed customization options
8. **3D Preview**: Interactive visualization of your custom sofa

## 🛠️ Development

### Code Architecture

- **MVVM Pattern**: Model-View-ViewModel architecture
- **GetX State Management**: Reactive state updates
- **Service Layer**: Separation of business logic
- **Repository Pattern**: Data abstraction layer

### Key Design Patterns

- **Singleton**: Service classes (AuthService, OrderService)
- **Factory**: Model creation from JSON
- **Observer**: GetX reactive state management
- **Dependency Injection**: GetX bindings

### Running Tests

```bash
flutter test
```

### Code Quality

```bash
# Analyze code
flutter analyze

# Format code
flutter format lib/
```

## � Features Roadmap

### ✅ Completed
- [x] Firebase Authentication
- [x] AI-Powered Personalization (8 steps)
- [x] 3D Sofa Visualization (GLB models)
- [x] Real-time 3D Model Generation
- [x] Emotion-Based Color Selection
- [x] AI Chatbot Assistant
- [x] Professional Concierge Service
- [x] Concierge Booking & Scheduling
- [x] Real-Time Concierge Chat
- [x] QR Code Payment Verification
- [x] Base64 Image Storage (< 1MB)
- [x] Admin Dashboard
- [x] Order Management System
- [x] Push Notifications (FCM)
- [x] Shopping Cart
- [x] Address Management
- [x] Profile Customization
- [x] Interior Renovation Section
- [x] Smooth Animations (Lottie)
- [x] 3D Model Caching
- [x] Offline Support### 🚧 In Progress
- [ ] Augmented Reality (AR) Preview
- [ ] Payment Gateway Integration (Razorpay/Stripe)
- [ ] Product Reviews System
- [ ] Social Sharing Features
- [ ] Multi-language Support

### 🔮 Future Plans
- [ ] Dark Mode Theme
- [ ] Tablet/Web Responsive Design
- [ ] Voice-Controlled Customization
- [ ] AI Interior Design Suggestions
- [ ] Virtual Showroom Tours
- [ ] Social Community Features
- [ ] Loyalty Program Integration
- [ ] Export 3D Models (STL/OBJ)
- [ ] Wishlist & Favorites
- [ ] Price Comparison Tools

## 🤝 Contributing

We welcome contributions! If you'd like to contribute to Me Sofa:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and development process.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Dikshit Bhatta

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 👨‍💻 Authors & Contributors

**[Dikshit Bhatta](https://github.com/DikshitBhatta)** - *Lead Developer & Creator*

See also the list of [contributors](https://github.com/DikshitBhatta/Personalized-Sofa/contributors) who participated in this project.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend infrastructure
- GetX community for state management solutions
- All open-source contributors whose packages made this possible
- AI/ML researchers whose work inspired our personalization algorithms

## 📞 Support & Contact

- **Issues**: [GitHub Issues](https://github.com/DikshitBhatta/Personalized-Sofa/issues)
- **Discussions**: [GitHub Discussions](https://github.com/DikshitBhatta/Personalized-Sofa/discussions)
- **Email**: support@mesofa.com (for business inquiries)

## 🔒 Security

If you discover a security vulnerability, please email security@mesofa.com instead of using the issue tracker.

See [SECURITY.md](SECURITY.md) for more details on our security policies.

## 📚 Documentation

- [Security Setup Guide](SECURITY_SETUP.md) - Firebase configuration and security
- [Contributing Guidelines](CONTRIBUTING.md) - How to contribute
- [Code of Conduct](CODE_OF_CONDUCT.md) - Community guidelines

## 📊 Project Stats

![GitHub stars](https://img.shields.io/github/stars/DikshitBhatta/Personalized-Sofa?style=social)
![GitHub forks](https://img.shields.io/github/forks/DikshitBhatta/Personalized-Sofa?style=social)
![GitHub issues](https://img.shields.io/github/issues/DikshitBhatta/Personalized-Sofa)
![GitHub pull requests](https://img.shields.io/github/issues-pr/DikshitBhatta/Personalized-Sofa)
![License](https://img.shields.io/github/license/DikshitBhatta/Personalized-Sofa)

## 🌐 Links

- [Project Website](#) (Coming Soon)
- [API Documentation](#) (Coming Soon)
- [User Guide](#) (Coming Soon)

---

<div align="center">

**Made with ❤️ by the Me Sofa Team**

*Revolutionizing furniture shopping, one personalized sofa at a time*

</div>
