import 'package:cubit_pool/hydrated_value_cubit.dart';

class HydratedNullableStringCubit extends HydratedValueCubit<String?> {
  HydratedNullableStringCubit({String? initialValue}) : super(initialValue);

  @override
  String? valueFromJson(String? json) {
    return json;
  }

  @override
  String? valueToJson(String? value) {
    return value;
  }
}
