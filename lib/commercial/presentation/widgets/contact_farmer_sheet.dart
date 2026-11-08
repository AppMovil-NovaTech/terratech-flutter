import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/commercial_remote_datasource.dart';
import '../../domain/product.dart';
import '../product_detail_bloc.dart';
import '../product_detail_event.dart';
import '../product_detail_state.dart';

/// Persistent bottom action bar exposing ONLY the "Contact Farmer" action
/// (US40 - Scenario 3). Shopping cart actions are omitted per scope.
class ContactFarmerBottomBar extends StatelessWidget {
  const ContactFarmerBottomBar({
    super.key,
    required this.product,
    required this.onContactPressed,
  });

  final Product product;
  final VoidCallback onContactPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    product.farmerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Trato directo • ${product.originRegion}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              key: const Key('contact_farmer_primary_button'),
              onPressed: onContactPressed,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.contact_phone_rounded),
              label: const Text(
                'Contactar al Agricultor',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal bottom sheet for composing and sending a direct inquiry to the farmer
/// utilizing the static authenticated user session (`test.user@terratech.com`)
/// (US40 - Scenario 3).
class ContactFarmerBottomSheet extends StatefulWidget {
  const ContactFarmerBottomSheet({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  State<ContactFarmerBottomSheet> createState() =>
      _ContactFarmerBottomSheetState();
}

class _ContactFarmerBottomSheetState extends State<ContactFarmerBottomSheet> {
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(
      text:
          'Hola ${widget.product.farmerName}, estoy interesado en el lote '
          '${widget.product.traceability.batchCode} de ${widget.product.name} '
          '(${widget.product.originRegion}). ¿Podrían brindarme detalles de '
          'disponibilidad y coordinación directa?',
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 24 + viewInsets.bottom),
      child: BlocBuilder<ProductDetailBloc, ProductDetailState>(
        builder: (context, state) {
          final isSubmitting =
              state.contactStatus == ContactFarmerStatus.submitting;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.support_agent_rounded,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Contactar al Agricultor',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Remitente autenticado (Sesión activa):',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '${MockAuthSession.testUserFullName} (${MockAuthSession.testUserEmail})',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const Divider(height: 14),
                    Text(
                      'Destinatario: ${widget.product.farmerName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Teléfono directo: ${widget.product.farmerPhone ?? '+51 984 512 309'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                key: const Key('contact_farmer_message_textfield'),
                controller: _messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Mensaje para el agricultor',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('submit_contact_farmer_button'),
                  onPressed: isSubmitting
                      ? null
                      : () {
                          context.read<ProductDetailBloc>().add(
                            ContactFarmerSubmitted(
                              message: _messageController.text,
                            ),
                          );
                          Navigator.of(context).pop();
                        },
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    isSubmitting
                        ? 'Enviando consulta...'
                        : 'Enviar Consulta Directa',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
