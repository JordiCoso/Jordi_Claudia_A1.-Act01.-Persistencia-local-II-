import 'package:flutter/material.dart';

import '../services/preferenciasservice.dart';
import '/models/habito.dart';

class PantallaEstadisticas extends StatefulWidget {
  final PreferenciasService _preferenciasService;

  const PantallaEstadisticas({super.key, required this._preferenciasService});

  @override
  State<PantallaEstadisticas> createState() => _PantallaEstadisticas();
}

class _PantallaEstadisticas extends State<PantallaEstadisticas> {
  //texto que aparece mientras recuperamos la última fecha.
  String ultimaApertura = 'Cargando...';

  //variable para guardar el número de aperturas.
  int numeroApertura = 0;

  //lista de habitos guardados,
  List<Habito> listaHabitos = [];

  //método que se ejecuta cuando se crea la pantalla.
  @override
  void initState() {
    super.initState();

    //recuperamos las estadísticas de la aplicación.
    cargarUltimaApertura(widget._preferenciasService);
    cargarNumeroAperturas(widget._preferenciasService);
    listaHabitos = widget._preferenciasService.cargarHabitos();
  }

  //recuperamos la última apertura de la aplicación.
  void cargarUltimaApertura(PreferenciasService preferenciasService) {
    //obtenemos la fecha guardada en SharedPreferences.
    String? fecha = preferenciasService.obtenerUltimaApertura();

    //comprobamos que la pantalla siga abierta.
    if (!mounted) {
      return;
    }

    //actualizamos la fecha que aparece en pantalla.
    setState(() {
      ultimaApertura = fecha ?? 'No hay ninguna fecha guardada.';
    });
  }

  //recuperamos el número de aperturas guardado.
  void cargarNumeroAperturas(PreferenciasService preferenciasService) {
    //obtenemos el contador de SharedPreferences.
    int numero = preferenciasService.obtenerNumeroAperturas();

    //actualizamos el número que aparece en pantalla.
    setState(() {
      numeroApertura = numero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Estadísticas')),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //título principal de la pantalla.
            Text(
              'Tu progreso',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 24),

            //tarjeta de estadísticas de los hábitos.
            Container(
              padding: EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //título de la sección de hábitos.
                  Row(
                    children: [
                      Icon(
                        Icons.bar_chart,
                        color: Theme.of(context).colorScheme.primary,
                      ),

                      SizedBox(width: 8),

                      Text(
                        'Estadísticas de hábitos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  Divider(),

                  SizedBox(height: 16),

                  //TODO: mostrar aquí las estadísticas reales.
                  if (listaHabitos.isEmpty)
                    Center(
                      child: Text('Todavía no has empezado ningún hábito.'),
                    )
                  else
                    Column(
                      children: [
                        for (Habito habito in listaHabitos)
                          Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(child: Text(habito.nombre)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Racha: ${habito.obtenerRacha()} días',
                                    ),
                                    Text(
                                      'Total: ${habito.diasCompletados} días',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                  SizedBox(height: 16),
                ],
              ),
            ),

            SizedBox(height: 20),

            //tarjeta de estadísticas de la aplicación.
            Container(
              padding: EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //título de la sección de actividad.
                  Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),

                      SizedBox(width: 8),

                      Text(
                        'Actividad',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  Divider(),

                  SizedBox(height: 16),

                  //mostramos la fecha de la última apertura.
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).colorScheme.primary,
                      ),

                      SizedBox(width: 16),

                      //Expanded permite que el texto ocupe
                      //el espacio disponible sin salirse de la pantalla.
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Última apertura'),

                            SizedBox(height: 4),

                            Text(
                              ultimaApertura,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Divider(),

                  SizedBox(height: 16),

                  //mostramos el número total de aperturas.
                  Row(
                    children: [
                      Icon(
                        Icons.app_blocking,
                        color: Theme.of(context).colorScheme.primary,
                      ),

                      SizedBox(width: 16),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Número de aperturas'),

                          SizedBox(height: 4),

                          Text(
                            '$numeroApertura',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
