import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran/quran.dart' as quran;

void main() => runApp(const QuranNoorApp());

class QuranNoorApp extends StatelessWidget {
  const QuranNoorApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ٱلۡقُرۡآنُ ٱلۡكَرِيمُ',
      theme: ThemeData.dark(useMaterial3: true).copyWith(scaffoldBackgroundColor: const Color(0xFF0F0F0F)),
      home: const QuranNoorHome(),
    );
  }
}

class QuranNoorHome extends StatelessWidget {
  const QuranNoorHome({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ٱلۡقُرۡآنُ ٱلۡكَرِيمُ - مصحف المدينة", style: TextStyle(fontSize: 18)), centerTitle: true, backgroundColor: Color(0xFF1E1E1E)),
      body: ListView.builder(
        itemCount: 114,
        itemBuilder: (context, i) {
          int num = i + 1;
          return Card(
            color: Color(0xFF1E1E1E),
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.green.shade900, child: Text("$num", style: TextStyle(color: Colors.white))),
              title: Text(quran.getSurahNameArabic(num), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              subtitle: Text("${quran.getVerseCount(num)} آية"),
              trailing: Icon(Icons.play_circle, color: Colors.green, size: 35),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SurahNoorPage(surahNumber: num))),
            ),
          );
        },
      ),
    );
  }
}

class SurahNoorPage extends StatefulWidget {
  final int surahNumber;
  const SurahNoorPage({super.key, required this.surahNumber});
  @override
  State<SurahNoorPage> createState() => _SurahNoorPageState();
}

class _SurahNoorPageState extends State<SurahNoorPage> {
  final player = AudioPlayer();
  bool isPlaying = false;
  String selectedReciter = "عبد الباسط";
  final Map<String, String> reciters = {
    "عبد الباسط": "Abdul_Basit_Murattal_192kbps",
    "المنشاوي": "Minshawy_Murattal_128kbps",
    "ياسر الدوسري": "Yasser_Ad-Dosari_128kbps",
  };

  Future<void> playSurah() async {
    if (isPlaying) { await player.pause(); setState(() => isPlaying = false); return; }
    int count = quran.getVerseCount(widget.surahNumber);
    String code = reciters[selectedReciter]!;
    List<AudioSource> sources = [];
    for (int i = 1; i <= count; i++) {
      String sId = widget.surahNumber.toString().padLeft(3, '0');
      String vId = i.toString().padLeft(3, '0');
      sources.add(AudioSource.uri(Uri.parse("https://everyayah.com/data/$code/$sId$vId.mp3")));
    }
    await player.setAudioSource(ConcatenatingAudioSource(children: sources));
    await player.play();
    setState(() => isPlaying = true);
  }

  @override
  void dispose() { player.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    int count = quran.getVerseCount(widget.surahNumber);
    return Scaffold(
      appBar: AppBar(title: Text(quran.getSurahNameArabic(widget.surahNumber)), backgroundColor: Color(0xFF1E1E1E)),
      body: Column(children: [
        Container(padding: EdgeInsets.all(12), color: Color(0xFF1E1E1E), child: Row(children: [IconButton(icon: Icon(isPlaying? Icons.pause_circle_filled : Icons.play_circle_filled, size: 50, color: Colors.green), onPressed: playSurah), Text(selectedReciter)])),
        Expanded(child: ListView.builder(padding: EdgeInsets.all(12), itemCount: count + 1, itemBuilder: (context, i) {
          if (i == count) {
            return Container(margin: EdgeInsets.only(top: 30, bottom: 40), padding: EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.green.withOpacity(0.12), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.green)), child: Column(children: [Text("الفاتحة الى المرحوم ناصر عزيز", textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)), SizedBox(height: 15), Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ الرَّحْمَٰنِ الرَّحِيمِ مَالِكِ يَوْمِ الدِّينِ إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, height: 1.9, color: Colors.greenAccent))] ));
          }
          return Container(padding: EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))), child: Text("${quran.getVerse(widget.surahNumber, i+1)} ﴿${i+1}﴾", textDirection: TextDirection.rtl, style: TextStyle(fontSize: 22, height: 1.8), textAlign: TextAlign.right));
        }))
      ]),
    );
  }
}