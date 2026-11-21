
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() => runApp(const JarvisApp());

class JarvisApp extends StatelessWidget {
  const JarvisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF050B16),
        colorScheme: const ColorScheme.dark(
          primary: Colors.cyanAccent,
        ),
      ),
      home: const JarvisHome(),
    );
  }
}

class JarvisHome extends StatefulWidget {
  const JarvisHome({super.key});

  @override
  State<JarvisHome> createState() => _JarvisHomeState();
}

class _JarvisHomeState extends State<JarvisHome>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText speech = stt.SpeechToText();
  final FlutterTts tts = FlutterTts();
  final TextEditingController input = TextEditingController();

  final List<String> messages = [
    'JARVIS ONLINE. در خدمتم.'
  ];

  bool listening = false;
  bool ready = false;
  bool english = false;

  late AnimationController animation;

  @override
  void initState() {
    super.initState();

    animation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..repeat(reverse: true);

    initialize();
  }

  Future<void> initialize() async {
    ready = await speech.initialize();
    await tts.setSpeechRate(0.45);
    await tts.setPitch(0.9);
    if (mounted) setState(() {});
  }

  Future<void> speak(String text) async {
    final isFa = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    await tts.setLanguage(isFa ? 'fa-IR' : 'en-US');
    await tts.speak(text);
  }

  String answer(String text) {
    final q = text.toLowerCase();

    if (q.contains('سلام') || q.contains('hello')) {
      return 'سلام! JARVIS آماده است.';
    }

    if (q.contains('ساعت') || q.contains('time')) {
      return 'ساعت الان ${DateTime.now().hour}:${DateTime.now().minute} است.';
    }

    if (q.contains('تاریخ') || q.contains('date')) {
      return 'امروز ${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day} است.';
    }

    if (q.contains('اسمت') || q.contains('name')) {
      return 'من JARVIS هستم.';
    }

    if (q.contains('help') || q.contains('کمک')) {
      return 'می‌توانی ساعت، تاریخ و نام من را بپرسی.';
    }

    return 'فرمان دریافت شد. برای پاسخ هوشمند آنلاین باید به هوش مصنوعی متصل شوم.';
  }

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;

    setState(() => messages.add('شما: $text'));

    final response = answer(text);

    setState(() => messages.add('JARVIS: $response'));

    await speak(response);
  }

  Future<void> listen() async {
    if (listening) {
      await speech.stop();
      setState(() => listening = false);
      return;
    }

    if (!ready) {
      await initialize();
    }

    if (!ready) return;

    setState(() => listening = true);

    await speech.listen(
      localeId: english ? 'en-US' : 'fa-IR',
      listenFor: const Duration(seconds: 20),
      onResult: (result) {
        if (result.finalResult) {
          send(result.recognizedWords);
          setState(() => listening = false);
        }
      },
    );
  }

  @override
  void dispose() {
    animation.dispose();
    input.dispose();
    speech.stop();
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'J.A.R.V.I.S',
          style: TextStyle(
            letterSpacing: 5,
            color: Colors.cyanAccent,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              setState(() => english = !english);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 25),
          Text(
            listening ? 'LISTENING...' : 'SYSTEM ONLINE',
            style: const TextStyle(
              color: Colors.cyanAccent,
              letterSpacing: 3,
            ),
          ),
          Expanded(
            flex: 4,
            child: Center(
              child: GestureDetector(
                onTap: listen,
                child: ScaleTransition(
                  scale: animation,
                  child: Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          Color(0xFF1686B0),
                          Color(0xFF07182D),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.cyanAccent,
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.cyan,
                          blurRadius: 35,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.memory,
                      size: 85,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1728),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.cyan.shade900),
              ),
              child: Column(
                children: [
                  const Text(
                    'COMMUNICATION LOG',
                    style: TextStyle(color: Colors.cyanAccent),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.all(7),
                        child: Text(messages[i]),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: input,
                          decoration: const InputDecoration(
                            hintText: 'Message JARVIS...',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          final text = input.text;
                          input.clear();
                          send(text);
                        },
                      ),
                    ],
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
