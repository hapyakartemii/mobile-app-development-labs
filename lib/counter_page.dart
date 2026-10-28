import 'package:flutter/material.dart';
import 'package:flutter_lab1/counter_logic.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  final TextEditingController _controller = TextEditingController();
  int _counter = 0;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final result = CounterLogic.apply(_counter, _controller.text);

    setState(() {
      _counter = result.value;
      _errorText = result.message;
    });

    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();

    if (result.isValid) {
      _controller.clear();
      if (result.action == CounterAction.reset) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Лічильник обнулено')),
        );
      }
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Невалідне введення'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Лабораторна №1: Лічильник'),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Поточне значення',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_counter',
                    key: const Key('counterValue'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displayLarge,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    key: const Key('inputField'),
                    controller: _controller,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Число або команда',
                      hintText: 'Напр. 5, -3 або "$resetCommand"',
                      errorText: _errorText,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    key: const Key('applyButton'),
                    onPressed: _submit,
                    icon: const Icon(Icons.check),
                    label: const Text('Застосувати'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
