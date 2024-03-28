import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const SomePkgDevToolsExtension());
}

class SomePkgDevToolsExtension extends StatelessWidget {
  const SomePkgDevToolsExtension({super.key});

  @override
  Widget build(BuildContext context) {
    return DevToolsExtension(
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('Foo DevTools Extension'),
          ),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 32.0),
              ElevatedButton(onPressed: ()=>{}, child: const Text("test button"))
              // EvalExample(),
              // SizedBox(height: 32.0),
              // ListeningForDevToolsEventExample(),
              // SizedBox(height: 32.0),
              // CallingDevToolsExtensionsAPIsExample(),
            ],
          ),
        ),
      ), // Build your extension here
    );
  }
}