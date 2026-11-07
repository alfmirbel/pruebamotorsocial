import 'package:flutter/material.dart';
import 'package:motorsocial/motorsocial.dart';

import 'prestamo.dart';

/// Subtítulo de las tarjetas: categoría y estado del préstamo.
String subtituloObjeto(SocialObject o) {
  final categoria = o.attribute<String>('categoria');
  final estado = Prestamo.estaDisponible(o) ? 'disponible' : 'prestado';
  return [?categoria, estado].join(' · ');
}

/// Editor de los atributos propios de PrestaVecino (categoría y estado de
/// conservación). La disponibilidad la gestiona el préstamo.
class ObjetoAtributosEditor extends StatefulWidget {
  const ObjetoAtributosEditor({
    super.key,
    required this.attributes,
    required this.onChanged,
    required this.categorias,
    this.colonia,
  });

  final Map<String, dynamic> attributes;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final List<String> categorias;
  final String? colonia;

  @override
  State<ObjetoAtributosEditor> createState() => _ObjetoAtributosEditorState();
}

class _ObjetoAtributosEditorState extends State<ObjetoAtributosEditor> {
  Map<String, dynamic> get attributes => widget.attributes;

  Map<String, dynamic> _with(String key, Object? value) => {
    ...attributes,
    Prestamo.disponible: attributes[Prestamo.disponible] ?? true,
    if (widget.colonia != null)
      'colonia': attributes['colonia'] ?? widget.colonia,
    key: value,
  };

  @override
  void initState() {
    super.initState();
    // Un objeto nuevo nace disponible y en la colonia de quien lo publica.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onChanged(_with('estado', attributes['estado'] ?? 'bueno'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categorias = widget.categorias;
    final onChanged = widget.onChanged;
    final categoria = attributes['categoria'] as String?;
    final estado = attributes['estado'] as String? ?? 'bueno';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          key: const Key('objeto-categoria'),
          initialValue: categorias.contains(categoria) ? categoria : null,
          decoration: const InputDecoration(labelText: 'Categoría'),
          items: [
            for (final c in categorias)
              DropdownMenuItem(value: c, child: Text(c)),
          ],
          onChanged: (v) => onChanged(_with('categoria', v)),
        ),
        const SizedBox(height: 12),
        SegmentedButton<String>(
          key: const Key('objeto-estado'),
          segments: const [
            ButtonSegment(value: 'bueno', label: Text('Buen estado')),
            ButtonSegment(value: 'regular', label: Text('Regular')),
          ],
          selected: {estado},
          onSelectionChanged: (s) => onChanged(_with('estado', s.first)),
        ),
      ],
    );
  }
}
