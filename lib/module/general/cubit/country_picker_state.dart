part of 'country_picker_cubit.dart';

class CountryPickerState extends Equatable {
  final CountryCode? selectedCountry;

  const CountryPickerState({this.selectedCountry});

  CountryPickerState copyWith({CountryCode? selectedCountry}) {
    return CountryPickerState(
        selectedCountry: selectedCountry ?? this.selectedCountry);
  }

  @override
  List<Object?> get props => [selectedCountry];
}
