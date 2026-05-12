import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../classes/NewsInsightDrawer.dart';
import '../services/fact_check_store.dart';



// ─── App root ────────────────────────────────────────────────────────────────
class Result extends StatelessWidget {
  final  historyResult;
  bool hasRun ;
   Result({super.key,required this.historyResult,required this.hasRun});
  @override
  Widget build(BuildContext context) {
    final store = Provider.of<FactCheckStore>(context);
    Map<String,dynamic> result ;
    if(historyResult!=null)
      {
         result = historyResult;
      }
    else
      {
         result = store.currentResult;
         if(!hasRun){
           FirebaseFirestore firestore =FirebaseFirestore.instance;
           var doc = firestore.collection('search_result').doc();
           result['doc_id']=doc.id;
           var userid = FirebaseAuth.instance.currentUser?.uid;
           result['user_id']=userid;
           result['timestamp']=Timestamp.now();
           doc.set(result);
           hasRun=true;
         }



      }


    // Show loader if result is not ready yet
    if (result.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Show error state if the API call failed
    if (result.containsKey('error')) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(result['error'])),
      );
    }
    // ── Parse response fields ─────────────────────────────────────────────────
    final verdictSource  = result['verdict_source'] ?? 'model';
    final isFactCheck    = verdictSource == 'fact_check';

    // When fact_check is the source use fact_check_label, otherwise model_label
    final label          = isFactCheck
        ? (result['fact_check_label'] ?? result['model_label'] ?? 'Unknown')
        : (result['model_label'] ?? 'Unknown');

    // When fact_check is the source use fact_check_confidence, otherwise model_confidence
    final confidence     = isFactCheck
        ? ((result['fact_check_confidence'] ?? result['model_confidence'] ?? 0.0) as num).toDouble()
        : ((result['model_confidence'] ?? 0.0) as num).toDouble();

    final extractedClaim = result['extracted_claim'] ?? '';
    final awareness      = result['awareness'] ?? '';
    final prompt         = result['prompt'] ?? '';
    final factCheckHits  = result['fact_check_hits'] as List? ?? [];
    var sources=<SourceItem>[];
    for (var hit in factCheckHits) {
      var ss =SourceItem(title: hit['text'], url: hit['url']);
      sources.add(ss);
    }
    return AnalysisResultScreen(
        claim: extractedClaim,
        scorePercent: confidence,
        verdict: label,
        awarenessText:awareness,
        sources:  sources,
      prompt: prompt,
      isFactCheck:isFactCheck ,
        verdictSource: verdictSource,
      );
  }
}

// ─── Data model ──────────────────────────────────────────────────────────────
class SourceItem {
  const SourceItem({required this.title, required this.url});
  final String title;
  final String url;
}

// ─── Palette constants ────────────────────────────────────────────────────────
abstract final class _Colors {
  static const navy       = Color(0xFF0D1F5C);
  static const royalBlue  = Color(0xFF1A3A8F);
  static const skyLight   = Color(0xffe8e8e8);
  static const cardBg     = Color(0xFFF5F8FF);
  static const barTrack   = Color(0xFFDDE6F5);
  static const mislead    = Color(0xFFE53935);
  static const accurate   = Color(0xFF2E7D32);
  static const unverified = Color(0xFFCFAD24);
}

Color _verdictColor(String verdict) {
  final v = verdict;
  if (v =='Misleading') {return _Colors.mislead;}
  else  {return _Colors.accurate;}
}

IconData _verdictIcon(String verdict) {
  final v = verdict.toLowerCase();
  if (v =='Misleading')  {return Icons.warning_amber_rounded;}
  else  { return Icons.check_circle_rounded;}

}


// ─── Main screen ─────────────────────────────────────────────────────────────
// 100% StatelessWidget — tabs via DefaultTabController,
// animation via TweenAnimationBuilder (no AnimationController needed).
class AnalysisResultScreen extends StatelessWidget {
  const AnalysisResultScreen({
    super.key,
    required this.claim,
    required this.scorePercent,
    required this.verdict,
    required this.awarenessText,
    required this.sources,
    required this.prompt,
    required this.isFactCheck,
    required this.verdictSource,
  });

  final String claim;
  final double scorePercent; // 0–100
  final String verdict;
  final String awarenessText;
  final List<SourceItem> sources;
  final String prompt;
  final bool isFactCheck;
  final String  verdictSource;

