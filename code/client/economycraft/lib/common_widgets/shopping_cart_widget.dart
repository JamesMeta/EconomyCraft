import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShoppingCartWidget extends StatelessWidget {
  const ShoppingCartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.shopping_cart, size: 40),
      onPressed: () {
        context.go('/home/shopping_cart');
      },
      tooltip: 'Shopping Cart',
    );
  }
}
