import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MaterialApp(
      home: MathApp(),
      theme: ThemeData(primarySwatch: Colors.orange),
      debugShowCheckedModeBanner: false,
    ));

class MathApp extends StatefulWidget {
  @override
  _MathAppState createState() => _MathAppState();
}

class _MathAppState extends State<MathApp> {
  String screen = 'start';
  String operation = "Сложение";
  String difficulty = "Легко";
  String currentLang = "RU"; 

  // Словарь переводов
  final Map<String, Map<String, String>> localizedText = {
    "RU": {
      "title": "ПОМОГИ КОТЕНКУ",
      "subtitle": "Выберите тип примеров:",
      "diff": "Сложность:",
      "start": "НАЧАТЬ ПУТЬ",
      "steps": "Осталось шагов: ",
      "win": "СЕМЬЯ ВМЕСТЕ!",
      "again": "ИГРАТЬ СНОВА",
      "lang": "Язык",
      "Сложение": "Сложение",
      "Вычитание": "Вычитание",
      "Умножение": "Умножение",
      "Деление": "Деление",
      "Легко": "Легко",
      "Средне": "Средне",
      "Сложно": "Сложно",
    },
    "EN": {
      "title": "HELP THE KITTEN",
      "subtitle": "Choose operation:",
      "diff": "Difficulty:",
      "start": "START JOURNEY",
      "steps": "Steps left: ",
      "win": "FAMILY REUNITED!",
      "again": "PLAY AGAIN",
      "lang": "Language",
      "Сложение": "Addition",
      "Вычитание": "Subtraction",
      "Умножение": "Multiplication",
      "Деление": "Division",
      "Легко": "Easy",
      "Средне": "Medium",
      "Сложно": "Hard",
    },
    "ZH": {
      "title": "帮助小猫",
      "subtitle": "选择运算:",
      "diff": "难度:",
      "start": "开始游戏",
      "steps": "剩余步数: ",
      "win": "团圆了!",
      "again": "再玩一次",
      "lang": "语言",
      "Сложение": "加法",
      "Вычитание": "减法",
      "Умножение": "乘法",
      "Деление": "除法",
      "Легко": "简单",
      "Средне": "普通",
      "Сложно": "困难",
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

  void startGame() {
    setState(() {
      currentTasksLeft = 10;
      solvedCount = 0;
      generateExample();
      screen = 'game';
    });
  }

  void generateExample() {
    var rng = Random();
    int maxRange = (difficulty == "Легко") ? 10 : (difficulty == "Средне" ? 31 : 101);
    
    if (operation == "Деление") {
      num2 = rng.nextInt(maxRange - 1) + 1; 
      int answer = rng.nextInt(maxRange);
      num1 = num2 * answer; 
    } else if (operation == "Умножение") {
      num1 = rng.nextInt(maxRange);
      num2 = rng.nextInt(maxRange);
    } else {
      num1 = rng.nextInt(maxRange);
      num2 = rng.nextInt(maxRange);
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
    options = variants.toList();
    options.shuffle();
  }

  int getCorrectAnswer() {
    if (operation == "Сложение") return num1 + num2;
    if (operation == "Вычитание") return num1 - num2;
    if (operation == "Умножение") return num1 * num2;
    if (operation == "Деление") return num1 ~/ num2;
    return 0;
  }

  String getOpSymbol() {
    if (operation == "Сложение") return "+";
    if (operation == "Вычитание") return "-";
    if (operation == "Умножение") return "×";
    if (operation == "Деление") return "÷";
    return "?";
  }

  void checkAnswer(int selectedAnswer) {
    if (selectedAnswer == getCorrectAnswer()) {
      setState(() {
        currentTasksLeft -= 1;
        solvedCount += 1;
      });
    } else {
      setState(() {
        currentTasksLeft = min(currentTasksLeft + 2, 30);
      });
    }
    if (currentTasksLeft <= 0) setState(() => screen = 'success');
    else generateExample();
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.language, color: Colors.orange[800]),
                    SizedBox(width: 10),
                    DropdownButton<String>(
                      value: currentLang,
                      underline: Container(height: 2, color: Colors.orange),
                      onChanged: (String? newValue) {
                        setState(() { currentLang = newValue!; });
                      },
                      items: <String>['RU', 'EN', 'ZH']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(t("title"), style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange[900])),
              SizedBox(height: 30),
              Text(t("subtitle"), style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10, runSpacing: 10,
                children: ["Сложение", "Вычитание", "Умножение", "Деление"].map((op) => choiceChip(op, isOp: true)).toList(),
              ),
              SizedBox(height: 30),
              Text(t("diff"), style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                children: ["Легко", "Средне", "Сложно"].map((d) => choiceChip(d, isOp: false)).toList(),
              ),
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: startGame,
                style: commonButtonStyle.copyWith(padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 60, vertical: 20))),
                child: Text(t("start")),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGameScreen() {
    double progress = solvedCount / (solvedCount + currentTasksLeft);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("${t("steps")}$currentTasksLeft"), centerTitle: true),
      body: Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: LinearProgressIndicator(value: progress, minHeight: 10, borderRadius: BorderRadius.circular(10)),
          ),
          Container(
            height: 140,
            child: Stack(
              children: [
                Align(alignment: Alignment(0.8, 0.0), child: Text("🐈‍⬛", style: TextStyle(fontSize: 65))),
                AnimatedAlign(
                  duration: Duration(milliseconds: 600),
                  alignment: Alignment(-0.8 + (progress * 1.55), 0.0),
                  child: Transform.flip(flipX: true, child: Text("🐈", style: TextStyle(fontSize: 45))),
                ),
              ],
            ),
          ),
          Text("$num1 ${getOpSymbol()} $num2 = ?", style: TextStyle(fontSize: 55, fontWeight: FontWeight.bold)),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
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
            ElevatedButton(
              onPressed: () => setState(() => screen = 'start'),
              style: commonButtonStyle,
              child: Text(t("again")),
            )
          ],
        ),
      ),
    );
  }

  Widget answerBtn(int val) {
    return Expanded(
      child: SizedBox(
        height: 65,
        child: ElevatedButton(
          style: commonButtonStyle.copyWith(
            backgroundColor: WidgetStateProperty.all(Colors.blue[400]),
            foregroundColor: WidgetStateProperty.all(Colors.white),
          ),
          onPressed: () => checkAnswer(val),
          child: Text("$val", style: TextStyle(fontSize: 28)),
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