  @override
  Widget build(BuildContext context) {
    // DefaultTabController injects a TabController into the widget tree
    // so TabBar / TabBarView can use it without any State.
    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Scaffold(
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
                      padding: const EdgeInsets.only(right: 100.0),
                      child: Text(
                        'Result',
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ClaimCard(claim: claim),
                        const SizedBox(height: 20),
                        _ScoreCard(
                          scorePercent: scorePercent.toInt(),
                          verdict: verdict,prompt: prompt,verdictSource: verdictSource,
                        ),
                        const SizedBox(height: 20),
                        if (isFactCheck && sources.isNotEmpty)
                          _TabSection(
                            awarenessText: awarenessText,
                            sources: sources,
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: _Colors.cardBg,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: _Colors.navy.withOpacity(0.08),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),

                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(18),
                              child: Text(
                                awarenessText,
                                style: TextStyle(
                                  color: _Colors.navy.withOpacity(0.78),
                                  fontSize: 14,
                                  height: 1.75,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        })
      ),
    );
  }
}

// ─── Top strip (no AppBar) ────────────────────────────────────────────────────
class _TopStrip extends StatelessWidget {
  const _TopStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_Colors.royalBlue, _Colors.navy],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x400D1F5C),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          InkWell(
            onTap: () => Navigator.maybePop(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Analysis Result',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          // Brand pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.language_rounded, color: Colors.white, size: 13),
                SizedBox(width: 4),
                Text(
                  'NEWS INSIGHT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Claim card ───────────────────────────────────────────────────────────────
class _ClaimCard extends StatelessWidget {
  const _ClaimCard({required this.claim});
  final String claim;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: _Colors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _Colors.navy.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: _Colors.navy.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _Colors.navy.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.format_quote_rounded,
              color: _Colors.navy,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              claim,
              style: const TextStyle(
                color: _Colors.navy,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Score card ───────────────────────────────────────────────────────────────
// Uses TweenAnimationBuilder — animates from 0 to scorePercent
// with zero boilerplate State or AnimationController.
class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.scorePercent,
    required this.verdict,
    required this.prompt,
    required this.verdictSource
  });

  final int scorePercent;
  final String verdict;
  final String prompt;
  final String verdictSource;
  @override
  Widget build(BuildContext context) {
    final color = _verdictColor(verdict);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _Colors.cardBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _Colors.navy.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Verdict badge ──────────────────────────────────────────────
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: color.withOpacity(0.35), width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_verdictIcon(verdict), color: color, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    verdict,
                    style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),


          const SizedBox(height: 14),

          // ── Label + animated score number ──────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'CREDIBILITY SCORE',
                style: TextStyle(
                  color: _Colors.navy.withOpacity(0.55),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              // TweenAnimationBuilder<double>(
              //   tween: Tween(begin: 0, end: scorePercent.toDouble()),
              //   duration: const Duration(milliseconds: 1400),
              //   curve: Curves.easeOutCubic,
              //   builder: (_, value, __) => Text(
              //     '${value.round()}%',
              //     style: TextStyle(
              //       color: color,
              //       fontSize: 28,
              //       fontWeight: FontWeight.w800,
              //       height: 1,
              //     ),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 20),
          // ── Animated progress bar ──────────────────────────────────────
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: scorePercent / 100),
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeOutCubic,
            builder: (_, fraction, __) => ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Stack(
                children: [
                  // Track
                  Container(height: 14, color: _Colors.barTrack),
                  // Fill
                  FractionallySizedBox(
                    widthFactor: fraction,
                    child: Container(
                      height: 14,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withOpacity(0.7), color],
                        ),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),


          const SizedBox(height: 20),
          // ── prompt badge ──────────────────────────────────────────────
          if (verdictSource =='model')
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                color: _Colors.unverified.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: _Colors.unverified.withOpacity(0.35), width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: _Colors.unverified, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      prompt,
                      style: TextStyle(
                        color: _Colors.unverified,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab section ──────────────────────────────────────────────────────────────
class _TabSection extends StatelessWidget {
  const _TabSection({
    required this.awarenessText,
    required this.sources,
  });

  final String awarenessText;
  final List<SourceItem> sources;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _Colors.cardBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _Colors.navy.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tab bar header
          Container(
            decoration: const BoxDecoration(
              color: _Colors.cardBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: TabBar(
              labelColor: _Colors.royalBlue,
              unselectedLabelColor: Color(0x730D1F5C),
              indicatorColor: _Colors.royalBlue,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Sources'),
                Tab(text: 'Awareness'),
              ],
            ),
          ),

          // Tab views
          SizedBox(
            height: 250,
            child: TabBarView(
              children: [
                // Sources tab
                ListView.separated(
                  padding: const EdgeInsets.all(18),
                  itemCount: sources.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _SourceTile(item: sources[i]),
                ),

                // Awareness tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    awarenessText,
                    style: TextStyle(
                      color: _Colors.navy.withOpacity(0.78),
                      fontSize: 14,
                      height: 1.75,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Source tile ──────────────────────────────────────────────────────────────
class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.item});
  final SourceItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        var url =Uri.parse(item.url);
        launchUrl(url);

      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _Colors.skyLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _Colors.navy.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            const Icon(Icons.link_rounded, color: _Colors.royalBlue, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  color: _Colors.navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              color: _Colors.navy.withOpacity(0.35),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}