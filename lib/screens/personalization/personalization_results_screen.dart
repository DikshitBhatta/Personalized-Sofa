import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/personalization_controller.dart';
import 'package:timberr/controllers/home_controller.dart';
import 'package:timberr/models/product.dart';
import 'package:timberr/models/personalization_data.dart' as pdata;
import 'package:timberr/widgets/tiles/product_grid_tile.dart';
import 'package:timberr/widgets/animation/fade_in_widget.dart';
import 'package:timberr/widgets/glb_viewer.dart';
import 'package:timberr/presentation/controllers/sofa_generation_controller.dart';
import 'package:timberr/domain/models/sofa_config.dart';
import 'package:timberr/models/preview_model.dart';
import 'package:timberr/widgets/pricing/sofa_price_display.dart';
// removed unused import
import 'package:timberr/widgets/buttons/custom_elevated_button.dart';
import 'package:timberr/screens/concierge/schedule_concierge_screen.dart';
import 'edit_personalization_screen.dart';

class PersonalizationResultsScreen extends StatefulWidget {
  const PersonalizationResultsScreen({super.key});

  @override
  State<PersonalizationResultsScreen> createState() => _PersonalizationResultsScreenState();
}

class _PersonalizationResultsScreenState extends State<PersonalizationResultsScreen> {
  final PersonalizationController _personalizationController = Get.find();
  final HomeController _homeController = Get.find();
  final SofaGenerationController _sofaGenCtrl = Get.put(SofaGenerationController());
  
