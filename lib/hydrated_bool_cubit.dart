import 'package:cubit_pool/hydrated_value_cubit.dart';

class HydratedBoolCubit extends HydratedValueCubit<bool> {
  HydratedBoolCubit(super.initialValue);

  @override
  bool? valueFromJson(String? json) {
    return json == "true";
  }

  @override
  String? valueToJson(bool? value) {
    return (value ?? false).toString();
  }
}
