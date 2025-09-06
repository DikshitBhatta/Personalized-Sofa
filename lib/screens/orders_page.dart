import 'package:flutter/material.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/widgets/cards/order_card.dart';
import 'package:timberr/widgets/tabbed/curved_bottom_navbar.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: PopScope(
        canPop: false,
        onPopInvoked: (_) => kOnExitConfirmation(),
        child: Scaffold(
          appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            "MY ORDERS",
            style: kMerriweatherBold16,
          ),
          bottom: TabBar(
            labelColor: kOffBlack,
            labelStyle: kNunitoSansBold18,
            unselectedLabelColor: kTinGrey,
            unselectedLabelStyle: kNunitoSans18,
            indicator: BoxDecoration(
              color: kOffBlack,
              borderRadius: BorderRadius.circular(4),
            ),
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 2,
            indicatorColor: kOffBlack,
            indicatorPadding:
                const EdgeInsets.only(left: 16, right: 16, top: 43),
            tabs: const [
              Tab(text: "Delivered"),
              Tab(text: "Processing"),
              Tab(text: "Cancelled"),
            ],
          ),
          ),
          bottomNavigationBar: const CurvedBottomNavBar(selectedPos: 1),
        body: TabBarView(
          physics: const BouncingScrollPhysics(),
          children: [
            ListView.builder(
              itemCount: 10,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return OrderCard(
                  orderNumber: (index + 1) * 102,
                  dateString: "22/04/2022",
                  quantity: index % 5 + 1,
                  totalAmount: (index + 1) * 40,
                  orderStatus: 0,
                );
              },
            ),
            ListView.builder(
              itemCount: 10,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return OrderCard(
                  orderNumber: (index + 1) * 102,
                  dateString: "22/04/2022",
                  quantity: index % 5 + 1,
                  totalAmount: (index + 1) * 40,
                );
              },
            ),
            ListView.builder(
              itemCount: 10,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return OrderCard(
                  orderNumber: (index + 1) * 102,
                  dateString: "22/04/2022",
                  quantity: index % 5 + 1,
                  totalAmount: (index + 1) * 40,
                  orderStatus: 2,
                );
              },
            ),
          ],
          ),
        ),
      ),
    );
  }
}
