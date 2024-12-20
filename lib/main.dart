import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_time_front/presentation/onboarding/onboarding_screen.dart';
import 'package:on_time_front/presentation/onboarding/preparation_reordarable_list.dart';
import 'package:on_time_front/shared/components/tile.dart';
import 'package:on_time_front/shared/theme/theme.dart';

void main() async {
  runApp(const ProviderScope(child: MyApp()));
  WidgetsFlutterBinding.ensureInitialized();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: themeData,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: OnboardingScreen(),
      ),
    );
  }
}

class ReorderableExample extends StatefulWidget {
  const ReorderableExample({super.key});

  @override
  State<ReorderableExample> createState() => _ReorderableListViewExampleState();
}

class _ReorderableListViewExampleState extends State<ReorderableExample> {
  final List<int> _items = List<int>.generate(50, (int index) => index);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    Widget proxyDecorator(
        Widget child, int index, Animation<double> animation) {
      return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          return SizedBox(
            child: child,
          );
        },
        child: child,
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      proxyDecorator: proxyDecorator,
      itemCount: _items.length,
      itemBuilder: (context, index) => Tile(
          key: ValueKey<int>(_items[index]),
          leading: const SizedBox(
            width: 30,
            height: 30,
            child: CircleAvatar(
              child: Icon(Icons.check),
            ),
          ),
          child: Text('Item ${_items[index]}')),
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final int item = _items.removeAt(oldIndex);
          _items.insert(newIndex, item);
        });
      },
    );
  }
}
