import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/home_controller.dart';
import 'package:timberr/controllers/personalization_controller.dart';
import 'package:timberr/screens/cart/cart_screen.dart';
import 'package:timberr/screens/search_delegate/product_search_delegate.dart';
import 'package:timberr/widgets/tabbed/curved_bottom_navbar.dart';
import 'package:timberr/widgets/tiles/product_grid_tile.dart';
import 'package:timberr/widgets/sections/renovate_interior_section.dart';
import 'package:timberr/widgets/sections/your_palette_section.dart';
import 'package:timberr/widgets/sections/image_slider_widget.dart';
import 'package:timberr/chatbot/widgets/chatbot_floating_button.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  final HomeController _controller = Get.find();
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    // Reload color from Firestore when home screen is loaded
    _reloadPersonalizationColor();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Also reload when dependencies change (e.g., coming back from another route)
    _reloadPersonalizationColor();
  }
  
  void _reloadPersonalizationColor() {
    try {
      final personalizationController = Get.find<PersonalizationController>();
      personalizationController.reloadColorFromFirestore();
    } catch (e) {
      print('PersonalizationController not found: $e');
    }
  }
  
  void _onCartTap() {
    Get.to(
            () => CartScreen(),
      transition: Transition.fade,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return PopScope(
      canPop: false,
      onPopInvoked: (_) => kOnExitConfirmation(),
      child: Scaffold(
        backgroundColor: kBackgroundBeige,
        bottomNavigationBar: const CurvedBottomNavBar(
          selectedPos: 0,
        ),
        body: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  leading: IconButton(
                    onPressed: () {
                      showSearch(
                          context: context, delegate: ProductSearchDelegate());
                    },
                    icon: SvgPicture.asset(
                      'assets/icons/search_icon_grey.svg',
                    ),
                  ),
                  title: Column(
                    children: [
                      Text(
                        'Make home',
                        style: kGelasio18.copyWith(
                          color: kTinGrey,
                        ),
                      ),
                      Text(
                        'BEAUTIFUL',
                        style: kGelasio18.copyWith(
                          fontWeight: FontWeight.bold,
                          color: kOffBlack,
                        ),
                      ),
                    ],
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      onPressed: _onCartTap,
                      icon: SvgPicture.asset(
                        'assets/icons/cart_icon_grey.svg',
                      ),
                    )
                  ],
                  // bottom: PreferredSize(
                  //     preferredSize: const Size(double.infinity, 65),
                  //     child: CategoryTabBar()),
                  floating: true,
                  snap: true,
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: Obx(() {
                    return SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.55,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 18,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return ProductGridTile(
                            product: _controller.productsList.elementAt(index),
                          );
                        },
                        childCount: _controller.productsList.length,
                      ),
                    );
                  }),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 10),
                ),
                
                // Renovate Interior Section
                SliverToBoxAdapter(
                  child: RenovateInteriorSection(),
                ),
                
                // Your Palette Today Section
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: YourPaletteSection(),
                  ),
                ),
                  
                // Image Slider Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ImageSliderWidget(),
                  ),
                ),
              ],
            ),
            
            // Chatbot floating button
            const ChatbotFloatingButton(),
          ],
        ),
      ),
    );
  }
}
