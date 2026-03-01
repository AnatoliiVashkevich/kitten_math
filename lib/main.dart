import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:js' as js; // Библиотека для связи с Google Analytics в index.html

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    home: MathApp(),
    theme: ThemeData(primarySwatch: Colors.orange),
    debugShowCheckedModeBanner: false,
  ));
}

class MathApp extends StatefulWidget {
  @override
  _MathAppState createState() => _MathAppState();
}

class _MathAppState extends State<MathApp> {
  String screen = 'start';
  String operation = "Сложение";
  String difficulty = "Студент";
  String currentLang = "RU";

  final List<String> kittenEmojis = ["🐱", "😺", "😽", "🐈", "🐾"];

  // Функция для отправки событий в Google Analytics
  void trackEvent(String name, Map<String, dynamic> params) {
    try {
      js.context.callMethod('gtag', ['event', name, js.JsObject.jsify(params)]);
    } catch (e) {
      debugPrint("Analytics Error: $e");
    }
  }

  final Map<String, Map<String, String>> localizedText = {
    "RU": {
      "title": "ПОМОГИ КОТЕНКУ",
      "subtitle": "Выберите тип примеров:",
      "diff": "Твой уровень мастерства:",
      "start": "НАЧАТЬ ПУТЬ",
      "steps": "Осталось шагов: ",
      "win": "СЕМЬЯ ВМЕСТЕ!",
      "again": "ИГРАТЬ СНОВА",
      "correct_is": "Правильный ответ: ",
      "next": "ДАЛЬШЕ",
      "exit_msg": "Ты отлично потрудился сегодня! Котенок желает тебе больших успехов! ✨",
      "bye": "В МЕНЮ",
      "continue": "ПРОДОЛЖИТЬ",
      "menu": "🏠 МЕНЮ",
      "exit": "ВЫХОД",
      "story_title": "ГДЕ ЖЕ МАМА? 🐱",
      "story_body": "Мама-кошка ждет котенка на другой стороне детской площадки! Путь к ней зашифрован в математических задачках. Решай их правильно, чтобы котенок бежал быстрее. Помоги малышу не заблудиться!",
      "go": "ПОЕХАЛИ!",
      "support1": "Ты молодец! Котенок видит, как ты стараешься!",
      "support2": "У тебя обязательно получится!",
      "support3": "Ошибаться — это нормально!",
      "support4": "Почти в точку! Еще один шаг!",
      "support5": "Котенок поддерживает тебя!",
      "Сложение": "Сложение", "Вычитание": "Вычитание", "Умножение": "Умножение", "Деление": "Деление",
      "Студент": "Студент", "Профессор": "Профессор", "Искусственный Интеллект": "ИИ",
    },
    "EN": {
      "title": "HELP THE KITTEN",
      "subtitle": "Choose operation:",
      "diff": "Your skill level:",
      "start": "START JOURNEY",
      "steps": "Steps left: ",
      "win": "FAMILY REUNITED!",
      "again": "PLAY AGAIN",
      "correct_is": "The right answer is: ",
      "next": "NEXT",
      "exit_msg": "You did a great job today!",
      "bye": "TO MENU",
      "continue": "CONTINUE",
      "menu": "🏠 MENU",
      "exit": "EXIT",
      "story_title": "WHERE IS MOMMY? 🐱",
      "story_body": "Mommy cat is waiting for the kitten on the other side of the playground! The path to her is hidden in math problems. Solve them correctly to make the kitten run faster. Help the little one find his way!",
      "go": "LET'S GO!",
      "support1": "Well done!",
      "support2": "You can do it!",
      "support3": "Mistakes are okay!",
      "support4": "Almost there!",
      "support5": "The kitten is cheering for you!",
      "Сложение": "Addition", "Вычитание": "Subtraction", "Умножение": "Multiplication", "Деление": "Division",
      "Студент": "Student", "Профессор": "Professor", "Искусственный Интеллект": "A.I.",
    }
  };

  int currentTasksLeft = 10;
  int solvedCount = 0;
  int num1 = 0, num2 = 0;
  List<int> options = [];

