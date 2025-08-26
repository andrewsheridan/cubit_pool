import 'package:cubit_pool/src/hydrated_value_cubit.dart';

class HydratedStringCubit extends HydratedValueCubit<String> {
  HydratedStringCubit(super.state);

  @override
  String? valueFromJson(String? json) {
    return json;
  }

  @override
  String? valueToJson(String? value) {
    return value;
  }
}
