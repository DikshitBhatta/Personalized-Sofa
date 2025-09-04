import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timberr/models/cart_item.dart';
import 'package:timberr/models/product.dart';
import 'package:timberr/screens/cart/cart_screen.dart';

class CartController extends GetxController {
  List cartIdList = [];
  var cartList = <CartItem>{}.obs;
  var total = 0.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchCartItems() async {
    final doc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    if (doc.exists) {
      cartIdList = doc.data()!['cartList'] ?? [];
      for (int i = 0; i < cartIdList.length; i++) {
        final cartDoc = await _firestore.collection('cart_items').doc(cartIdList[i]).get();
        if (cartDoc.exists) {
          final cartData = cartDoc.data()!;
          final productDoc = await _firestore.collection('Products').doc(cartData['product_id']).get();
          if (productDoc.exists) {
            final product = Product.fromJson(productDoc.data()!);
            cartList.add(CartItem(
              cartData['cart_id'],
              cartData['quantity'],
              cartData['color'],
              product.toJson(),
            ));
            total.value = total.value + ((cartData['quantity'] as int) * product.price).toInt();
          }
        }
      }
    }
  }

  int findProduct(Product product, Color color) {
    for (int i = 0; i < cartList.length; i++) {
      if (cartList.elementAt(i).productId == product.productId &&
          cartList.elementAt(i).color == color) {
        return i;
      }
    }
    return -1;
  }

  Future<void> addToCart(Product product, Color color,
      {int quantity = 1, bool showSnackbar = true}) async {
    int index = findProduct(product, color);
    if (index != -1) {
      //product already present in cart
      cartList.elementAt(index).addQuantity(quantity);
      total.value = total.value + (quantity * cartList.elementAt(index).price);
      //update quantity in database
      await _firestore
          .collection('cart_items')
          .doc(cartList.elementAt(index).cartId.toString())
          .update({'quantity': cartList.elementAt(index).quantity});
    } else {
      //product not there in cart
      //add item to cart_items database
      final docRef = _firestore.collection("cart_items").doc();
      await docRef.set({
        'product_id': product.productId,
        'quantity': quantity,
        'color': colorToString(color),
        'cart_id': docRef.id,
      });
      cartList.add(
        CartItem(
          docRef.id,
          quantity,
          colorToString(color),
          product.toJson(),
        ),
      );
      total.value = total.value + (quantity * product.price);
      //set cart_id in user cartlist
      cartIdList.add(docRef.id);
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({'cartList': cartIdList});
    }
    if (showSnackbar) {
      Get.snackbar(
        "Added to Cart",
        "${product.name} has been added to the cart",
        onTap: (_) {
          Get.closeCurrentSnackbar();
          Get.to(
            () => CartScreen(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 600),
          );
        },
      );
    }
  }

  Future<void> removeFromCart(CartItem item) async {
    cartList.remove(item);
    cartIdList.remove(item.cartId);
    total.value = total.value - (item.quantity * item.price);
    //remove cart_id from user cart list
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      'cartList': cartIdList,
    });
    //remove item from cart_items database
    await _firestore.collection('cart_items').doc(item.cartId.toString()).delete();
  }

  Future incrementQuantity(CartItem item) async {
    item.addQuantity(1);
    total.value = total.value + item.price;
    await _firestore
        .collection('cart_items')
        .doc(item.cartId.toString())
        .update({'quantity': item.quantity});
    update();
  }

  Future decrementQuantity(CartItem item) async {
    if (item.quantity == 1) {
      await removeFromCart(item);
    } else {
      item.removeQuantity(1);
      await _firestore
          .collection('cart_items')
          .doc(item.cartId.toString())
          .update({'quantity': item.quantity});
      total.value = total.value - item.price;
      update();
    }
  }

  Future<void> removeAllFromCart() async {
    cartList.clear();
    //delete each cart entry from the database
    for (String cartId in cartIdList) {
      await _firestore.collection('cart_items').doc(cartId).delete();
    }
    cartIdList.clear();
    //remove all the elements from the user cart
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      'cartList': [],
    });
  }
}
