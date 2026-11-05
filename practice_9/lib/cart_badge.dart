import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.select<Cart, int>((c) => c.count);

    return Badge(
      label: Text('$count'),
      isLabelVisible: count > 0,
      child: IconButton(
        icon: const Icon(Icons.shopping_cart),
        onPressed: () => Navigator.of(context).pushNamed('/cart'),
      ),
    );
  }
}
