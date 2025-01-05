import 'package:flutter/material.dart';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const DiceApp());
}

class DiceApp extends StatelessWidget {
  const DiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dice Rol',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const DicePage(),
    );
  }
}

class DicePage extends StatefulWidget {
  const DicePage({super.key});

  @override
  State<DicePage> createState() => _DicePageState();
}

class _DicePageState extends State<DicePage> {
  int firstDiceNumber = 1;
  int secondDiceNumber = 1;
  int thirdDiceNumber = 1;
  int fourthDiceNumber = 1;
  double balance = 10.0;
  double currentWager = 1.0;
  String selectedWagerType = '2 Alike';
  
  final Map<String, int> wagerMultipliers = {
    '2 Alike': 2,
    '3 Alike': 3,
    '4 Alike': 4,
  };

  double getMaxWager() {
    int multiplier = wagerMultipliers[selectedWagerType] ?? 2;
    return balance / multiplier;
  }

  void rollDice() {
    if (currentWager <= 0 || currentWager > getMaxWager()) {
      return;
    }

    setState(() {
      firstDiceNumber = Random().nextInt(6) + 1;
      secondDiceNumber = Random().nextInt(6) + 1;
      thirdDiceNumber = Random().nextInt(6) + 1;
      fourthDiceNumber = Random().nextInt(6) + 1;
      
      // Count how many dice show the same number
      Map<int, int> numberCount = {};
      [firstDiceNumber, secondDiceNumber, thirdDiceNumber, fourthDiceNumber]
          .forEach((dice) {
        numberCount[dice] = (numberCount[dice] ?? 0) + 1;
      });
      
      int maxMatches = numberCount.values.reduce(max);
      bool won = false;

      switch (selectedWagerType) {
        case '2 Alike':
          won = maxMatches >= 2;
          break;
        case '3 Alike':
          won = maxMatches >= 3;
          break;
        case '4 Alike':
          won = maxMatches >= 4;
          break;
      }

      void showResult(bool won) {
        Fluttertoast.showToast(
          msg: won ? "You Won!" : "Sorry, try again!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: won ? Colors.green : Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
        );
      }

      int multiplier = wagerMultipliers[selectedWagerType] ?? 2;
      if (won) {
        balance += currentWager * multiplier;
      } else {
        balance -= currentWager * multiplier;  // Now correctly multiplies losses too
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dice Roller'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Balance: ${balance.toStringAsFixed(2)} coins',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Wager Type: '),
              DropdownButton<String>(
                value: selectedWagerType,
                items: wagerMultipliers.keys.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedWagerType = newValue!;
                    currentWager = currentWager.clamp(0, getMaxWager());
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Wager Amount: '),
              SizedBox(
                width: 100,
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Max: ${getMaxWager().toStringAsFixed(2)}',
                  ),
                  onChanged: (value) {
                    setState(() {
                      currentWager = double.tryParse(value) ?? 0;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // First row of dice
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/images/dice$firstDiceNumber.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/images/dice$secondDiceNumber.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          // Second row of dice
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/images/dice$thirdDiceNumber.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/images/dice$fourthDiceNumber.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: currentWager > 0 && currentWager <= getMaxWager()
                ? rollDice
                : null,
            child: const Text('Roll Dice'),
          ),
        ],
      ),
    );
  }
}