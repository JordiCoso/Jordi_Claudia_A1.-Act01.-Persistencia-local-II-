import 'package:flutter/material.dart';
import '/widgets/campo_texto_app.dart';


class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();

}

class _RegistroState extends State<Registro> {

  //creamos los controladores para tener los datos guardados y recuperarlos cuando lo necesitemos.
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();

  @override
  //cuando se quite la pantalla, debemos usar el dispose para librerar la informacion.
  void dispose() {
    usuarioController.dispose();
    nombreController.dispose();
    apellidoController.dispose();
    emailController.dispose();
    contrasenaController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            CampoTextoApp(etiqueta: 'Usuario', controller: usuarioController,
            ),

            SizedBox(height: 16),

            CampoTextoApp(etiqueta: 'Nombre', controller: nombreController,
            ),

            SizedBox(height: 16),

            CampoTextoApp(etiqueta: 'Apellido', controller: apellidoController,
            ),

            SizedBox(height: 16),

            CampoTextoApp(etiqueta: 'Email', controller: emailController,
            ),

            SizedBox(height: 16),

            CampoTextoApp(etiqueta: 'Contraseña', controller: contrasenaController, ocultarTexto: true,
            ),
          ],
        ),
      ),
    );
  }
}