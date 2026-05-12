import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:news_insight/screens/Verification.dart';

import '../classes/AppUser.dart';
import '../classes/Utilities.dart';
import 'Register.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var emailController =  TextEditingController();
  var passController =  TextEditingController();
  var passwordVisible =false;
  var emailIsPressed =false;
  var passwordPressed =false;
  final _formKey =GlobalKey<FormState>();
  FirebaseAuth auth =FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    void showHidePass(){
      setState(() {
        passwordVisible=!passwordVisible;
      });
    }

    TextStyle textFormStyle = TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: const Color(0xff171716),);
    TextStyle textHintStyle =TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: const Color(0xff171716),
    );
    return Scaffold(
      backgroundColor: const Color(0xffe8e8e8),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 40.h,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      image: const AssetImage('images/logo1.png'),
                      fit: BoxFit.fill,
                      width: 170.w,
                      height: 160.h,
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),
                Text(
                  'Login',
                  style: TextStyle(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2254c5)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 40.h,
                ),
                SizedBox(
                    width: 350.w,
                    //height: 48.h,

                    child: Focus(
                      onFocusChange: (hasFocus){
                        if(hasFocus)
                        {
                          emailIsPressed=true;setState(() {});
                        }
                        else
                        {
                          emailIsPressed=false;setState(() {});
                        }
                      },
                      child: TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.text,
                        inputFormatters: null,
                        validator: Utilities.validateEmail,
                        cursorColor: const Color(0xFF2254c5),
                        style:textFormStyle,
                        decoration:  InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.red, width: 0.0),
                          ),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(
                                top: 14.h,bottom: 14.h,left: 14.w,right: 14.w),
                            child: Image(
                              image:  AssetImage('images/email.png'),
                              fit: BoxFit.fill,
                              width: 20.w,
                              height: 20.h,
                              color: emailIsPressed? const Color(0xFF2254c5):const Color(0xffA7A7A7),
                            ),
                          ),
                          contentPadding: EdgeInsets.fromLTRB(0.0, 7.h, 0.0, 0.0),
                          filled:true ,
                          fillColor: const Color(0xffFAFAFA),
                          hintText:  'Email',
                          hintStyle: textHintStyle,

                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: const BorderSide(
                                  color: Colors.red
                              )
                          ),

                        ),
                      ),
                    )
                ),//email or phone textField
                SizedBox(
                  height: 10.h,
                ),
                SizedBox(
                    width: 350.w,
                    //height: 48.h,

                    child: Focus(
                      onFocusChange: (hasFocus){
                        if(hasFocus)
                        {
                          passwordPressed=true;setState(() {});
                        }
                        else
                        {
                          passwordPressed=false;setState(() {});
                        }
                      },
                      child: TextFormField(
                        controller: passController,
                        obscureText: !passwordVisible,
                        obscuringCharacter: '*',
                        validator: validatePassword,
                        cursorColor: const Color(0xffFAFAFA),
                        style:textFormStyle,
                        decoration:  InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.red, width: 0.0),
                          ),
                          prefixIcon:Padding(
                            padding: EdgeInsets.only(
                                top: 14.h,bottom: 14.h,left: 14.w,right: 14.w),
                            child: Image(
                              image:  const AssetImage('images/solar_lock-password-bold.png'),
                              fit: BoxFit.fill,
                              width: 20.w,
                              height: 20.h,
                              color: passwordPressed? const Color(0xFF2254c5):const Color(0xffA7A7A7),
                            ),
                          ),


                          suffixIcon: InkWell(
                            onTap: showHidePass,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: 14.h,bottom: 14.h,left: 14.w,right: 14.w),
                              child: Image(
                                image: const AssetImage('images/solar_eye-bold.png'),
                                fit: BoxFit.fill,
                                width: 20.w,
                                height: 20.h,
                                color: passwordPressed? const Color(0xffFAFAFA):const Color(0xffA7A7A7),
                              ),
                            ),
                          ),
                          contentPadding: EdgeInsets.fromLTRB(0.0, 7.h, 0.0, 0.0),
                          filled:true ,
                          fillColor: const Color(0xffFAFAFA),
                          hintText:  'Password',
                          hintStyle: textHintStyle,

                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: const BorderSide(
                                  color: Colors.red
                              )
                          ),

                        ),
                      ),
                    )
                ),//password  textField

                SizedBox(
                  height: 8.h,
                ),

                SizedBox(
                  height: 50.h,
                ),
                InkWell(
                  onTap: () {
                    _formKey.currentState!.validate();
                     login();
                  },
                  child: Container(
                    width: 350.w,
                    height: 52.h,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2254c5),
                      borderRadius: BorderRadius.all(Radius.circular(15))
                    ),
                    child: Center(
                      child: Text(
                        'Login',
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xffffffff)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 40.h,
                ),
                Text(
                  "You don't have account?",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2254c5),

                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 2.h,
                ),
                InkWell(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context2)=>const Register()));
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(width: 1,color:Color(0xFF2254c5), )
                        )
                    ),
                    child: Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2254c5),

                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? validatePassword(String? value) {
    return Utilities.validatePassword(value, passController.text,passController.text);
  }

  void login() async{
    if(_formKey.currentState!.validate())
    {
      String email = emailController.text;
      String pass = passController.text;
      Utilities.showLoaderDialog(context);
      try
      {
        UserCredential credential= await auth.signInWithEmailAndPassword(email: email, password: pass);
        var userDoc = await firestore.collection("Users").doc(credential.user?.uid).get();
        AppUser user = AppUser.fromJason( userDoc.data()!);
        Navigator.pop(context);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context2) => Verification()));
      }on FirebaseAuthException catch (error)
      {
        if(error.code == "invalid-credential" )
        {

          Navigator.pop(context);
          Utilities.showNotificationDialog(context, true, "Invalid credentials",false,null);
        }else if (error.code == 'network-request-failed')
        {
          Navigator.pop(context);
          Utilities.showNotificationDialog(context, true, "No Internet",false,null);
        }
      }
      catch (e)
      {
        print(e);
        Navigator.pop(context);

      }
    }
  }



}
