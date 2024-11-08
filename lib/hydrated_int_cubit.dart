import 'package:cubit_pool/hydrated_value_cubit.dart';

class HydratedIntCubit extends HydratedValueCubit<int> {
  HydratedIntCubit(super.state);

  @override
  int? valueFromJson(String? json) {
    return json == null ? null : int.tryParse(json);
  }

  @override
  String? valueToJson(int? value) {
    return value?.toString();
  }
}
