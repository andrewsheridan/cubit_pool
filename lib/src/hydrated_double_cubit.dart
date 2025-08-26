import 'package:cubit_pool/src/hydrated_value_cubit.dart';

class HydratedDoubleCubit extends HydratedValueCubit<double> {
  HydratedDoubleCubit(super.state);

  @override
  double? valueFromJson(String? json) {
    return json == null ? null : double.tryParse(json);
  }

  @override
  String? valueToJson(double? value) {
    return value?.toString();
  }
}
