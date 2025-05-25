import 'package:flutter/material.dart';
import 'package:economycraft/classes/product.dart';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductMarketTileWidget extends StatefulWidget {
  final Product product;

  const ProductMarketTileWidget({super.key, required this.product});

  @override
  State<ProductMarketTileWidget> createState() => _ProductTileWidgetState();
}

class _ProductTileWidgetState extends State<ProductMarketTileWidget> {
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          showAddToCartDialog(context);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main info row (image, name, price)
              Row(
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
                        widget.product.avatarUrl,
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
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.product.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 229, 255, 252),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.product.minecraftTag,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 74, 237, 217),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Price and quantity
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(widget.product.price),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 23, 221, 97),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          'Stock: ${widget.product.quantity}',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                widget.product.quantity > 10
                                    ? Colors.grey[600]
                                    : Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showAddToCartDialog(BuildContext context) {
    // Initialize quantity controller with a default value
    _quantityController.text = '1';

    // For calculating total price
    double totalPrice = widget.product.price;
    int quantity = 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Update total when quantity changes
            void updateTotal(String value) {
              setState(() {
                quantity = int.tryParse(value) ?? 1;
                if (quantity < 1) quantity = 1;
                if (quantity > widget.product.quantity) {
                  quantity = widget.product.quantity;
                }
                _quantityController.text = quantity.toString();
                totalPrice = widget.product.price * quantity;
              });
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with product image and details
                    Row(
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
                              widget.product.avatarUrl,
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
                                widget.product.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Unit Price: ${NumberFormat.currency(symbol: '\$').format(widget.product.price)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 23, 221, 97),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Available: ${widget.product.quantity}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      widget.product.quantity > 10
                                          ? Colors.grey[600]
                                          : Colors.red[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Quantity selector section
                    const Text(
                      'Select Quantity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Quantity input with +/- buttons
                    Row(
                      children: [
                        // Decrease button
                        InkWell(
                          onTap: () {
                            int currentQty =
                                int.tryParse(_quantityController.text) ?? 1;
                            if (currentQty > 1) {
                              currentQty--;
                              _quantityController.text = currentQty.toString();
                              updateTotal(currentQty.toString());
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 229, 255, 252),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.remove,
                              color: Color.fromARGB(255, 74, 237, 217),
                            ),
                          ),
                        ),

                        // Quantity input field
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              onChanged: updateTotal,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Increase button
                        InkWell(
                          onTap: () {
                            int currentQty =
                                int.tryParse(_quantityController.text) ?? 1;
                            if (currentQty < widget.product.quantity) {
                              currentQty++;
                              _quantityController.text = currentQty.toString();
                              updateTotal(currentQty.toString());
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 229, 255, 252),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Color.fromARGB(255, 74, 237, 217),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Total price section
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Price:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            NumberFormat.currency(
                              symbol: '\$',
                            ).format(totalPrice),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 23, 221, 97),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        // Cancel button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color.fromARGB(255, 74, 237, 217),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color.fromARGB(255, 74, 237, 217),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Add to cart button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (quantity <= 0 ||
                                  quantity > widget.product.quantity) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please enter a valid quantity',
                                    ),
                                  ),
                                );
                                return;
                              }

                              await _addProductToCart(
                                widget.product.id,
                                quantity,
                              );
                              if (!context.mounted) return;
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Added ${quantity}x ${widget.product.name} to cart!',
                                  ),
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    23,
                                    221,
                                    97,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                23,
                                221,
                                97,
                              ),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Add to Cart'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addProductToCart(int productId, int quantity) async {
    final key = 'shopping_cart';
    final prefs = await SharedPreferences.getInstance();

    final cart = prefs.getStringList(key) ?? [];

    for (var i = 0; i < quantity; i++) {
      cart.add(productId.toString());
    }

    await prefs.setStringList(key, cart);
  }
}
