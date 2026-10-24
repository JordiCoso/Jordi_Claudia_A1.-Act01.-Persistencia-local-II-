import 'package:flutter/material.dart';

class BotonPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback pulsar;

  const BotonPrincipal ({super.key, required this.texto, required this.pulsar});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: pulsar,
      child: Text(
        texto,
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}