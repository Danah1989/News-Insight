
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



class Utilities
{

  static showNotificationDialog(BuildContext context,bool isError,String message,
      bool withButtons,Function? onAccept ){
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    Dialog alert=Dialog(
      surfaceTintColor: const Color(0x77ffffff),

      child: Container(
        width: double.infinity,height:withButtons? 281.h:267.h,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
            color:  Color(0xFFc8d7fa)
        ),

        child:Column(
          children: [
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: InkWell(
                onTap: (){Navigator.pop(context);},
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                      top: 20.h,end: 20.w),
                  child: Image(
                    color: Color(0xFF2254c5),
                    image: const AssetImage('images/close.png'),
                    fit: BoxFit.fill,
                    width: shortestSide<600?32.w:32.h ,
                    height: 32.h,
                  ),
                ),
              ),
            ),
            Center(
              child: Stack(
                children: [

                  Padding(
                    padding:  EdgeInsets.only(top:33.h,left: 40.h,right: 40.h),
                    child: Image(
                      color:withButtons?Color(0xFF2254c5): isError?Color(0xFFbf0404):Color(0xFF2c8201),
                      image: AssetImage(withButtons?"images/info.png": isError?"images/false.png":"images/true.png"),
                      fit: BoxFit.fill,
                      width: shortestSide<600?40.w:40.h ,
                      height: 40.h,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15.h,),
            Text(message,
              style: TextStyle(
                fontSize: 18.sp,
                fontFamily: 'Cairo-Bold',
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2254c5),

              ),
              textScaleFactor:shortestSide<600?1:.8 ,
            ),
            SizedBox(height: 10.h,),
            Visibility(
              visible: withButtons,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          onAccept!();
                          },
                        child: Container(
                          width: 120.w,
                          height: 45.h,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('images/gold_button.png'),
                              fit: BoxFit.fill,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'نعم',
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xff171716)),
                              textScaleFactor:shortestSide<600?1:.8 ,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),


                    InkWell(
                      onTap: () {Navigator.pop(context);},
                      child: Container(
                        width: 120.w,
                        height: 45.h,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('images/gold_button.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'لا',
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w700,
                                color: const Color(0xff171716)),
                            textScaleFactor:shortestSide<600?1:.8 ,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            )
          ],
        ) ,
      ),

    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }

  static showLoaderDialog(BuildContext context){
    AlertDialog alert=AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(margin: const EdgeInsets.only(left: 7),child:const Text("Loading..." )),
        ],),
    );
    showDialog(barrierDismissible: false,

      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }

  static String? validateEmail(String? value) {
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);

    if( !regex.hasMatch(value!))
    {
      return 'Email is invalid';
    }
    else
    {
      return null;
    }

  }

  static String? validatePassword(String? value,String? pass,String? confPass) {
    if(value==null||value.length<6 )
    {
      return'Password must be 6 or more digits';
    }
    if(pass!=confPass)
    {
      return "Password fields not match";
    }
    return null;
  }

  static String? validateMobile(String? value) {
    if( value==null || value.length!=10 || !value.startsWith("05"))
    {
      return 'phone is invalid must be 05XXXXXXXX';
    }
    else
    {
      return null;
    }
  }
  static String? validateName(String? value) {
    if( value==null || value.isEmpty)
    {
      return 'This field is required';
    }
    else
    {
      return null;
    }
  }
}