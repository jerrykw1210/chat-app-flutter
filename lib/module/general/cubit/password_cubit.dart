import 'package:bloc/bloc.dart';

class PasswordCubit extends Cubit<bool> {
  PasswordCubit() : super(true);

  void showPassword() => emit(!state);
}
