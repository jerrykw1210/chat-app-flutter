import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/general/cubit/country_picker_cubit.dart';

class PhoneNoTextField extends StatelessWidget {
  PhoneNoTextField({super.key, required this.phoneNoController});
  TextEditingController phoneNoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: phoneNoController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter
            .digitsOnly // Allow only numbers with up to two decimal places
      ],
      decoration: InputDecoration(
          hintText: Strings.pleaseFillInPhoneNumber,
          prefixIcon: BlocBuilder<CountryPickerCubit, CountryPickerState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.only(left: 14, right: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CountryCodePicker(
                      showFlagDialog: true,
                      showFlag: false,
                      padding: EdgeInsets.zero,
                      initialSelection: "MY",
                      onInit: (value) => context
                          .read<CountryPickerCubit>()
                          .selectCountry(value),
                      textStyle: const TextStyle(
                          color: Color.fromRGBO(52, 64, 84, 1),
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          fontFamily: "Inter"),
                      // builder: (country) {
                      //   log("country name ${country?.name}");
                      //   if (country?.name == "Taiwan") {
                      //     return CountryCode(
                      //         name: "China(Taiwan)",
                      //         code: "CN(TW)",
                      //         dialCode: "886");
                      //   }
                      // },
                      onChanged: (value) {
                        context.read<CountryPickerCubit>().selectCountry(value);
                      },
                    ),
                    // Text(
                    //   state.selectedCountry?.dialCode == null
                    //       ? "+60"
                    //       : "${state.selectedCountry?.dialCode}",
                    //   style: const TextStyle(
                    //       color: Color.fromRGBO(52, 64, 84, 1),
                    //       fontWeight: FontWeight.w400,
                    //       fontSize: 16,
                    //       fontFamily: "Inter"),
                    // ),
                    const SizedBox(width: 2),
                    SvgPicture.asset("assets/Buttons/chevron-down.svg",
                        width: 20, height: 20)
                  ],
                ),
              );
            },
          )),
    );
  }
}
