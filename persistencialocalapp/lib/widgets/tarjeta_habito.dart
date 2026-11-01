import 'package:flutter/material.dart';

class TarjetaHabito extends StatefulWidget {
  final String nombre;
  final Color color;
  final bool completado;

  final IconData icono;

  final ValueChanged<bool?>? completar;
  final VoidCallback editar;
  final VoidCallback eliminar;

  Icon? valor;

  TarjetaHabito({
    super.key,
    this.nombre = '',
    required this.color,
    required this.completado,
    this.icono = Icons.water,
    this.completar,
    required this.editar,
    required this.eliminar,
  });

  static final ButtonStyle estilo = ElevatedButton.styleFrom(
    padding: const EdgeInsets.all(0),
    alignment: Alignment.center,
    fixedSize: const Size(40, 40),
    minimumSize: const Size(0, 0),
    maximumSize: const Size(50, 50),
  );

  @override
  State<TarjetaHabito> createState() => _TarjetaHabitoState();
}

enum Iconos { gota, correr, hierba }

class _TarjetaHabitoState extends State<TarjetaHabito> {
  final List<Icon> opcionesIconos = <Icon>[
    Icon(Icons.water_drop),
    Icon(Icons.directions_run),
    Icon(Icons.grass),
  ];

  @override
  Widget build(BuildContext context) {
    widget.valor = widget.valor ?? opcionesIconos.first;
    final DropdownButton<Icon> botonDesplegable = DropdownButton<Icon>(
      value: widget.valor,
      items: <DropdownMenuItem<Icon>>[
        DropdownMenuItem<Icon>(
          value: opcionesIconos[Iconos.gota.index],
          child: opcionesIconos[Iconos.gota.index],
        ),
        DropdownMenuItem<Icon>(
          value: opcionesIconos[Iconos.correr.index],
          child: opcionesIconos[Iconos.correr.index],
        ),
        DropdownMenuItem<Icon>(
          value: opcionesIconos[Iconos.hierba.index],
          child: opcionesIconos[Iconos.hierba.index],
        ),
      ],
      onChanged: (Icon? icono) {
        setState(() {
          widget.valor = icono!;
        });
      },
    );

    return Expanded(
      child: Row(
        children: [
          if (widget.completar != null)
            Checkbox(value: widget.completado, onChanged: widget.completar),
          widget.completar == null
              ? botonDesplegable
              : Icon(widget.icono, color: widget.color),

          Text(widget.nombre, style: TextStyle(color: widget.color)),
          SizedBox(width: 0),
          ElevatedButton(
            onPressed: widget.editar,
            style: TarjetaHabito.estilo,

            child: const Icon(Icons.edit),
          ),
          const SizedBox(width: 0),
          ElevatedButton(
            onPressed: widget.eliminar,
            style: TarjetaHabito.estilo,
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
