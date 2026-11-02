import 'package:flutter/material.dart';

import '../models/iconos.dart';

class TarjetaHabito extends StatefulWidget {
  final String nombre;
  final Color color;
  final bool completado;

  final IconData icono;

  final ValueChanged<bool?>? completar;
  final VoidCallback editar;
  final VoidCallback eliminar;

  const TarjetaHabito({
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

class _TarjetaHabitoState extends State<TarjetaHabito> {
  late DropdownMenuItem<Icon> menuGota = DropdownMenuItem<Icon>(
    value: opcionesIconos[NombreIconos.gota.index],
    child: menuCorrer,
  );
  late DropdownMenuItem<Icon> menuCorrer = DropdownMenuItem<Icon>(
    value: opcionesIconos[NombreIconos.correr.index],
    child: menuHierba,
  );
  late DropdownMenuItem<Icon> menuHierba = DropdownMenuItem<Icon>(
    value: opcionesIconos[NombreIconos.hierba.index],
    child: menuHierba,
  );

  Icon? valor = opcionesIconos[NombreIconos.gota.index];

  @override
  Widget build(BuildContext context) {
    final DropdownButton<Icon> botonDesplegable = DropdownButton<Icon>(
      value: valor,
      items: <DropdownMenuItem<Icon>>[menuGota, menuCorrer, menuHierba],
      onChanged: (Icon? icono) {
        setState(() {
          valor = icono;
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