  final ButtonStyle commonButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.orange[400],
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  );

  String t(String key) => localizedText[currentLang]![key] ?? key;

  void showStartStory() {
    trackEvent('story_view', {'lang': currentLang}); // Аналитика: просмотр истории
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("🐈", style: TextStyle(fontSize: 70)),
              SizedBox(height: 15),
              Text(t("story_title"), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange[900])),
              SizedBox(height: 15),
              Text(t("story_body"), textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: commonButtonStyle.copyWith(backgroundColor: WidgetStateProperty.all(Colors.green[400])),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  startGame();
                },
                child: Text(t("go")),
              ),
            )
          ],
        );
      },
    );
  }

  void startGame() {
    // Аналитика: запуск игры с параметрами
    trackEvent('game_start', {
      'operation': operation,
      'difficulty': difficulty,
      'language': currentLang
    });
    setState(() {
      currentTasksLeft = 10;
      solvedCount = 0;
      generateExample();
      screen = 'game';
    });
  }

  void generateExample() {
    var rng = Random();
    int range1 = (difficulty == "Студент") ? 10 : (difficulty == "Профессор" ? 31 : 101);
    
    if (operation == "Умножение" || operation == "Деление") {
      num2 = rng.nextInt(9) + 1;
      if (operation == "Деление") {
        int answer = rng.nextInt(range1);
        num1 = num2 * answer;
      } else {
        num1 = rng.nextInt(range1);
      }
    } else {
      num1 = rng.nextInt(range1);
      num2 = rng.nextInt(range1);
      if (operation == "Вычитание" && num1 < num2) {
        int temp = num1; num1 = num2; num2 = temp;
      }
    }

    int correctAnswer = getCorrectAnswer();
    Set<int> variants = {correctAnswer};
    while (variants.length < 4) {
      int offset = rng.nextInt(5) + 1;
      int fake = rng.nextBool() ? correctAnswer + offset : (correctAnswer - offset).abs();
      variants.add(fake);
    }
    options = variants.toList()..shuffle();
  }

  int getCorrectAnswer() => (operation == "Сложение") ? num1 + num2 : (operation == "Вычитание") ? num1 - num2 : (operation == "Умножение") ? num1 * num2 : (num2 == 0 ? 0 : num1 ~/ num2);

  String getOpSymbol() {
    if (operation == "Сложение") return "+";
    if (operation == "Вычитание") return "-";
    if (operation == "Умножение") return "×";
    return "÷";
  }

  void showSupportDialog() {
    final random = Random();
    String randomEmoji = kittenEmojis[random.nextInt(kittenEmojis.length)];
    String randomPhrase = t("support${random.nextInt(5) + 1}");
    String fullResult = "$num1 ${getOpSymbol()} $num2 = ${getCorrectAnswer()}";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(randomEmoji, style: TextStyle(fontSize: 80)),
              SizedBox(height: 20),
              Text(t("correct_is"), style: TextStyle(fontSize: 16)),
              Text(fullResult, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green)),
              SizedBox(height: 15),
              Text(randomPhrase, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: commonButtonStyle,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  setState(() => generateExample());
                },
                child: Text(t("next")),
              ),
            )
          ],
        );
      },
    );
  }

  void showExitDialog(bool toMenu) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("🐱✨", style: TextStyle(fontSize: 80)),
              SizedBox(height: 20),
              Text(t("exit_msg"), textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            ],
          ),
          actions: [
            Column(
              children: [
                Center(
                  child: ElevatedButton(
                    style: commonButtonStyle.copyWith(backgroundColor: WidgetStateProperty.all(Colors.green[400])),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(t("continue")),
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    if (toMenu) setState(() => screen = 'start');
                  },
                  child: Text(t("bye"), style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  void checkAnswer(int selectedAnswer) {
    int correct = getCorrectAnswer();
    if (selectedAnswer == correct) {
      // Аналитика: правильный ответ
      trackEvent('answer_correct', {
        'operation': operation,
        'level': 10 - currentTasksLeft + 1
      });

      setState(() {
        currentTasksLeft -= 1;
        solvedCount += 1;
      });
      if (currentTasksLeft <= 0) {
        // Аналитика: победа
        trackEvent('game_win', {'difficulty': difficulty});
        setState(() => screen = 'success');
      } else {
        generateExample();
      }
    } else {
      // Аналитика: ошибка
      trackEvent('answer_wrong', {
        'operation': operation,
        'user_choice': selectedAnswer,
        'correct_answer': correct
      });
      showSupportDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (screen == 'start') return buildStartScreen();
    if (screen == 'success') return buildSuccessScreen();
    return buildGameScreen();
  }

  Widget buildStartScreen() {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.language, color: Colors.orange[800]),
                    SizedBox(width: 10),
                    DropdownButton<String>(
                      value: currentLang,
                      onChanged: (String? val) {
                        trackEvent('language_change', {'lang': val!}); // Аналитика: смена языка
                        setState(() => currentLang = val);
                      },
                      items: ['RU', 'EN'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                    ),
                  ],
                ),
              ),
              Text(t("title"), style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange[900])),
              SizedBox(height: 20),
              Text(t("subtitle"), style: TextStyle(fontSize: 18)),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10, runSpacing: 10,
                children: ["Сложение", "Вычитание", "Умножение", "Деление"].map((op) => choiceChip(op, isOp: true)).toList(),
              ),
              SizedBox(height: 20),
              Text(t("diff"), style: TextStyle(fontSize: 18)),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                children: ["Студент", "Профессор", "Искусственный Интеллект"].map((d) => choiceChip(d, isOp: false)).toList(),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: showStartStory,
                style: commonButtonStyle.copyWith(padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 60, vertical: 20))),
                child: Text(t("start")),
              ),
              SizedBox(height: 20),
              TextButton.icon(
                onPressed: () => showExitDialog(false),
                icon: Icon(Icons.exit_to_app, color: Colors.orange[900]),
                label: Text(t("exit"), style: TextStyle(color: Colors.orange[900], fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGameScreen() {
    double progress = (solvedCount + currentTasksLeft == 0) ? 0 : solvedCount / (solvedCount + currentTasksLeft);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange, 
        title: Text("${t("steps")}$currentTasksLeft"), 
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: LinearProgressIndicator(value: progress, minHeight: 10, backgroundColor: Colors.orange[100], color: Colors.orange, borderRadius: BorderRadius.circular(10)),
          ),
          Container(
            height: 100,
            child: Stack(
              children: [
                Align(alignment: Alignment(0.8, 0.0), child: Text("🐈‍⬛", style: TextStyle(fontSize: 50))),
                AnimatedAlign(
                  duration: Duration(milliseconds: 600),
                  alignment: Alignment(-0.8 + (progress * 1.4), 0.0),
                  child: Transform.flip(flipX: true, child: Text("🐈", style: TextStyle(fontSize: 35))),
                ),
              ],
            ),
          ),
          Text("$num1 ${getOpSymbol()} $num2 = ?", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => showExitDialog(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[100],
              foregroundColor: Colors.orange[900],
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
            ),
            child: Text(t("menu"), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
            child: Column(
              children: [
                Row(children: [answerBtn(options[0]), SizedBox(width: 15), answerBtn(options[1])]),
                SizedBox(height: 15),
                Row(children: [answerBtn(options[2]), SizedBox(width: 15), answerBtn(options[3])]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSuccessScreen() {
    return Scaffold(
      backgroundColor: Colors.orange[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.flip(flipX: true, child: Text("🐈‍⬛", style: TextStyle(fontSize: 80))),
                Text(" ❤️ ", style: TextStyle(fontSize: 40)),
                Text("🐈", style: TextStyle(fontSize: 60)),
              ],
            ),
            SizedBox(height: 20),
            Text(t("win"), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange[900])),
            SizedBox(height: 50),
            ElevatedButton(onPressed: () => setState(() => screen = 'start'), style: commonButtonStyle, child: Text(t("again")))
          ],
        ),
      ),
    );
  }

  Widget answerBtn(int val) {
    return Expanded(
      child: SizedBox(
        height: 70,
        child: ElevatedButton(
          style: commonButtonStyle.copyWith(backgroundColor: WidgetStateProperty.all(Colors.blue[400])),
          onPressed: () => checkAnswer(val),
          child: Text("$val", style: TextStyle(fontSize: 30)),
        ),
      ),
    );
  }

  Widget choiceChip(String label, {required bool isOp}) {
    bool isSelected = isOp ? (operation == label) : (difficulty == label);
    return ChoiceChip(
      label: Text(t(label)),
      selected: isSelected,
      selectedColor: Colors.orange,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
      onSelected: (bool selected) {
        setState(() {
          if (isOp) operation = label;
          else difficulty = label;
        });
      },
    );
  }
}