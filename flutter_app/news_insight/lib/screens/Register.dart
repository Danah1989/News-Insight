import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../classes/AppUser.dart';
import '../classes/Utilities.dart';
import 'Login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  var passwordVisible =false;
  var confPasswordVisible =false;
  var nameController =  TextEditingController();
  var emailController =  TextEditingController();
  var phoneController =  TextEditingController();
  var passController =  TextEditingController();
  var confPassController =  TextEditingController();
  var emailIsPressed =false;
  var phoneIsPressed =false;
  var passwordPressed =false;
  var confPasswordPressed =false;
  var nameIsPressed =false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  final _formKey =GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {

    void showHidePass(){
      setState(() {
        passwordVisible=!passwordVisible;
      });
    }
    String? validatePassword(String? value) {
      return Utilities.validatePassword(value, passController.text,passController.text);
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
                  height: 5.h,
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
                  'Register',
                  style: TextStyle(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2254c5)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20.h,
                ),
                SizedBox(
                    width: 350.w,
                    //height: 48.h,

                    child: Focus(
                      onFocusChange: (hasFocus){
                        if(hasFocus)
                        {
                          nameIsPressed=true;setState(() {});
                        }
                        else
                        {
                          nameIsPressed=false;setState(() {});
                        }
                      },
                      child: TextFormField(
                        controller: nameController,
                        validator: Utilities.validateName,
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
                              image:  AssetImage('images/user2.png'),
                              fit: BoxFit.fill,
                              width: 20.w,
                              height: 20.h,
                              color: nameIsPressed? const Color(0xFF2254c5):const Color(0xffA7A7A7),
                            ),
                          ),
                          
                          contentPadding: EdgeInsets.fromLTRB(0.0, 7.h, 0.0, 0.0),
                          filled:true ,
                          fillColor: const Color(0xffFAFAFA),
                          hintText:  'Name',
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
                ),//email  textField
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
                          emailIsPressed=true;setState(() {});
                        }
                        else
                        {
                          emailIsPressed=false;setState(() {});
                        }
                      },
                      child: TextFormField(
                        controller: emailController,
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
                ),//email  textField
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
                          phoneIsPressed=true;setState(() {});
                        }
                        else
                        {
                          phoneIsPressed=false;setState(() {});
                        }
                      },
                      child: TextFormField(
                        controller: phoneController,
                        keyboardType:TextInputType.phone,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: Utilities.validateMobile,
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
                              image:  AssetImage('images/phone2.png'),
                              fit: BoxFit.fill,
                              width: 20.w,
                              height: 20.h,
                              color: phoneIsPressed? const Color(0xFF2254c5):const Color(0xffA7A7A7),
                            ),
                          ),




                          contentPadding: EdgeInsets.fromLTRB(0.0, 7.h, 0.0, 0.0),
                          filled:true ,
                          fillColor: const Color(0xffFAFAFA),
                          hintText:  'Phone',
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
                                color: passwordPressed? const Color(0xffA7A7A7):const Color(0xffA7A7A7),
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
                  height: 10.h,
                ),
                SizedBox(
                    width: 350.w,
                    //height: 48.h,

                    child: Focus(
                      onFocusChange: (hasFocus){
                        if(hasFocus)
                        {
                          confPasswordPressed=true;setState(() {});
                        }
                        else
                        {
                          confPasswordPressed=false;setState(() {});
                        }
                      },
                      child: TextFormField(
                        controller: confPassController,
                        obscureText: !confPasswordVisible,
                        obscuringCharacter: '*',
                        validator: validatePassword,
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
                          prefixIcon:Padding(
                            padding: EdgeInsets.only(
                                top: 14.h,bottom: 14.h,left: 14.w,right: 14.w),
                            child: Image(
                              image:  const AssetImage('images/solar_lock-password-bold.png'),
                              fit: BoxFit.fill,
                              width: 20.w,
                              height: 20.h,
                              color: confPasswordPressed? const Color(0xFF2254c5):const Color(0xffA7A7A7),
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
                                color: confPasswordPressed? const Color(0xffA7A7A7):const Color(0xffA7A7A7),
                              ),
                            ),
                          ),
                          contentPadding: EdgeInsets.fromLTRB(0.0, 7.h, 0.0, 0.0),
                          filled:true ,
                          fillColor: const Color(0xffFAFAFA),
                          hintText:  'Confirm Password',
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
                  height: 20.h,
                ),
                InkWell(
                  onTap: () {
                    _formKey.currentState!.validate();
                    register();
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
                        'Register',
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
                  "have account?",
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
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(width: 1,color:Color(0xffF9B217), )
                        )
                    ),
                    child: Text(
                      'Login Now',
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

  void register()  async{
    if(_formKey.currentState!.validate())
    {
      String name = nameController.text;
      String mobile = phoneController.text;
      String email = emailController.text;
      String pass = passController.text;
      AppUser user = AppUser();
      user.name=name;
      user.mobile=mobile;
      user.email=email;
      user.password=pass;
      Utilities.showLoaderDialog(context);
      QuerySnapshot querySnapshot= await firestore.collection("Users")
          .where("mobile",isEqualTo: user.mobile).get();
      if(querySnapshot.docs.isNotEmpty)
      {
        Navigator.pop(context);
        Utilities.showNotificationDialog(context, true, "mobile number is used before",false,null);
        return;
      }

      try
      {
        UserCredential credential = await auth.createUserWithEmailAndPassword(email: email, password: pass);
        user.id=credential.user!.uid;
        await firestore.collection("Users").doc(user.id).set(user.toMap());
        Navigator.pop(context);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context2) => const Login()));
      } on FirebaseAuthException catch(e){
        if(e.code == "weak-password")
        {

          Navigator.pop(context);
          Utilities.showNotificationDialog(context, true, "Weak password",false,null);
        }else if (e.code == 'email-already-in-use')
        {
          Navigator.pop(context);
          Utilities.showNotificationDialog(context, true, "email already in use",false,null);
        }
      }catch (e)
      {
        print(e);
        Navigator.pop(context);
      }





    }


  }
}
