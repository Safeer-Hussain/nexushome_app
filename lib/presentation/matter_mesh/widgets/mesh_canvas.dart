import 'package:flutter/material.dart';

import '../../../domain/entities/mesh_node_entity.dart';

class MeshCanvas extends StatefulWidget {
  final List<MeshNodeEntity> nodes;
  final VoidCallback? onNodeTap;

  const MeshCanvas({super.key, required this.nodes, this.onNodeTap});

  @override
  State<MeshCanvas> createState() => _MeshCanvasState();
}

class _MeshCanvasState extends State<MeshCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return CustomPaint(
              painter: _MeshTopologyPainter(
                nodes: widget.nodes,
                pulseValue: _pulseController.value,
                colorScheme: colorScheme,
              ),
              size: const Size(double.infinity, 280),
            );
          },
        ),
      ),
    );
  }
}

class _MeshTopologyPainter extends CustomPainter {
  final List<MeshNodeEntity> nodes;
  final double pulseValue;
  final ColorScheme colorScheme;

  _MeshTopologyPainter({
    required this.nodes,
    required this.pulseValue,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    MeshNodeEntity? centerNode;
    for (final n in nodes) {
      if (n.nodeType == 'border_router') {
        centerNode = n;
        break;
      }
    }
    centerNode ??= nodes.first;

    final centerPoint = Offset(
      size.width * centerNode.xPos,
      size.height * centerNode.yPos,
    );

    // Draw background grid lines for architectural mesh look
    final gridPaint = Paint()
      ..color = colorScheme.outlineVariant.withValues(alpha: 0.35)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw mesh connection lines between nodes
    final linePaint = Paint()
      ..color = colorScheme.primary.withValues(alpha: 0.45)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final activeLinePaint = Paint()
      ..color = colorScheme.primary.withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (final node in nodes) {
      if (node.id == centerNode.id) continue;

      final nodePoint = Offset(size.width * node.xPos, size.height * node.yPos);

      // Connect End Devices to Router or Border Router
      if (node.nodeType == 'router') {
        canvas.drawLine(centerPoint, nodePoint, activeLinePaint);
      } else {
        // Find nearest router node
        MeshNodeEntity? router;
        for (final n in nodes) {
          if (n.nodeType == 'router') {
            router = n;
            break;
          }
        }
        router ??= centerNode;
        final routerPoint = Offset(
          size.width * router.xPos,
          size.height * router.yPos,
        );
        canvas.drawLine(routerPoint, nodePoint, linePaint);
      }
    }

    // Draw nodes
    for (final node in nodes) {
      final point = Offset(size.width * node.xPos, size.height * node.yPos);
      final isBorderRouter = node.nodeType == 'border_router';
      final isRouter = node.nodeType == 'router';

      Color nodeColor;
      double radius;

      if (isBorderRouter) {
        nodeColor = colorScheme.primary;
        radius = 16.0;

        // Animated pulse ring around border router
        final pulseRadius = radius + (pulseValue * 12.0);
        final pulsePaint = Paint()
          ..color = colorScheme.primary.withValues(
            alpha: (1.0 - pulseValue) * 0.4,
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(point, pulseRadius, pulsePaint);
      } else if (isRouter) {
        nodeColor = colorScheme.secondary;
        radius = 12.0;
      } else {
        nodeColor = colorScheme.tertiary;
        radius = 8.0;
      }

      // Draw Node Outer Ring
      final nodeBgPaint = Paint()..color = colorScheme.surfaceContainerHighest;
      canvas.drawCircle(point, radius + 2, nodeBgPaint);

      final nodePaint = Paint()
        ..color = nodeColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, radius, nodePaint);

      // Node label
      final textSpan = TextSpan(
        text: node.nodeName.split(' ').first,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(point.dx - textPainter.width / 2, point.dy + radius + 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MeshTopologyPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue || oldDelegate.nodes != nodes;
  }
}
