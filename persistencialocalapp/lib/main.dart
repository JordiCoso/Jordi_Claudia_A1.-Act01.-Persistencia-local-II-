import 'package:flutter/material.dart';
import 'package:habitosapp/services/DataBaseHelper.dart';

import '/screens/bienvenida.dart';
import '/screens/principal.dart';
import '/services/PreferenciasService.dart';

import 'models/usuario.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //creamos el servicio de preferencias.
  PreferenciasService _preferenciasService = await PreferenciasService.crear();
  final Databasehelper _basedatos1 = await Databasehelper;
  final Databasehelper _basedatos2 = await Databasehelper.crear();
  //aumentamos el número de veces que se abre la aplicación.
  _preferenciasService.aumentarNumeroAperturar();

  //guardamos la fecha y hora de la última apertura.
  _preferenciasService.registrarApertura();
  print(_basedatos1 == _basedatos2);
  print('Base 1 $_basedatos1, Base 2  $_basedatos2');
  print(_preferenciasService);
  //iniciamos la aplicación con el servicio de preferencias.
  runApp(MyApp(preferenciasService: _preferenciasService));
}

class MyApp extends StatefulWidget {
  //servicio que utilizamos para recuperar las preferencias.
  final PreferenciasService _preferenciasService;

  const MyApp({super.key, required this._preferenciasService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    //la aplicacion "escucha" los cambios.
    return ValueListenableBuilder<bool>(
      valueListenable: widget._preferenciasService.temaOscuro,

      builder: (context, temaOscuro, child) {
        return ValueListenableBuilder<double>(
          valueListenable: widget._preferenciasService.tamanoLetra,

          builder: (context, tamanoLetra, child) {
            return MaterialApp(
              title: 'HabitosApp',

              //colores de la aplicación en modo claro.
              theme: ThemeData(
                scaffoldBackgroundColor: Color(0xFFF5F7F2),

                colorScheme: ColorScheme.light(
                  primary: Color(0xFF72917C),
                  secondary: Color(0xFFA2BBA8),
                  surface: Color(0xFFFFFFFF),
                ),

                //colores de la barra superior.
                appBarTheme: AppBarTheme(
                  backgroundColor: Color(0xFFF5F7F2),
                  foregroundColor: Color(0xFF263D32),
                ),
              ),

              //colores de la aplicación en modo oscuro.
              darkTheme: ThemeData(
                scaffoldBackgroundColor: Color(0xFF171F1B),

                colorScheme: ColorScheme.dark(
                  primary: Color(0xFFA2BBA8),
                  secondary: Color(0xFF72917C),
                  surface: Color(0xFF28352E),
                ),

                //colores de la barra superior en modo oscuro.
                appBarTheme: AppBarTheme(
                  backgroundColor: Color(0xFF171F1B),
                  foregroundColor: Color(0xFFE9F1EA),
                ),
              ),

              //seleccionamos el tema guardado.
              themeMode: temaOscuro ? ThemeMode.dark : ThemeMode.light,

              //ahora vamos a aplicar el tamaño de la letra a TODOS los textos
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(tamanoLetra / 14)),
                  child: child!, //aquí indicamos que child no es null, poniendo el !
                );
              },

              //comprobamos si el usuario ya se ha registrado.
              home: comprobarInicio(widget._preferenciasService),
            );
          },
        );
      },
    );
  }

  //comprobamos si debemos mostrar Bienvenida o Principal.
  Widget comprobarInicio(PreferenciasService _preferenciasService) {
    //recuperamos los datos del usuario.
    Usuario _usuario = _preferenciasService.cargarUsuario();

    //si no tiene nombre o hábitos, mostramos Bienvenida.
    //si ya tiene datos guardados, mostramos Principal.
    return (_usuario.nombre == '' || _usuario.numeroHabitos == 0)
        ? Bienvenida(preferenciasService: _preferenciasService)
        : Principal(
            preferenciasService: _preferenciasService,
            usuario: _usuario,
          );
  }
}
