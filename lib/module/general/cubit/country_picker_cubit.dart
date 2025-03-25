import 'package:bloc/bloc.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:equatable/equatable.dart';

part 'country_picker_state.dart';

class CountryPickerCubit extends Cubit<CountryPickerState> {
  CountryPickerCubit() : super(const CountryPickerState());

  selectCountry(dynamic selectedCountry) {
    emit(state.copyWith(selectedCountry: selectedCountry));
  }
}
