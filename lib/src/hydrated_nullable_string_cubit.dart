import 'package:cubit_pool/src/hydrated_value_cubit.dart';

class HydratedNullableStringCubit extends HydratedValueCubit<String?> {
  HydratedNullableStringCubit([super.state]);

  @override
  String? valueFromJson(String? json) {
    return json;
  }

  @override
  String? valueToJson(String? value) {
    return value;
  }
}