  List<Product> _recommendedProducts = [];
  bool _isLoading = true;
  bool _hasStartedGeneration = false;
  final TextEditingController _changeNoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecommendedProducts();
    // Start generation automatically when screen opens (if not already started)
    WidgetsBinding.instance.addPostFrameCallback((_) => _startGenerationIfNeeded());
  }

  @override
  void dispose() {
    _changeNoteController.dispose();
    super.dispose();
  }

  void _startGenerationIfNeeded() async {
    if (_hasStartedGeneration) return;
    _hasStartedGeneration = true;

    // Build SofaConfig from personalization data
    final p = _personalizationController.personalizationData;
    final cfg = SofaConfig(
      targetUser: p.audienceType?.toString().split('.').last ?? 'adult',
      usageStyle: p.usageStyle?.usagePattern?.toString().split('.').last ?? 'lounging',
      seatingFeel: p.usageStyle?.firmnessPreference?.toString().split('.').last ?? 'balanced',
      capacity: p.usageStyle?.sofaCapacity?.toString().split('.').last ?? '3',
      material: p.styleMaterial?.materialType?.toString().split('.').last ?? 'linen',
      features: p.styleMaterial?.functionalityTypes?.map((e) => e.toString().split('.').last).toList() ?? [],
      color: p.personalizationDetails?.colorHex ?? 'grey',
      pattern: p.personalizationDetails?.patternType?.toString().split('.').last ?? 'jacquard',
      stitching: p.personalizationDetails?.stitchingType?.toString().split('.').last ?? 'double',
      legs: p.personalizationDetails?.legType?.toString().split('.').last ?? 'oak',
    );

    try {
      // Start with the new two-preview system instead of the old single generation
      await _sofaGenCtrl.generatePreviews(cfg);
    } catch (_) {
      // errors are surfaced via controller.errorMessage; UI will show them
    }
  }

  void _loadRecommendedProducts() {
    setState(() {
      _isLoading = true;
    });

    // Get all products and filter based on personalization data
    final allProducts = _homeController.productsList;
    final personalizationData = _personalizationController.personalizationData;
    
    // Simple recommendation logic based on personalization preferences
    List<Product> recommended = [];
    
    if (allProducts.isNotEmpty) {
      // Filter by category if we have style preferences
      if (personalizationData.styleMaterial?.materialType != null) {
        // For now, recommend sofas (category 1) since that's what we're personalizing
        recommended = allProducts.where((product) => product.categoryId == 1).toList();
      } else {
        recommended = allProducts.toList();
      }
      
      // Limit to first 6 products for better performance
      if (recommended.length > 6) {
        recommended = recommended.take(6).toList();
      }
    }

    setState(() {
      _recommendedProducts = recommended;
      _isLoading = false;
    });
  }

  Widget _buildPersonalizationSummary() {
    final personalizationData = _personalizationController.personalizationData;
    
    return Column(
      children: [
        if (personalizationData.styleMaterial?.materialType != null) ...[
          Row(
            children: [
              const Icon(Icons.texture, size: 20, color: kTinGrey),
              const SizedBox(width: 12),
              Text(
                "Material: ${_getMaterialName(personalizationData.styleMaterial!.materialType!)}",
                style: kNunitoSans14.copyWith(color: kOffBlack),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        
        if (personalizationData.personalizationDetails?.colorHex != null) ...[
          Row(
            children: [
              const Icon(Icons.palette, size: 20, color: kTinGrey),
              const SizedBox(width: 12),
              Text(
                "Custom Color Selected",
                style: kNunitoSans14.copyWith(color: kOffBlack),
              ),
              const SizedBox(width: 8),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Color(int.parse(personalizationData.personalizationDetails!.colorHex!.replaceFirst('#', ''), radix: 16) + 0xFF000000),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kGrey.withOpacity(0.3)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        
        if (personalizationData.usageStyle != null) ...[
          Row(
            children: [
              const Icon(Icons.weekend, size: 20, color: kTinGrey),
              const SizedBox(width: 12),
              Text(
                "Usage Style: ${_getUsageStyleSummary(personalizationData.usageStyle!)}",
                style: kNunitoSans14.copyWith(color: kOffBlack),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        
        Row(
          children: [
            const Icon(Icons.star, size: 20, color: kTinGrey),
            const SizedBox(width: 12),
            Text(
              "Personalized just for you!",
              style: kNunitoSans14.copyWith(color: kSeaGreen, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  String _getMaterialName(pdata.MaterialType material) {
    switch (material) {
      case pdata.MaterialType.fullGrain:
        return "Full Grain Leather";
      case pdata.MaterialType.semiAniline:
        return "Semi-Aniline Leather";
      case pdata.MaterialType.nubuck:
        return "Nubuck Leather";
      case pdata.MaterialType.pu:
        return "PU Leather";
      case pdata.MaterialType.cotton:
        return "Cotton Fabric";
      case pdata.MaterialType.linen:
        return "Linen Fabric";
      case pdata.MaterialType.velvet:
        return "Luxury Velvet";
      case pdata.MaterialType.alcantara:
        return "Alcantara";
      case pdata.MaterialType.ecoFabric:
        return "Eco-Friendly Fabric";
    }
  }

  String _getUsageStyleSummary(pdata.UsageStyleData usageStyle) {
    // Adult usage style
    if (usageStyle.usagePattern != null) {
      switch (usageStyle.usagePattern!) {
        case pdata.UsagePattern.lounging:
          return "Lounging Style";
        case pdata.UsagePattern.formalHosting:
          return "Formal Hosting";
        case pdata.UsagePattern.familyLiving:
          return "Family Living";
      }
    }
    
    // Child usage style
    if (usageStyle.childUsageType != null) {
      switch (usageStyle.childUsageType!) {
        case pdata.ChildUsageType.readingQuiet:
          return "Reading & Quiet Time";
        case pdata.ChildUsageType.playtimeTV:
          return "Playtime & TV";
        case pdata.ChildUsageType.napRest:
          return "Nap & Rest";
      }
    }
    
    // Pet usage style
    if (usageStyle.petRelaxLocation != null) {
      switch (usageStyle.petRelaxLocation!) {
        case pdata.PetRelaxLocation.besideFloor:
          return "Pet-Friendly Floor Design";
        case pdata.PetRelaxLocation.sofaCushions:
          return "Pet-Sharing Comfort";
        case pdata.PetRelaxLocation.armrestsBackrest:
          return "Pet Perch Design";
        case pdata.PetRelaxLocation.bed:
          return "Pet Bed Companion";
        case pdata.PetRelaxLocation.hiddenSpace:
          return "Pet Hide-Away Design";
      }
    }
    
    return "Custom Style";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundBeige,
      appBar: AppBar(
        backgroundColor: kBackgroundBeige,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new, color: kOffBlack, size: 20),
        ),
        centerTitle: true,
        title: Text(
          "RECOMMENDED FOR YOU",
          style: kMerriweatherBold16.copyWith(color: kOffBlack),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: kOffBlack),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Success message
                  // FadeInWidget(
                  //   child: Container(
                  //     width: double.infinity,
                  //     padding: const EdgeInsets.all(20),
                  //     decoration: BoxDecoration(
                  //       gradient: LinearGradient(
                  //         begin: Alignment.topLeft,
                  //         end: Alignment.bottomRight,
                  //         colors: [
                  //           kSeaGreen.withOpacity(0.1),
                  //           kSeaGreen.withOpacity(0.05),
                  //         ],
                  //       ),
                  //       borderRadius: BorderRadius.circular(16),
                  //       border: Border.all(color: kSeaGreen.withOpacity(0.3)),
                  //     ),
                  //     child: Column(
                  //       children: [
                  //         Container(
                  //           width: 60,
                  //           height: 60,
                  //           decoration: BoxDecoration(
                  //             color: kSeaGreen,
                  //             borderRadius: BorderRadius.circular(30),
                  //           ),
                  //           child: const Icon(
                  //             Icons.check,
                  //             color: Colors.white,
                  //             size: 30,
                  //           ),
                  //         ),
                  //         const SizedBox(height: 16),
                  //         Text(
                  //           "Personalization Complete!",
                  //           style: kNunitoSansBold20.copyWith(color: kOffBlack),
                  //         ),
                  //         const SizedBox(height: 8),
                  //         Text(
                  //           "Based on your preferences, we've curated these perfect matches for you.",
                  //           textAlign: TextAlign.center,
                  //           style: kNunitoSans14.copyWith(color: kGrey),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  
                  // const SizedBox(height: 32),
                  
                  // Your Personalization Summary
                  // if (_personalizationController.personalizationData.personalizationDetails != null)
                  //   FadeInWidget(
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           "Your Personalization",
                  //           style: kNunitoSansSemiBold18.copyWith(color: kOffBlack),
                  //         ),
                  //         const SizedBox(height: 12),
                  //         _buildPersonalizationSummary(),
                  //         const SizedBox(height: 32),
                  //       ],
                  //     ),
                  //   ),
                  
                  // Recommended Products
                  // Text(
                  //   "Recommended Products",
                  //   style: kNunitoSansSemiBold18.copyWith(color: kOffBlack),
                  // ),
                  // const SizedBox(height: 4),
                  // Text(
                  //   "Handpicked based on your preferences",
                  //   style: kNunitoSans14.copyWith(color: kGrey),
                  // ),
                  
                  // const SizedBox(height: 20),
                  
                  if (_recommendedProducts.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          // 3D Model Viewer
                          FadeInWidget(
                            child: Column(
                              children: [
                                Text(
                                  "Personalized Sofa Preview",
                                  style: kNunitoSansSemiBold18.copyWith(color: kOffBlack),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Based on your preferences,  we've curated these perfect matches for you.",
                                  style: kNunitoSans14.copyWith(color: kGrey),
                                ),
                                const SizedBox(height: 20),

                                // Personalization summary (placed right below the intro text)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: kLynxWhite,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: kGrey.withOpacity(0.2)),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.palette_outlined,
                                            color: kOffBlack,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Your Personalization",
                                            style: kNunitoSansSemiBold16.copyWith(color: kOffBlack, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _buildPersonalizationSummary(),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // NEW: Two-preview system
                                Obx(() {
                                  final generatingPreviews = _sofaGenCtrl.isGeneratingPreviews.value;
                                  final previews = _sofaGenCtrl.previewModels;
                                  final selectedIndex = _sofaGenCtrl.selectedPreviewIndex.value;
                                  final isRefining = _sofaGenCtrl.isRefining.value;
                                  final refinedModel = _sofaGenCtrl.refinedModel.value;
                                  final err = _sofaGenCtrl.errorMessage.value;

                                  // Show error state
                                  if (err != null) {
                                    return Column(
                                      children: [
                                        Text('Generation failed', style: kNunitoSans14.copyWith(color: Colors.red)),
                                        const SizedBox(height: 8),
                                        Text(err, style: kNunitoSans12Grey),
                                        const SizedBox(height: 12),
                                        GlbViewer(
                                          assetPath: 'assets/3dmodel/sofamodel.glb',
                                          height: 220,
                                          width: double.infinity,
                                        ),
                                      ],
                                    );
                                  }

                                  // Show refined model if available
                                  if (refinedModel != null && refinedModel.glbUrl != null) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Your Personalized 3D Sofa', style: kNunitoSans16.copyWith(color: kOffBlack, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        // Add error handling and fallback for refined model
                                        Stack(
                                          children: [
                                            Container(
                                              height: 300,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: kOffBlack.withOpacity(0.3)),
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Stack(
                                                  children: [
                                                    // Try to display the refined model with fallback
                                                    _buildRefinedModelDisplay(refinedModel),
                                                    // Success indicator
                                                    Positioned(
                                                      top: 8,
                                                      right: 8,
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                        decoration: BoxDecoration(
                                                          color: kSeaGreen.withOpacity(0.9),
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: Text(
                                                          'Refined Model',
                                                          style: kNunitoSans12Grey.copyWith(
                                                            color: Colors.white, 
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Price tag positioned at bottom right
                                            Positioned(
                                              bottom: 0,
                                              left: 12,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.3),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: const CompactPriceTag(
                                                  showBreakdown: false,
                                                  height: 60,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            OutlinedButton.icon(
                                              onPressed: () {
                                                Get.dialog(AlertDialog(
                                                  title: const Text('Download 3D Model'),
                                                  content: SelectableText(refinedModel.glbUrl!, style: kNunitoSans12Grey),
                                                  actions: [
                                                    TextButton(onPressed: () => Get.back(), child: const Text('Close')),
                                                  ],
                                                ));
                                              },
                                              icon: const Icon(Icons.download),
                                              label: const Text('Download'),
                                            ),
                                            const SizedBox(width: 12),
                                            OutlinedButton.icon(
                                              onPressed: () {
                                                // Try to refresh/reload the model
                                                setState(() {
                                                  // Force a rebuild to retry loading the model
                                                });
                                              },
                                              icon: const Icon(Icons.refresh),
                                              label: const Text('Refresh'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  }

                                  // Show refinement progress
                                  if (isRefining && selectedIndex != null) {
                                    return Column(
                                      children: [
                                        SizedBox(
                                          height: 24,
                                          child: LinearProgressIndicator(
                                            value: _sofaGenCtrl.refineProgress.value / 100.0,
                                            color: kSeaGreen,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text('Refining selected model: ${_sofaGenCtrl.refineProgress.value}%', 
                                             style: kNunitoSans14.copyWith(color: kTinGrey)),
                                        const SizedBox(height: 8),
                                        // Show the selected preview being refined
                                        GlbViewer(
                                          assetPath: previews[selectedIndex].basicGlbUrl ?? 'assets/3dmodel/sofamodel.glb',
                                          height: 220,
                                          width: double.infinity,
                                        ),
                                      ],
                                    );
                                  }

                                  // Show two preview options
                                  if (previews.isNotEmpty) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Choose Your Preferred Style', style: kNunitoSans16.copyWith(color: kOffBlack, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        Text('Select one of the two options below to refine', style: kNunitoSans14.copyWith(color: kGrey)),
                                        const SizedBox(height: 16),
                                        // Changed to Column layout for better visibility
                                        Column(
                                          children: [
                                            // Preview 1
                                            _buildPreviewCard(0, previews.length > 0 ? previews[0] : null),
                                            const SizedBox(height: 16),
                                            // Preview 2
                                            _buildPreviewCard(1, previews.length > 1 ? previews[1] : null),
                                          ],
                                        ),
                                      ],
                                    );
                                  }

                                  // Show preview generation progress
                                  if (generatingPreviews) {
                                    return Column(
                                      children: [
                                        Text('Generating preview options...', style: kNunitoSans16.copyWith(color: kOffBlack, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            // Preview 1 progress
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  Text('Option 1', style: kNunitoSans14.copyWith(color: kTinGrey)),
                                                  const SizedBox(height: 8),
                                                  LinearProgressIndicator(
                                                    value: _sofaGenCtrl.preview1Progress.value / 100.0,
                                                    color: kOffBlack,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text('${_sofaGenCtrl.preview1Progress.value}%', style: kNunitoSans12Grey),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            // Preview 2 progress
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  Text('Option 2', style: kNunitoSans14.copyWith(color: kTinGrey)),
                                                  const SizedBox(height: 8),
                                                  LinearProgressIndicator(
                                                    value: _sofaGenCtrl.preview2Progress.value / 100.0,
                                                    color: kOffBlack,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text('${_sofaGenCtrl.preview2Progress.value}%', style: kNunitoSans12Grey),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        GlbViewer(
                                          assetPath: 'assets/3dmodel/sofamodel.glb',
                                          height: 220,
                                          width: double.infinity,
                                        ),
                                      ],
                                    );
                                  }

                                  // Default state - show placeholder
                                  return GlbViewer(
                                    assetPath: 'assets/3dmodel/sofamodel.glb',
                                    height: 300,
                                    width: double.infinity,
                                  );
                                }),
                                const SizedBox(height: 20),
                                  // Generate previews button (calls the new two-preview flow)
                                  Obx(() {
                                    final generatingPreviews = _sofaGenCtrl.isGeneratingPreviews.value;
                                    final hasRefinedModel = _sofaGenCtrl.refinedModel.value != null;
                                    final hasPreviews = _sofaGenCtrl.previewModels.isNotEmpty;
                                    
                                    // Don't show button if we already have a refined model
                                    if (hasRefinedModel) {
                                      return const SizedBox.shrink();
                                    }
                                    
                                    // Don't show button if we already have previews
                                    if (hasPreviews) {
                                      return const SizedBox.shrink();
                                    }
                                    
                                    return SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: generatingPreviews ? null : () async {
                                          // Build SofaConfig from personalization data
                                          final p = _personalizationController.personalizationData;
                                          final cfg = SofaConfig(
                                            targetUser: p.audienceType?.toString().split('.').last ?? 'adult',
                                            usageStyle: p.usageStyle?.usagePattern?.toString().split('.').last ?? 'lounging',
                                            seatingFeel: p.usageStyle?.firmnessPreference?.toString().split('.').last ?? 'balanced',
                                            capacity: p.usageStyle?.sofaCapacity?.toString().split('.').last ?? '3',
                                            material: p.styleMaterial?.materialType?.toString().split('.').last ?? 'linen',
                                            features: p.styleMaterial?.functionalityTypes?.map((e) => e.toString().split('.').last).toList() ?? [],
                                            color: p.personalizationDetails?.colorHex ?? 'grey',
                                            pattern: p.personalizationDetails?.patternType?.toString().split('.').last ?? 'jacquard',
                                            stitching: p.personalizationDetails?.stitchingType?.toString().split('.').last ?? 'double',
                                            legs: p.personalizationDetails?.legType?.toString().split('.').last ?? 'oak',
                                          );

                                          await _sofaGenCtrl.generatePreviews(cfg);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kOffBlack,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                        ),
                                        child: Text(
                                          generatingPreviews ? 'Generating Preview Options…' : 'Generate Preview Options',
                                          style: kNunitoSans14.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                const SizedBox(height: 16),

                                // Edit Personalization Button - Moved above note
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          Get.to(() => const EditPersonalizationScreen());
                                        },
                                        icon: const Icon(Icons.edit, size: 18),
                                        label: const Text('Edit Personalization'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: kOffBlack,
                                          side: BorderSide(color: kOffBlack),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Note and custom preferences input
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: kSnowFlakeWhite,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: kGrey.withOpacity(0.12)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Note",
                                        style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "This is an initial 3D model. Please mention your change preferences/additional preferences below.",
                                        style: kNunitoSans14.copyWith(color: kGrey),
                                      ),
                                      const SizedBox(height: 12),
                                      TextField(
                                        controller: _changeNoteController,
                                        maxLines: 3,
                                        decoration: InputDecoration(
                                          hintText: 'E.g., prefer firmer cushions, change leg color to oak',
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              // Save the note to final preferences
                        final existing = _personalizationController.personalizationData.finalPreferences;
                        final updated = existing != null
                          ? pdata.FinalPreferences(
                            whatMattersMost: existing.whatMattersMost,
                            washableReplaceableCovers: existing.washableReplaceableCovers,
                            ecoFriendly: existing.ecoFriendly,
                            changePreferencesNote: _changeNoteController.text,
                          )
                          : pdata.FinalPreferences(changePreferencesNote: _changeNoteController.text);
                        _personalizationController.setFinalPreferences(updated);
                                              Get.snackbar('Saved', 'Your change preferences have been saved', snackPosition: SnackPosition.BOTTOM);
                                            },
                                            style: ElevatedButton.styleFrom(backgroundColor: kOffBlack),
                                            child: Text('Save Preferences', style: kNunitoSans14.copyWith(color: Colors.white)),
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.55,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      itemCount: _recommendedProducts.length,
                      itemBuilder: (context, index) {
                        return FadeInWidget(
                          child: ProductGridTile(
                            product: _recommendedProducts[index],
                            heroMode: false,
                          ),
                        );
                      },
                    ),
                  
                  const SizedBox(height: 40),
                  
                  // Concierge Button - Only show when refined model is available
                  GetBuilder<SofaGenerationController>(
                    builder: (controller) {
                      final refinedModel = controller.refinedModel.value;
                      if (refinedModel != null && refinedModel.glbUrl != null) {
                        return Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    kOffBlack.withOpacity(0.1),
                                    kOffBlack.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: kOffBlack.withOpacity(0.3)),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: kOffBlack,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Icon(Icons.support_agent, color: Colors.white),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Ready for Next Step?",
                                              style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
                                            ),
                                            Text(
                                              "Schedule a concierge visit to finalize your order",
                                              style: kNunitoSans14.copyWith(color: kTinGrey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: CustomElevatedButton(
                                      onTap: () {
                                        Get.to(
                                          () => const ScheduleConciergeScreen(),
                                          transition: Transition.cupertino,
                                          duration: const Duration(milliseconds: 600),
                                          curve: Curves.easeOut,
                                        );
                                      },
                                      text: "Schedule a Concierge Visit",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  
                ],
              ),
            ),
    );
  }

  Widget _buildPreviewCard(int index, PreviewModel? preview) {
    final isSelected = _sofaGenCtrl.selectedPreviewIndex.value == index;
    final isGenerating = _sofaGenCtrl.isGeneratingPreviews.value;
    
    return Container(
      height: 300, // Fixed height for better layout
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? kSeaGreen : kGrey.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: kSeaGreen.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Column(
        children: [
          // Preview image/model area
          Expanded(
            flex: 3, // Give more space to the 3D model
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                color: kSnowFlakeWhite,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: preview != null 
                  ? _buildPreviewModelDisplay(preview)
                  : _buildLoadingOrFallback(isGenerating, index),
              ),
            ),
          ),
          // Selection button area
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              color: isSelected ? kSeaGreen.withOpacity(0.1) : Colors.white,
            ),
            child: Column(
              children: [
                Text(
                  'Option ${index + 1}',
                  style: kNunitoSans14.copyWith(
                    color: isSelected ? kSeaGreen : kOffBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (preview != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    preview.basicGlbUrl != null ? 'GLB Model Ready' : 'Thumbnail Available',
                    style: kNunitoSans12Grey,
                  ),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: preview != null && !isGenerating && !_sofaGenCtrl.isRefining.value
                        ? () => _selectPreview(index)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? kSeaGreen : kOffBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      isSelected ? 'Selected' : 'Select & Refine',
                      style: kNunitoSans14.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewModelDisplay(PreviewModel preview) {
    print('PersonalizationResultsScreen: _buildPreviewModelDisplay called');
    print('  - Preview basicGlbUrl: ${preview.basicGlbUrl}');
    print('  - Preview thumbnailUrl: ${preview.thumbnailUrl}');
    
    // Check if GLB is a local file (cached) or remote URL
    final isLocalGlb = preview.basicGlbUrl != null && 
                      preview.basicGlbUrl!.isNotEmpty && 
                      !preview.basicGlbUrl!.startsWith('http');
    
    print('  - GLB is local file: $isLocalGlb');
    
    // Prioritize local GLB files over remote ones due to CORS issues
    if (isLocalGlb) {
      print('PersonalizationResultsScreen: Displaying local GLB model: ${preview.basicGlbUrl}');
      return Stack(
        children: [
          GlbViewer(
            assetPath: preview.basicGlbUrl!,
            height: double.infinity,
            width: double.infinity,
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: kSeaGreen.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '3D Model',
                style: kNunitoSans12Grey.copyWith(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      );
    } else if (preview.thumbnailUrl != null && preview.thumbnailUrl!.isNotEmpty) {
      print('PersonalizationResultsScreen: Displaying thumbnail (GLB has CORS issues): ${preview.thumbnailUrl}');
      return Stack(
        children: [
          Image.network(
            preview.thumbnailUrl!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Text('Loading preview...', style: kNunitoSans12Grey),
                  ],
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              print('PersonalizationResultsScreen: Thumbnail load failed: $error');
              return _buildErrorFallback('Preview failed to load');
            },
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Preview',
                style: kNunitoSans12Grey.copyWith(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      );
    } else if (preview.basicGlbUrl != null && preview.basicGlbUrl!.isNotEmpty) {
      print('PersonalizationResultsScreen: Trying remote GLB (may have CORS issues): ${preview.basicGlbUrl}');
      return Stack(
        children: [
          GlbViewer(
            assetPath: preview.basicGlbUrl!,
            height: double.infinity,
            width: double.infinity,
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Remote GLB',
                style: kNunitoSans12Grey.copyWith(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      );
    } else {
      print('PersonalizationResultsScreen: No preview data available');
      return _buildErrorFallback('No preview data available');
    }
  }

  Widget _buildErrorFallback(String message) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: kSnowFlakeWhite,
        border: Border.all(color: Colors.red.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 32),
          const SizedBox(height: 8),
          Text(
            'Preview Failed',
            style: kNunitoSans14.copyWith(color: Colors.red, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: kNunitoSans12Grey,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          GlbViewer(
            assetPath: 'assets/3dmodel/sofamodel.glb',
            height: 100,
            width: 100,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOrFallback(bool isGenerating, int index) {
    if (isGenerating) {
      final progress1 = _sofaGenCtrl.preview1Progress.value;
      final progress2 = _sofaGenCtrl.preview2Progress.value;
      final currentProgress = index == 0 ? progress1 : progress2;
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              value: currentProgress > 0 ? currentProgress / 100.0 : null,
            ),
            const SizedBox(height: 12),
            Text(
              'Generating Option ${index + 1}...',
              style: kNunitoSans14.copyWith(color: kTinGrey, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              '$currentProgress%',
              style: kNunitoSans12Grey,
            ),
          ],
        ),
      );
    } else {
      return GlbViewer(
        assetPath: 'assets/3dmodel/sofamodel.glb',
        height: double.infinity,
        width: double.infinity,
      );
    }
  }

  void _selectPreview(int index) async {
    final p = _personalizationController.personalizationData;
    final cfg = SofaConfig(
      targetUser: p.audienceType?.toString().split('.').last ?? 'adult',
      usageStyle: p.usageStyle?.usagePattern?.toString().split('.').last ?? 'lounging',
      seatingFeel: p.usageStyle?.firmnessPreference?.toString().split('.').last ?? 'balanced',
      capacity: p.usageStyle?.sofaCapacity?.toString().split('.').last ?? '3',
      material: p.styleMaterial?.materialType?.toString().split('.').last ?? 'linen',
      features: p.styleMaterial?.functionalityTypes?.map((e) => e.toString().split('.').last).toList() ?? [],
      color: p.personalizationDetails?.colorHex ?? 'grey',
      pattern: p.personalizationDetails?.patternType?.toString().split('.').last ?? 'jacquard',
      stitching: p.personalizationDetails?.stitchingType?.toString().split('.').last ?? 'double',
      legs: p.personalizationDetails?.legType?.toString().split('.').last ?? 'oak',
    );

    await _sofaGenCtrl.selectAndRefinePreview(index, cfg, personalizationData: p);
  }

  Widget _buildRefinedModelDisplay(refinedModel) {
    final glbUrl = refinedModel.glbUrl;
    final thumbnailUrl = refinedModel.thumbnailUrl;
    
    print('PersonalizationResultsScreen: _buildRefinedModelDisplay called');
    print('  - Refined GLB URL: $glbUrl');
    print('  - Refined thumbnail URL: $thumbnailUrl');
    
    // Check if GLB is a local file (cached) or remote URL
    final isLocalGlb = glbUrl != null && 
                      glbUrl.isNotEmpty && 
                      !glbUrl.startsWith('http');
    
    print('  - GLB is local file: $isLocalGlb');
    
    // Prioritize local GLB files over remote ones due to CORS issues
    if (isLocalGlb) {
      print('PersonalizationResultsScreen: Displaying local refined GLB model: $glbUrl');
      return GlbViewer(
        assetPath: glbUrl,
        height: double.infinity,
        width: double.infinity,
      );
    } else if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      print('PersonalizationResultsScreen: Displaying refined thumbnail (GLB has CORS issues): $thumbnailUrl');
      return Image.network(
        thumbnailUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
                const SizedBox(height: 8),
                Text('Loading refined model...', style: kNunitoSans12Grey),
              ],
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('PersonalizationResultsScreen: Refined thumbnail load failed: $error');
          // Fallback to trying the GLB anyway
          if (glbUrl != null && glbUrl.isNotEmpty) {
            print('PersonalizationResultsScreen: Falling back to remote GLB for refined model');
            return GlbViewer(
              assetPath: glbUrl,
              height: double.infinity,
              width: double.infinity,
            );
          }
          return _buildRefinedErrorFallback('Refined model failed to load');
        },
      );
    } else if (glbUrl != null && glbUrl.isNotEmpty) {
      print('PersonalizationResultsScreen: Trying remote GLB for refined model (may have CORS issues): $glbUrl');
      return GlbViewer(
        assetPath: glbUrl,
        height: double.infinity,
        width: double.infinity,
      );
    } else {
      print('PersonalizationResultsScreen: No refined model data available');
      return _buildRefinedErrorFallback('No refined model data available');
    }
  }

  Widget _buildRefinedErrorFallback(String message) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: kSnowFlakeWhite,
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_outlined, color: Colors.orange, size: 32),
          const SizedBox(height: 8),
          Text(
            'Model Loading Issue',
            style: kNunitoSans14.copyWith(color: Colors.orange, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: kNunitoSans12Grey,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Fallback Model:',
            style: kNunitoSans12Grey.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          GlbViewer(
            assetPath: 'assets/3dmodel/sofamodel.glb',
            height: 120,
            width: 120,
          ),
        ],
      ),
    );
  }
}
