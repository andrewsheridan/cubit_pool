import 'package:hydrated_bloc/hydrated_bloc.dart';

abstract class HydratedCubitWithSetter<T> extends HydratedCubit<T> {
  HydratedCubitWithSetter(super.state);

  void setState(T value) {
    emit(value);
  }
}
