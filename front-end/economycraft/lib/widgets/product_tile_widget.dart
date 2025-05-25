import 'package:flutter/material.dart';
import 'package:economycraft/classes/product.dart';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:intl/intl.dart';

class ProductTileWidget extends StatefulWidget {
  final Product product;

  const ProductTileWidget({super.key, required this.product});

  @override
  State<ProductTileWidget> createState() => _ProductTileWidgetState();
}

class _ProductTileWidgetState extends State<ProductTileWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _minecraftTagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.product.name;
    _descriptionController.text = widget.product.description;
    _priceController.text = widget.product.price.toString();
    _quantityController.text = widget.product.quantity.toString();
    _minecraftTagController.text = widget.product.minecraftTag;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    return Container(
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
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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

          const Divider(height: 24),

          // Actions row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  _showEditDialog();
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 74, 237, 217),
                  side: const BorderSide(
                    color: Color.fromARGB(255, 74, 237, 217),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  _showDeleteConfirmation();
                },
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog() {
    // Form validation flags
    bool nameError = false;
    bool priceError = false;
    bool quantityError = false;
    bool tagError = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Validate input and update error states
            void validateField(String field) {
              switch (field) {
                case 'name':
                  setDialogState(
                    () => nameError = _nameController.text.isEmpty,
                  );
                  break;
                case 'price':
                  setDialogState(
                    () =>
                        priceError =
                            _priceController.text.isEmpty ||
                            double.tryParse(
                                  _priceController.text.replaceAll('\$', ''),
                                ) ==
                                null,
                  );
                  break;
                case 'quantity':
                  setDialogState(
                    () =>
                        quantityError =
                            _quantityController.text.isEmpty ||
                            int.tryParse(_quantityController.text) == null,
                  );
                  break;
                case 'tag':
                  setDialogState(
                    () => tagError = _minecraftTagController.text.isEmpty,
                  );
                  break;
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                width: 450,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 229, 255, 252),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.edit,
                            color: Color.fromARGB(255, 74, 237, 217),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Edit Product',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Update details for ${widget.product.name}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product image and basic info
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Image
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color.fromARGB(
                                        255,
                                        201,
                                        201,
                                        201,
                                      ),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(9),
                                    child: Image.network(
                                      widget.product.avatarUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return const Icon(
                                          Icons.inventory_2,
                                          size: 40,
                                          color: Colors.grey,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),

                                // Basic info fields
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextField(
                                        controller: _nameController,
                                        decoration: InputDecoration(
                                          labelText: 'Product Name*',
                                          border: const OutlineInputBorder(),
                                          errorText:
                                              nameError
                                                  ? 'Name is required'
                                                  : null,
                                        ),
                                        onChanged: (_) => validateField('name'),
                                      ),
                                      const SizedBox(height: 16),
                                      TextField(
                                        controller: _minecraftTagController,
                                        decoration: InputDecoration(
                                          labelText: 'Minecraft Tag*',
                                          border: const OutlineInputBorder(),
                                          errorText:
                                              tagError
                                                  ? 'Tag is required'
                                                  : null,
                                          suffixIcon: const Icon(Icons.tag),
                                        ),
                                        onChanged: (_) => validateField('tag'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Description
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                hintText: 'Product description (optional)',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),

                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 24),

                            // Pricing and inventory section
                            const Text(
                              'Pricing & Inventory',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 74, 237, 217),
                              ),
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                // Price field
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Unit Price*',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _priceController,
                                        decoration: InputDecoration(
                                          border: const OutlineInputBorder(),
                                          prefixIcon: const Icon(
                                            Icons.attach_money,
                                            color: Color.fromARGB(
                                              255,
                                              23,
                                              221,
                                              97,
                                            ),
                                          ),
                                          errorText:
                                              priceError
                                                  ? 'Enter valid price'
                                                  : null,
                                        ),
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        onChanged:
                                            (_) => validateField('price'),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),

                                // Quantity field
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Available Quantity*',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _quantityController,
                                        decoration: InputDecoration(
                                          border: const OutlineInputBorder(),
                                          prefixIcon: const Icon(
                                            Icons.inventory_2,
                                            color: Colors.blueGrey,
                                          ),
                                          errorText:
                                              quantityError
                                                  ? 'Enter valid quantity'
                                                  : null,
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged:
                                            (_) => validateField('quantity'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Footer with buttons
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        border: Border(
                          top: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '* Required fields',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Validate all fields
                              setDialogState(() {
                                nameError = _nameController.text.isEmpty;
                                priceError =
                                    _priceController.text.isEmpty ||
                                    double.tryParse(
                                          _priceController.text.replaceAll(
                                            '\$',
                                            '',
                                          ),
                                        ) ==
                                        null;
                                quantityError =
                                    _quantityController.text.isEmpty ||
                                    int.tryParse(_quantityController.text) ==
                                        null;
                                tagError = _minecraftTagController.text.isEmpty;
                              });

                              // Only proceed if all valid
                              if (!nameError &&
                                  !priceError &&
                                  !quantityError &&
                                  !tagError) {
                                _updateProduct();
                                Navigator.of(context).pop();
                              }
                            },
                            icon: const Icon(Icons.save),
                            label: const Text('Save Changes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                74,
                                237,
                                217,
                              ),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text(
            'Are you sure you want to delete "${widget.product.name}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteProduct();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProduct() async {
    try {
      await SupabaseHelper.updateProduct(
        widget.product.id,
        _nameController.text,
        _descriptionController.text,
        double.parse(_priceController.text.replaceAll('\$', '')),
        int.parse(_quantityController.text),
        _minecraftTagController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully')),
        );

        // Refresh state to show updated information
        setState(() {
          widget.product.name = _nameController.text;
          widget.product.description = _descriptionController.text;
          widget.product.price = double.parse(
            _priceController.text.replaceAll('\$', ''),
          );
          widget.product.quantity = int.parse(_quantityController.text);
          widget.product.minecraftTag = _minecraftTagController.text;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating product: $e')));
      }
    }
  }

  Future<void> _deleteProduct() async {
    try {
      await SupabaseHelper.deleteProduct(widget.product.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully')),
        );

        // Force parent widget to rebuild
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting product: $e')));
      }
    }
  }
}
