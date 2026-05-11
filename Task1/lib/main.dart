import 'package:flutter/material.dart';
import 'package:hotuanphuoc_2224802010872_lab5/models/cart.dart';
import 'package:hotuanphuoc_2224802010872_lab5/models/catalog.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartModel(catalog: CatalogModel()),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shopping Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFE6E6E6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7E733),
          foregroundColor: Colors.black,
          elevation: 1,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            fontFamily: 'Georgia',
          ),
        ),
      ),
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 64),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Welcome',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 48),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Tài khoản',
                  isDense: true,
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Mật khẩu',
                  isDense: true,
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFF7E733), width: 2),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFF7E733), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7E733),
                    foregroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CatalogPage()),
                    );
                  },
                  child: const Text('ENTER'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.read<CartModel>().catalog;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
          return ListView.builder(
            itemCount: catalog.items.length,
            itemBuilder: (context, index) {
              final item = catalog.getByPosition(index);
              final inCart = cart.contains(item);

              return ListTile(
                leading: Container(width: 30, height: 30, color: item.color),
                minTileHeight: 48,
                horizontalTitleGap: 12,
                title: Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                trailing: inCart
                    ? const Icon(Icons.check, color: Colors.grey)
                    : TextButton(
                        onPressed: () => cart.add(item),
                        child: const Text(
                          'ADD',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Cart'),
      ),
      body: Container(
        color: const Color(0xFFF7E733),
        child: Consumer<CartModel>(
          builder: (context, cart, child) {
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    children: cart.items
                        .map(
                          (item) => Text(
                            '-${item.name}',
                            style: const TextStyle(fontSize: 20),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${cart.totalPrice}',
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(82, 40),
                          shape: const RoundedRectangleBorder(),
                        ),
                        onPressed: () {},
                        child: const Text('BUY'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
