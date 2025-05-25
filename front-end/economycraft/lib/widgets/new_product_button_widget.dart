import 'package:flutter/material.dart';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:economycraft/classes/product.dart';

class NewProductButtonWidget extends StatefulWidget {
  final int companyId;

  const NewProductButtonWidget({super.key, required this.companyId});

  @override
  State<NewProductButtonWidget> createState() => _NewProductButtonWidgetState();
}

class _NewProductButtonWidgetState extends State<NewProductButtonWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _shippingCostController = TextEditingController();
  final TextEditingController _minecraftTagController = TextEditingController();
  String _avatarUrl = '';
  bool _imageUploading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        _showAddProductDialog();
      },
      icon: const Icon(Icons.add),
      label: const Text('Add New Product'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 23, 221, 97),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  void _showAddProductDialog() {
    // Reset form fields
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _quantityController.clear();
    _minecraftTagController.clear();
    _shippingCostController.clear();
    _avatarUrl = '';

    // Form validation flags
    bool nameError = false;
    bool priceError = false;
    bool quantityError = false;
    bool tagError = false;

    showDialog(
      context: context,
      builder: (context) {
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
                            double.tryParse(_priceController.text) == null,
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
                            Icons.add_shopping_cart,
                            color: Color.fromARGB(255, 74, 237, 217),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Add New Product',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Enter product details to add to your inventory',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
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
                            // Image upload and basic info section
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Image Upload
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Product Image',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: 120,
                                      height: 120,
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
                                      child:
                                          _avatarUrl.isNotEmpty
                                              ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(9),
                                                child: Image.network(
                                                  _avatarUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return const Icon(
                                                      Icons.image_not_supported,
                                                      size: 40,
                                                      color: Colors.grey,
                                                    );
                                                  },
                                                ),
                                              )
                                              : Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.add_photo_alternate,
                                                    size: 40,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Upload Image',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: 120,
                                      child: ElevatedButton.icon(
                                        onPressed:
                                            _imageUploading
                                                ? null
                                                : () async {
                                                  setDialogState(() {
                                                    _imageUploading = true;
                                                  });

                                                  final url =
                                                      await SupabaseHelper.addProductAvatar();

                                                  setDialogState(() {
                                                    _avatarUrl = url ?? '';
                                                    _imageUploading = false;
                                                  });
                                                },
                                        icon:
                                            _imageUploading
                                                ? const SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                )
                                                : const Icon(
                                                  Icons.upload_file,
                                                  size: 14,
                                                ),
                                        label: Text(
                                          _imageUploading
                                              ? 'Uploading...'
                                              : 'Select Image',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            74,
                                            237,
                                            217,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 20),

                                // Basic product info
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
                                        controller: _descriptionController,
                                        decoration: const InputDecoration(
                                          labelText:
                                              'Product Description (Optional)',
                                          border: OutlineInputBorder(),
                                          alignLabelWithHint: true,
                                        ),
                                        maxLines: 3,
                                      ),
                                      const SizedBox(height: 16),
                                      TextField(
                                        controller: _minecraftTagController,
                                        decoration: InputDecoration(
                                          labelText: 'Minecraft Tag*',
                                          border: const OutlineInputBorder(),
                                          hintText: 'e.g. minecraft:diamond',
                                          helperText:
                                              'The exact Minecraft item ID',
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
                            const Divider(),
                            const SizedBox(height: 24),

                            // Pricing and inventory section
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                              border:
                                                  const OutlineInputBorder(),
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
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 16,
                                                  ),
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
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Quantity*',
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
                                              border:
                                                  const OutlineInputBorder(),
                                              prefixIcon: const Icon(
                                                Icons.inventory_2,
                                                color: Colors.blueGrey,
                                              ),
                                              errorText:
                                                  quantityError
                                                      ? 'Enter valid quantity'
                                                      : null,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 16,
                                                  ),
                                            ),
                                            keyboardType: TextInputType.number,
                                            onChanged:
                                                (_) =>
                                                    validateField('quantity'),
                                          ),
                                        ],
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

                    // Action buttons
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
                                    double.tryParse(_priceController.text) ==
                                        null;
                                quantityError =
                                    _quantityController.text.isEmpty ||
                                    int.tryParse(_quantityController.text) ==
                                        null;
                                tagError = _minecraftTagController.text.isEmpty;
                              });

                              // If all valid, add product
                              if (!nameError &&
                                  !priceError &&
                                  !quantityError &&
                                  !tagError) {
                                _addProduct();
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Product'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                23,
                                221,
                                97,
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

  Future<void> _addProduct() async {
    // Validate form
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _minecraftTagController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      double price = double.parse(_priceController.text);
      int quantity = int.parse(_quantityController.text);

      await SupabaseHelper.addProductToCompany(
        widget.companyId,
        _nameController.text,
        _descriptionController.text,
        price,
        quantity,
        _minecraftTagController.text,
        _avatarUrl.isNotEmpty
            ? _avatarUrl
            : 'https://example.com/default-product.png',
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );

        // Force rebuild of parent widget
        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding product: $e')));
    }
  }
}
