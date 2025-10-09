import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:economycraft/classes/product.dart';

class CartItemCard extends StatelessWidget {
  final Product product;
  final int quantity;
  final NumberFormat currencyFormat;
  final void Function(Product) removeItemFromCart;

  const CartItemCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.currencyFormat,
    required this.removeItemFromCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color.fromARGB(255, 201, 201, 201),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(255, 244, 244, 244),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color.fromARGB(255, 201, 201, 201),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.network(
                product.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.inventory_2,
                      color: Colors.grey,
                      size: 36,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 229, 255, 252),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product.minecraftTag,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 74, 237, 217),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Price and quantity
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat.format(product.price * quantity),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color.fromARGB(255, 23, 221, 97),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${currencyFormat.format(product.price)} × $quantity',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => removeItemFromCart(product),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Remove'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red[400],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: Size.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
