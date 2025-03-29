import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/models/location/product/location_product.dart';
import 'package:livit/models/product_sale/product_sale.dart';
import 'package:livit/services/exceptions/base_exception.dart';
import 'package:livit/services/firestore_storage/bloc/product/product_bloc_exception.dart';
import 'package:livit/services/firestore_storage/firestore_storage/firestore_storage.dart';
import 'package:livit/utilities/debug/livit_debugger.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final Map<String, LoadingState> _loadingStates = {};
  final Map<String, LivitException> _errors = {};

  final FirestoreStorageService _firestoreStorageService;
  final _debugger = const LivitDebugger('ProductBloc');

  ProductBloc({
    required FirestoreStorageService firestoreStorageService,
  })  : _firestoreStorageService = firestoreStorageService,
        super(ProductInitial()) {
    on<LoadLocationProducts>(_onLoadLocationProducts);
    // on<AddProduct>(_onAddProduct);
    // on<UpdateProduct>(_onUpdateProduct);
    // on<DeleteProduct>(_onDeleteProduct);
  }

  Future<void> _onLoadLocationProducts(
    LoadLocationProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      _debugger.debPrint('Loading location products for location: ${event.locationId}', DebugMessageType.methodCalling);
      _loadingStates[event.locationId] = LoadingState.loading;
      emit(ProductsLoaded(products: [], loadingStates: _loadingStates));
      final products = await _firestoreStorageService.productService.getProductsByLocationId(event.locationId);
      _debugger.debPrint('Products loaded: ${products.length}', DebugMessageType.done);
      _loadingStates[event.locationId] = LoadingState.loaded;
      emit(ProductsLoaded(products: products, loadingStates: _loadingStates));
      if (event.loadProductSales) {
        final productSalesMap = <LocationProduct, List<LivitProductSale>>{};
        for (LocationProduct product in products) {
          productSalesMap[product] =
              await _firestoreStorageService.productSaleService.getProductsSalesByLocationIdAndProductId(event.locationId, product.id);
          _debugger.debPrint('Product sales loaded: ${productSalesMap[product]!}', DebugMessageType.done);
        }
        emit(ProductsLoaded(products: products, loadingStates: _loadingStates, productSales: productSalesMap));
      }
    } on FirebaseException catch (e) {
      _debugger.debPrint('Error loading location products: $e', DebugMessageType.error);
      _loadingStates[event.locationId] = LoadingState.error;
      _errors[event.locationId] = GenericProductBlocException(details: e.toString());
      emit(ProductsLoaded(products: [], loadingStates: _loadingStates, errors: _errors));
    } catch (e) {
      _debugger.debPrint('Error loading location products: $e', DebugMessageType.error);
      _loadingStates[event.locationId] = LoadingState.error;
      _errors[event.locationId] = e is LivitException ? e : GenericProductBlocException(details: e.toString());
      emit(ProductsLoaded(products: [], loadingStates: _loadingStates, errors: _errors));
    }
  }

  // Add other event handlers...
}
