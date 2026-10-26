import 'package:flutter/material.dart';

class CampoTextoApp extends StatelessWidget {
  final String etiqueta; //para mostrar el nomnbre y el usuario...
  final TextEditingController controller; //para leer el texto.
  final bool ocultarTexto; //para ocultar la contraseña.

  const CampoTextoApp({super.key, required this.etiqueta, required this.controller, this.ocultarTexto = false});

@override
  Widget build(BuildContext context) {
  return TextField(
    controller: controller, //conecta con el TextEditingController.
    obscureText: ocultarTexto, //cuando sea true, se ocultará el texto.
    //muestra la etiqueta que le damos y dibuja un borde alrededor.
    decoration: InputDecoration(labelText: etiqueta,
    border: const OutlineInputBorder(),
    ),
  );
}
}