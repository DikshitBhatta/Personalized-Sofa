import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/address_controller.dart';
import 'package:timberr/screens/input/enhanced_add_shipping_screen.dart';
import 'package:timberr/widgets/cards/address_card.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  final AddressController _addressController = Get.find<AddressController>();

  @override
  void initState() {
    super.initState();
    // Fetch addresses when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addressController.fetchAddresses();
    });
  }

  void _addOnTap() async {
    await Get.to(
      () => const EnhancedAddShippingScreen(),
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
    );
    // Refresh addresses when returning from add screen
    await _addressController.fetchAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundBeige,
      appBar: AppBar(
        backgroundColor: kBackgroundBeige,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: kOffBlack,
            size: 20,
          ),
        ),
        centerTitle: true,
        title: const Text(
          "SHIPPING ADDRESS",
          style: kMerriweatherBold16,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addOnTap,
        elevation: 8,
        backgroundColor: Colors.white,
        foregroundColor: kOffBlack,
        child: const Icon(
          Icons.add,
          size: 34,
        ),
      ),
      body: GetBuilder<AddressController>(builder: (addressController) {
        if (addressController.addressList.isEmpty) {
          return Center(
            child: Text(
              "No Shipping Addresses have been entered",
              style: kNunitoSans14.copyWith(
                color: kGrey,
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: addressController.addressList.length,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemBuilder: (context, index) {
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      child: Checkbox(
                        value: (addressController.selectedIndex == index)
                            ? true
                            : false,
                        onChanged: (isSelected) {
                          addressController.setDefaultShippingAddress(index);
                        },
                        activeColor: kOffBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        splashRadius: 20,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    Text(
                      "Use as the shipping address",
                      style: kNunitoSans18.copyWith(
                        color: kGrey,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                AddressCard(
                  address: addressController.addressList[index],
                  index: index,
                ),
                const SizedBox(height: 30),
              ],
            );
          },
        );
      }),
    );
  }
}
