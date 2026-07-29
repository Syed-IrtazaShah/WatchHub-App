// ignore_for_file: file_names

import 'package:flutter/material.dart';

class KeyboardUtils {

  static void  hidekeyboar(BuildContext context)
  {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if(!currentFocus.hasPrimaryFocus){

      currentFocus.unfocus();
      
    }


  }
  
}