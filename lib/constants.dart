import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

const kOffBlack = Color(0xFF303030);
const kLeadBlack = Color(0xFF212121);
const kRaisinBlack = Color(0xFF222222);
const kGrey = Color(0xFF8B8680); // Warm gray with ivory undertones
const kTinGrey = Color(0xFF9B9490); // Light warm gray
const kGraniteGrey = Color(0xFF6B645F); // Darker warm gray
const kBasaltGrey = Color(0xFFA39E99); // Medium warm gray
const kTrolleyGrey = Color(0xFF8A8580); // Warm taupe gray
const kNoghreiSilver = Color(0xFFCFC9C3); // Warm silver with ivory tones
const kChristmasSilver = Color(0xFFDED8D0); // Your requested ivory color
const kLynxWhite = Color(0xFFF5F2EE); // Warm off-white ivory
const kSnowFlakeWhite = Color(0xFFEFEBE6); // Light ivory
const kBackgroundBeige = Color(0xFFDAD2C7); // Main background color for all screens
const kSeaGreen = Color(0xFF2AA952);
const kCrayolaGreen = Color(0xFF27AE60);
const kFireOpal = Color(0xFFEB5757);
const kSilverGrey = Color(0xFF8E8E93); // For inactive bottom nav icons
const kNavBarBlack = Color(0xFF1C1C1C); // For bottom navigation bar background
const kIvoryGradientLight = Color(0xFFCEC4B6); // Light ivory for gradient
const kIvoryGradientMid = Color(0xFFC9BFB5); // Mid ivory for gradient
const kIvoryGradientDark = Color(0xFFCBC0B4); // Dark ivory for gradient

const kNunitoSans10Grey =
    TextStyle(fontFamily: "NunitoSans", fontSize: 10, color: kGrey);
const kNunitoSans12Grey =
    TextStyle(fontFamily: "NunitoSans", fontSize: 12, color: kGrey);
const kNunitoSans12TrolleyGrey =
    TextStyle(fontFamily: "NunitoSans", fontSize: 12, color: kTrolleyGrey);
const kNunitoSansSemiBold12 = TextStyle(
  fontFamily: "NunitoSans",
  fontSize: 12,
  fontWeight: FontWeight.w600,
  color: Color(0xCCFFFFFF),
);
const kNunitoSans14 = TextStyle(
  fontFamily: "NunitoSans",
  fontSize: 14,
  color: kOffBlack,
);
const kNunitoSans16 = TextStyle(
  fontFamily: "NunitoSans",
  fontSize: 14,
);
const kNunitoSansSemiBold16 = TextStyle(
  fontFamily: "NunitoSans",
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: kOffBlack,
);
const kNunitoSansSemiBold16TinGrey = TextStyle(
  fontFamily: "NunitoSans",
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: kTinGrey,
);
const kNunitoSansSemiBold16NorgheiSilver = TextStyle(
  fontFamily: "NunitoSans",
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: kNoghreiSilver,
);
const kNunitoSansBold16 = TextStyle(
  fontFamily: "NunitoSans",
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: kOffBlack,
);
const kNunitoSans18 = TextStyle(fontFamily: "NunitoSans", fontSize: 18);
const kNunitoSansTinGrey18 =
    TextStyle(fontFamily: "NunitoSans", fontSize: 18, color: kTinGrey);
const kNunitoSansBold18 = TextStyle(
  fontFamily: "NunitoSans",
  fontSize: 18,
  color: kOffBlack,
  fontWeight: FontWeight.bold,
);
const kNunitoSansSemiBold18 = TextStyle(
  fontFamily: "NunitoSans",
  fontSize: 18,
  color: kOffBlack,
  fontWeight: FontWeight.w600,
);
const kNunitoSansSemiBold20White = TextStyle(
    fontFamily: "NunitoSans",
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white);
const kNunitoSansBold20 = TextStyle(
    fontFamily: "NunitoSans",
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: kOffBlack);
const kNunitoSansBold24 = TextStyle(
    fontFamily: "NunitoSans",
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: kOffBlack);
const kMerriweatherBold16 = TextStyle(
  fontFamily: "Merriweather",
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: kOffBlack,
);
const kMerriweatherBold24 = TextStyle(
    fontFamily: "Merriweather",
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2);
const kMerriweather30TinGrey = TextStyle(
  fontFamily: "Merriweather",
  fontSize: 30,
  color: kTinGrey,
);
const kGelasio18 = TextStyle(
  fontFamily: "Gelasio",
  fontSize: 18,
);
const inputDecorationConst = InputDecoration(
  floatingLabelBehavior: FloatingLabelBehavior.always,
  labelStyle: TextStyle(
    fontFamily: "NunitoSans",
    color: kTinGrey,
  ),
  enabledBorder: UnderlineInputBorder(
    borderSide: BorderSide(
      color: kChristmasSilver,
      width: 2,
    ),
  ),
  focusedBorder: UnderlineInputBorder(
    borderSide: BorderSide(
      color: kOffBlack,
      width: 2,
    ),
  ),
  errorBorder: UnderlineInputBorder(
    borderSide: BorderSide(
      color: kFireOpal,
      width: 2,
    ),
  ),
  focusedErrorBorder: UnderlineInputBorder(
    borderSide: BorderSide(
      color: kFireOpal,
      width: 2,
    ),
  ),
);

Future<bool> kOnExitConfirmation() async {
  bool exit = false;
  await kDefaultDialog(
    "Exit",
    "Are you sure do you want to exit the app?",
    onYesPressed: () {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      exit = true;
    },
  );
  return exit;
}

Future kDefaultDialog(String title, String message,
    {VoidCallback? onYesPressed}) async {
  if (GetPlatform.isIOS) {
    await Get.dialog(
      CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (onYesPressed != null)
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Get.back();
              },
              child: const Text(
                "Cancel",
              ),
            ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: onYesPressed,
            child: Text(
              (onYesPressed == null) ? "Ok" : "Yes",
            ),
          ),
        ],
      ),
    );
  } else {
    await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (onYesPressed != null)
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: kFireOpal,
                ),
              ),
            ),
          TextButton(
            onPressed: (onYesPressed == null)
                ? () {
                    Get.back();
                  }
                : onYesPressed,
            child: Text(
              (onYesPressed == null) ? "Ok" : "Yes",
              style: const TextStyle(
                color: kOffBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
