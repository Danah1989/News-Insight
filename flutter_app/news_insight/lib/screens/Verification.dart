import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:news_insight/screens/Result.dart';

import '../classes/NewsInsightDrawer.dart';
import '../classes/Utilities.dart';
import '../services/fact_check_store.dart';

class Verification extends StatefulWidget {
  const Verification({super.key});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  bool _isChecking = false;
  final _controller =  TextEditingController();
  final _formKey =GlobalKey<FormState>();

  Future<void> _handleCheck() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Enforce 100-word limit on the client side as well
    final wordCount = text.split(RegExp(r'\s+')).length;
    if (wordCount > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please keep your input under 100 words.')),
      );
      return;
    }

    setState(() => _isChecking = true);

    final store = Provider.of<FactCheckStore>(context, listen: false);

    try {
      await store.checkFact(text);
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Result(historyResult: null, hasRun: false,)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to check claim. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }
  @override
  Widget build(BuildContext mContext) {
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
      endDrawer: const NewsInsightDrawer(),
      backgroundColor: const Color(0xffe8e8e8),
      body: Builder(builder: (BuildContext sContext){
        return SingleChildScrollView(
          child: SafeArea(
              child:Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: Text(
                              'News Verification',
                              style: TextStyle(
                                  fontSize: 30.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2254c5)),
                              textAlign: TextAlign.center,
                            ),
                        ),


                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Card(
                            child: IconButton(
                              icon: Icon(Icons.menu), // Custom icon
                              onPressed: () => Scaffold.of(sContext).openEndDrawer(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 35.h,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 30,left: 30),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: 10,
                        controller: _controller,
                        validator: Utilities.validateName,
                        cursorColor: const Color(0xFF2254c5),
                        style:textFormStyle,
                        decoration:  InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                          ),

                          contentPadding: EdgeInsets.fromLTRB(7.h, 7.h, 7.h, 7.h),
                          filled:true ,
                          fillColor: const Color(0xffFAFAFA),
                          hintText:  'Enter the news you want to verify',
                          hintStyle: textHintStyle,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),

                          ),
                          focusedBorder:   OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),

                              borderSide: const BorderSide(
                                width: 2,
                                color: Color(0xFF2254c5),
                              )
                          ),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: const BorderSide(
                                  color: Colors.red
                              )
                          ),

                        ),
                      ),
                    ),
                    SizedBox(
                      height: 35.h,
                    ),
                    InkWell(
                      onTap: () {
                        Utilities.showLoaderDialog(context);
                        _formKey.currentState!.validate();
                        _isChecking ? null : _handleCheck();
                      },
                      child: Container(
                        width: 300.w,
                        height: 52.h,
                        decoration: const BoxDecoration(
                            color: Color(0xFF2254c5),
                            borderRadius: BorderRadius.all(Radius.circular(15))
                        ),
                        child: Center(
                          child: Text(
                            'Verify',
                            style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xffffffff)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 35.h,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Text(
                        'This tool provides guidance based on analysis and trusted sources, but it should not be relied on as a final judgment.',
                        style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2254c5)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              )
          ),
        );
      }),
    );
  }
}
