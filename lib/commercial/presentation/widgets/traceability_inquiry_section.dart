import 'package:flutter/material.dart';

import '../../domain/product.dart';
import '../../domain/traceability.dart';

/// Dedicated section displaying strictly registered and authorized TerraTech
/// provenance, farmer, crop, and associated production events (US40 - Scenario 2).
class TraceabilityInquirySection extends StatelessWidget {
  const TraceabilityInquirySection({
    super.key,
    required this.product,
    required this.traceability,
    required this.onVerifyQrPressed,
  });

  final Product product;
  final TraceabilityInfo traceability;
  final VoidCallback onVerifyQrPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      key: const Key('traceability_inquiry_section'),
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.verified_user_rounded,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Trazabilidad del Producto',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      Text(
                        'Información previamente registrada y autorizada en TerraTech',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  key: const Key('traceability_qr_inquiry_button'),
                  onPressed: onVerifyQrPressed,
                  icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                  label: const Text('Ficha QR'),
                ),
              ],
            ),
            const Divider(height: 24),
            TraceabilityMetadataRow(
              icon: Icons.inventory_2_outlined,
              label: 'Código de Lote',
              value: traceability.batchCode,
            ),
            TraceabilityMetadataRow(
              icon: Icons.landscape_outlined,
              label: 'Procedencia / Parcela',
              value:
                  '${traceability.fieldName} (${traceability.originRegion})',
            ),
            TraceabilityMetadataRow(
              icon: Icons.person_pin_circle_outlined,
              label: 'Agricultor Responsable',
              value: traceability.farmerName,
            ),
            TraceabilityMetadataRow(
              icon: Icons.grass_outlined,
              label: 'Cultivo Registrado',
              value: traceability.cropName,
            ),
            TraceabilityMetadataRow(
              icon: Icons.layers_outlined,
              label: 'Tipo de Suelo y Área',
              value:
                  '${traceability.soilType} • ${(traceability.fieldSizeM2 ?? 15000).toStringAsFixed(0)} m²',
            ),
            if (traceability.sensorNodeCode != null)
              TraceabilityMetadataRow(
                icon: Icons.sensors_rounded,
                label: 'Nodo Sensor IoT',
                value:
                    '${traceability.sensorNodeName ?? 'Sensor TerraTech'} (${traceability.sensorNodeCode})',
              ),
            if (traceability.soilMoistureMean != null)
              TraceabilityMetadataRow(
                icon: Icons.water_drop_outlined,
                label: 'Humedad Edáfica Media',
                value: '${traceability.soilMoistureMean!.toStringAsFixed(1)}%',
              ),
            if (traceability.technicalSummary != null &&
                traceability.technicalSummary!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.analytics_outlined,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Reporte Agronómico: ${traceability.technicalSummary}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              'Eventos de Producción Asociados',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            ...List<Widget>.generate(traceability.productionEvents.length, (
              index,
            ) {
              final event = traceability.productionEvents[index];
              final isLast = index == traceability.productionEvents.length - 1;
              return ProductionEventTimelineTile(
                event: event,
                isLast: isLast,
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Key-value row displaying a single provenance or agronomic attribute.
class TraceabilityMetadataRow extends StatelessWidget {
  const TraceabilityMetadataRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 10),
          SizedBox(
            width: 138,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Timeline step representing an individual authorized production event.
class ProductionEventTimelineTile extends StatelessWidget {
  const ProductionEventTimelineTile({
    super.key,
    required this.event,
    required this.isLast,
  });

  final ProductionEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final formattedDate =
        '${event.timestamp.day.toString().padLeft(2, '0')}/'
        '${event.timestamp.month.toString().padLeft(2, '0')}/'
        '${event.timestamp.year}';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: colorScheme.onPrimary,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: colorScheme.primary.withValues(alpha: 0.35),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            event.stage,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          formattedDate,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (event.metricsSummary != null &&
                        event.metricsSummary!.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 6),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.memory_rounded,
                            size: 14,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.metricsSummary!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal dialog presenting the verified TerraTech QR traceability certificate
/// for a product (US40 - Scenario 2).
class QrTraceabilityCertificateDialog extends StatelessWidget {
  const QrTraceabilityCertificateDialog({
    super.key,
    required this.product,
    required this.traceability,
  });

  final Product product;
  final TraceabilityInfo traceability;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      key: const Key('qr_traceability_certificate_dialog'),
      icon: Icon(
        Icons.verified_user_rounded,
        size: 40,
        color: colorScheme.primary,
      ),
      title: const Text(
        'Ficha de Trazabilidad QR Verificada',
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.qr_code_2_rounded,
                    size: 68,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    traceability.qrVerificationCode ??
                        'TT-QR-2026-P${product.id}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _CertificateDetailRow(
              label: 'Producto:',
              value: product.name,
            ),
            _CertificateDetailRow(
              label: 'Lote registrado:',
              value: traceability.batchCode,
            ),
            _CertificateDetailRow(
              label: 'Procedencia:',
              value:
                  '${traceability.fieldName} (${traceability.originRegion})',
            ),
            _CertificateDetailRow(
              label: 'Agricultor:',
              value: traceability.farmerName,
            ),
            _CertificateDetailRow(
              label: 'Cultivo:',
              value: traceability.cropName,
            ),
            _CertificateDetailRow(
              label: 'Nodo Sensor IoT:',
              value: traceability.sensorNodeCode ?? 'Verificado TerraTech',
            ),
            const SizedBox(height: 10),
            Text(
              'Únicamente se presenta información previamente registrada y autorizada en TerraTech.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar ficha'),
        ),
      ],
    );
  }
}

class _CertificateDetailRow extends StatelessWidget {
  const _CertificateDetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
