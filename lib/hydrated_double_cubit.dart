import 'package:cubit_pool/hydrated_value_cubit.dart';

class HydratedDoubleCubit extends HydratedValueCubit<double> {
  HydratedDoubleCubit({double initialValue = 0}) : super(initialValue);

  @override
  double? valueFromJson(String? json) {
    return json == null ? null : double.tryParse(json);
  }

  @override
  String? valueToJson(double? value) {
    return value?.toString();
  }
}
