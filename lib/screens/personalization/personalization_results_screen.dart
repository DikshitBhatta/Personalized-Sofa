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
import 'package:timberr/screens/concierge/schedule_concierge_screen.dart';

class PersonalizationResultsScreen extends StatefulWidget {
  const PersonalizationResultsScreen({super.key});

  @override
  State<PersonalizationResultsScreen> createState() => _PersonalizationResultsScreenState();
}

class _PersonalizationResultsScreenState extends State<PersonalizationResultsScreen> {
  final PersonalizationController _personalizationController = Get.find();
  final HomeController _homeController = Get.find();
  
  List<Product> _recommendedProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendedProducts();
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
      }
    }
    
    return "Custom Style";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLynxWhite,
      appBar: AppBar(
        backgroundColor: kLynxWhite,
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
                          const SizedBox(height: 20),
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
                                GlbViewer(
                                  assetPath: 'assets/3dmodel/sofamodel.glb',
                                  height: 300,
                                  width: double.infinity,
                                ),
                                const SizedBox(height: 20),
                                Container(
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
                  
                  // Single action button
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to concierge scheduling screen with a smooth transition
                            Get.to(
                              () => const ScheduleConciergeScreen(),
                              transition: Transition.cupertino,
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOut,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kOffBlack,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            "Schedule a Concierge Visit",
                            style: kNunitoSans14.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
