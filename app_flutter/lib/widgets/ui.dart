import "package:flutter/material.dart";

import "../estado_helpers.dart";

class EntradaAnimada extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const EntradaAnimada({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<EntradaAnimada> createState() => _EntradaAnimadaState();
}

class _EntradaAnimadaState extends State<EntradaAnimada> {
  bool visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, 0.12),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class EstadoPill extends StatelessWidget {
  final String estado;
  final bool grande;
  final Object? heroTag;

  const EstadoPill({
    super.key,
    required this.estado,
    this.grande = false,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorPorEstado(estado);
    final pill = Container(
      padding: EdgeInsets.symmetric(
        horizontal: grande ? 16 : 12,
        vertical: grande ? 10 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconoPorEstado(estado), size: grande ? 20 : 15, color: color),
          const SizedBox(width: 6),
          Text(
            etiquetaEstado(estado),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: grande ? 15 : 12.5,
            ),
          ),
        ],
      ),
    );

    if (heroTag == null) return pill;
    return Hero(
      tag: heroTag!,
      child: Material(color: Colors.transparent, child: pill),
    );
  }
}

class SeccionCard extends StatelessWidget {
  final String? titulo;
  final Widget child;
  final EdgeInsets padding;

  const SeccionCard({
    super.key,
    this.titulo,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (titulo != null) ...[
              Text(
                titulo!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class ChipDato extends StatelessWidget {
  final IconData icono;
  final String texto;

  const ChipDato({super.key, required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            texto,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
