import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../classes/NewsInsightDrawer.dart';
import 'Result.dart';


late List<HistoryItem> historyItems;

// ─── App root ─────────────────────────────────────────────────────────────────
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<List<HistoryItem>>(
      future: getData(),
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: CircularProgressIndicator(),
        ); // Loading state
  } else if (snapshot.hasError) {
    return Text('Error: ${snapshot.error}'); // Error state
    } else {
    return HistoryList(
          items: historyItems
          );
    }
    },
    );
  }
}

// ─── Data model ───────────────────────────────────────────────────────────────


class HistoryItem {
  const HistoryItem({required this.verdict, required this.text,required this.json});
  final String verdict;
  final String text;
  final Map<String,dynamic> json;

  /// Returns the first six words of [text].
  String get preview {
    final words = text.trim().split(RegExp(r'\s+'));
    return words.take(6).join(' ') + (words.length > 6 ? '…' : '');
  }
}

// ─── Palette ──────────────────────────────────────────────────────────────────
abstract final class _Colors {
  static const navy      = Color(0xFF0D1F5C);
  static const royalBlue = Color(0xFF1A3A8F);
  static const skyLight  = Color(0xffe8e8e8);
  static const cardBg    = Color(0xFFF5F8FF);

  // Verdict colours
  static const misleadBg     = Color(0xFFFDECEC);
  static const misleadBorder = Color(0xFFE53935);
  static const misleadText   = Color(0xFFB71C1C);
  static const misleadIcon   = Color(0xFFE53935);

  static const reliableBg     = Color(0xFFE8F5E9);
  static const reliableBorder = Color(0xFF2E7D32);
  static const reliableText   = Color(0xFF1B5E20);
  static const reliableIcon   = Color(0xFF2E7D32);
}

// ─── History screen (StatelessWidget) ────────────────────────────────────────
class HistoryList extends StatelessWidget {
  const HistoryList({super.key, required this.items});
  final List<HistoryItem> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const NewsInsightDrawer(),
      backgroundColor: _Colors.skyLight,
      body: Builder(builder: (BuildContext sContext){
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 35.0),
                    child: Text(
                      'Search History',
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

              // ── Card grid ────────────────────────────────────────────────
              Expanded(
                child: items.isEmpty
                    ? const _EmptyState()
                    : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.05,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _HistoryCard(item: items[i]),
                ),
              ),
            ],
          ),
        );
      })
    );
  }

}

// ─── History card ─────────────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item});
  final HistoryItem item;

  bool get _isMisleading => item.verdict == 'Misleading';

  Color get _bg     => _isMisleading ? _Colors.misleadBg     : _Colors.reliableBg;
  Color get _border => _isMisleading ? _Colors.misleadBorder  : _Colors.reliableBorder;
  Color get _text   => _isMisleading ? _Colors.misleadText    : _Colors.reliableText;
  Color get _icon   => _isMisleading ? _Colors.misleadIcon    : _Colors.reliableIcon;

  IconData get _verdictIcon =>
      _isMisleading ? Icons.warning_amber_rounded : Icons.verified_rounded;

  String get _verdictLabel =>
      _isMisleading ? 'Misleading' : 'Reliable';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _Colors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _Colors.navy.withOpacity(0.07)),
        boxShadow: [
          BoxShadow(
            color: _Colors.navy.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) =>  Result(historyResult: item.json,hasRun: true,)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Verdict badge ───────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                        color: _border.withOpacity(0.4), width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_verdictIcon, color: _icon, size: 13),
                      const SizedBox(width: 5),
                      Text(
                        _verdictLabel,
                        style: TextStyle(
                          color: _text,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ── Divider ─────────────────────────────────────────────
                Container(
                  height: 1,
                  color: _Colors.navy.withOpacity(0.07),
                ),

                const SizedBox(height: 14),

                // ── Preview text (first 6 words) ────────────────────────
                Text(
                  item.preview,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _Colors.navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),

                const Spacer(),

                // ── Chevron hint ────────────────────────────────────────
                Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: _Colors.navy.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _Colors.cardBg,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _Colors.navy.withOpacity(0.08),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Icon(
              Icons.history_rounded,
              size: 40,
              color: _Colors.navy.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No searches yet',
            style: TextStyle(
              color: _Colors.navy.withOpacity(0.5),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your verified news will appear here.',
            style: TextStyle(
              color: _Colors.navy.withOpacity(0.35),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

Future<List<HistoryItem>> getData() async{
   var userId = FirebaseAuth.instance.currentUser?.uid;
   FirebaseFirestore firestore = FirebaseFirestore.instance;
   final docSnap= await firestore.collection('search_result').where('user_id',isEqualTo: userId).orderBy('timestamp').get();
   historyItems=<HistoryItem>[];
   historyItems.clear();
   for(var doc in docSnap.docs)
     {
       if(doc.get('verdict_source')=='model')
         {
           var item= HistoryItem(
             json:doc.data() ,
             verdict: doc.get('model_label'),
             text: doc.get('extracted_claim'),
           );
           historyItems.add(item);
         }
       else
         {
           var item= HistoryItem(
             json:doc.data() ,
             verdict: doc.get('fact_check_label'),
             text: doc.get('extracted_claim'),
           );
           historyItems.add(item);
         }

     }
   return historyItems;
 }