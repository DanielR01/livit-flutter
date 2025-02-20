part of '../location_detail.dart';

class PromoterLocationProductsPreview extends StatefulWidget {
  const PromoterLocationProductsPreview({super.key});

  @override
  State<PromoterLocationProductsPreview> createState() => _PromoterLocationProductsPreviewState();
}

class _PromoterLocationProductsPreviewState extends State<PromoterLocationProductsPreview> {
  late final LocationBloc _locationBloc;

  @override
  void initState() {
    super.initState();
    _locationBloc = context.read<LocationBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      hasPadding: false,
      // shadowType: ShadowType.none,
      child: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          late final Widget bar;
          late final Widget content;
          if (state is! ProductsLoaded || state.loadingStates[_locationBloc.currentLocation!.id] == null) {
            BlocProvider.of<ProductBloc>(context).add(LoadLocationProducts(locationId: _locationBloc.currentLocation!.id));
          }
          if (state is ProductInitial ||
              (state is ProductsLoaded && state.loadingStates[_locationBloc.currentLocation!.id] == LoadingState.loading)) {
            bar = _buildBasicBar();
            content = _buildLoadingState();
          } else if (state is ProductsLoaded) {
            if (state.loadingStates[_locationBloc.currentLocation!.id] == LoadingState.error) {
              bar = _buildBasicBar();
              content = _buildErrorState();
            } else if (state.products.isEmpty) {
              bar = _buildBasicBar();
              content = _buildEmptyState();
            } else {
              bar = _buildExpandableBar();
              content = _buildProductsList(state.products);
              //content = _buildLoadingState();
            }
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              bar,
              content,
            ],
          );
        },
      ),
    );
  }

  Widget _buildBasicBar() {
    return LivitBar(
      shadowType: ShadowType.weak,
      child: LivitText(
        'Productos',
        textType: LivitTextType.smallTitle,
      ),
    );
  }

  Widget _buildExpandableBar() {
    return LivitBar.expandable(
      buttons: [
        Button.secondary(
          boxShadow: [LivitShadows.inactiveWhiteShadow],
          text: 'Añadir producto',
          rightIcon: CupertinoIcons.cart_badge_plus,
          onTap: () {},
          isActive: true,
        ),
      ],
      titleText: 'Productos',
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: LivitContainerStyle.padding(),
      child: PreviewField.productLoading(isPromoter: true),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: LivitContainerStyle.padding(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LivitText('Error al cargar los productos', textType: LivitTextType.regular),
              LivitSpaces.xs,
              Icon(
                CupertinoIcons.exclamationmark_circle,
                color: LivitColors.yellowError,
                size: LivitButtonStyle.iconSize,
              ),
            ],
          ),
          LivitSpaces.s,
          Button.main(
            text: 'Reintentar',
            onTap: () {
              BlocProvider.of<ProductBloc>(context).add(LoadLocationProducts(locationId: _locationBloc.currentLocation!.id));
            },
            isActive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: LivitContainerStyle.padding(),
      child: Column(
        children: [
          LivitText('No has registrado ningún producto para vender en esta ubicación.', textType: LivitTextType.regular),
          LivitSpaces.s,
          Button.main(
            text: 'Añadir producto',
            rightIcon: CupertinoIcons.cart_badge_plus,
            onTap: () {},
            isActive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(List<LocationProduct> products) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: Padding(
        padding: LivitContainerStyle.padding(),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return PreviewField.product(
              products[index],
              isPromoter: true,
            );
          },
        ),
      ),
    );
  }
}
