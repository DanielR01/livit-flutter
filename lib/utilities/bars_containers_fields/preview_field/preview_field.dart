import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/models/event/event.dart';
import 'package:livit/models/location/product/location_product.dart';
import 'package:livit/models/media/location_media_file.dart';
import 'package:livit/services/firestore_storage/bloc/event/event_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/ticket/ticket_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/ticket/ticket_event.dart';
import 'package:livit/services/firestore_storage/bloc/ticket/ticket_state.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/bars_containers_fields/small_image_container.dart';
import 'package:shimmer/shimmer.dart';

part 'product/promoter/promoter_product_preview_field.dart';
part 'product/promoter/promoter_product_loading_preview_field.dart';
part 'product/customer/customer_product_loading_preview_field.dart';
part 'product/customer/customer_product_preview_field.dart';
part 'event/promoter/promoter_event_loading_preview_field.dart';
part 'event/customer/customer_event_loading_preview_field.dart';
part 'event/promoter/promoter_event_preview_field.dart';
part 'event/customer/customer_event_preview_field.dart';

class PreviewField extends StatefulWidget {
  final LocationProduct? product;
  final bool isProduct;
  final LivitEvent? event;
  final bool isEvent;
  final bool isPromoter;
  const PreviewField({
    super.key,
    required this.product,
    required this.event,
    required this.isProduct,
    required this.isEvent,
    this.isPromoter = false,
  });

  factory PreviewField.event(LivitEvent event, {bool isPromoter = false}) => PreviewField(
        product: null,
        event: event,
        isProduct: false,
        isEvent: true,
        isPromoter: isPromoter,
      );
  factory PreviewField.product(LocationProduct product, {bool isPromoter = false}) => PreviewField(
        product: product,
        event: null,
        isProduct: true,
        isEvent: false,
        isPromoter: isPromoter,
      );
  factory PreviewField.eventLoading({bool isPromoter = false}) => PreviewField(
        product: null,
        event: null,
        isProduct: false,
        isEvent: true,
        isPromoter: isPromoter,
      );
  factory PreviewField.productLoading({bool isPromoter = false}) => PreviewField(
        product: null,
        event: null,
        isProduct: true,
        isEvent: false,
        isPromoter: isPromoter,
      );

  @override
  State<PreviewField> createState() => _PreviewFieldState();
}

class _PreviewFieldState extends State<PreviewField> {
  @override
  Widget build(BuildContext context) {
    if (widget.isProduct) {
      if (widget.product == null) {
        if (widget.isPromoter) {
          return PromoterProductLoadingPreviewField();
        } else {
          return CustomerProductLoadingPreviewField();
        }
      } else {
        if (widget.isPromoter) {
          return PromoterProductPreviewField(product: widget.product!);
        } else {
          return CustomerProductPreviewField(product: widget.product!);
        }
      }
    } else {
      if (widget.event == null) {
        if (widget.isPromoter) {
          return PromoterEventLoadingPreview();
        } else {
          return CustomerEventLoadingPreviewField();
        }
      } else {
        final LivitEvent event = widget.event!;
        if (widget.isPromoter) {
          return PromoterEventPreviewField(event: event);
        } else {
          return CustomerEventPreviewField(event: event);
        }
      }
    }
  }
}
