import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/controllers/personalization_controller.dart';
import 'package:timberr/models/personalization_data.dart';
import 'package:timberr/screens/personalization/personalization_step1.dart';

class PersonalizationFlowScreen extends StatefulWidget {
  final AudienceType? preSelectedAudience;

  const PersonalizationFlowScreen({super.key, this.preSelectedAudience});

  @override
  State<PersonalizationFlowScreen> createState() => _PersonalizationFlowScreenState();
}

class _PersonalizationFlowScreenState extends State<PersonalizationFlowScreen> {
  @override
  void initState() {
    super.initState();
    // Set the audience type after the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.preSelectedAudience != null) {
        final controller = Get.find<PersonalizationController>();
        controller.setAudienceType(widget.preSelectedAudience!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use the existing controller from HomeBinding instead of creating a new one
    // This ensures color changes persist across navigation
    if (!Get.isRegistered<PersonalizationController>()) {
      Get.put(PersonalizationController());
    }
    
    // Navigate to step 1
    return PersonalizationStep1Screen();
  }
}
