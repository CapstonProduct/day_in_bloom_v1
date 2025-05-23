import 'package:day_in_bloom_v1/features/authentication/service/fitbit_auth_service.dart';
import 'package:day_in_bloom_v1/widgets/app_bar.dart';
import 'package:day_in_bloom_v1/widgets/vertical_img_text_button.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HealthQnaScreen extends StatefulWidget {
  const HealthQnaScreen({super.key});

  @override
  State<HealthQnaScreen> createState() => _HealthQnaScreenState();
}

class _HealthQnaScreenState extends State<HealthQnaScreen> {
  Map<String, dynamic>? _data;
  int _currentQuestionIndex = 0;
  final Map<int, int> _selectedAnswers = {}; 
  final Map<int, String> _subjectiveAnswers = {};

  final String gptApiGatewayUrl = dotenv.env['GPT_API_GATEWAY_URL']!;
  final String saveApiGatewayUrl = dotenv.env['SAVE_QNA_API_GATEWAY_URL']!;

  late BuildContext dialogContext;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final String response = await rootBundle.loadString('assets/qna_content.json');
    final data = json.decode(response);
    setState(() {
      _data = data;
    });
  }

  Widget _buildQuestionAndAnswers() {
    if (_data == null) {
      return Center(child: CircularProgressIndicator());
    }

    var question = _data!['questions'][_currentQuestionIndex];
    List<bool> pressedAnswers = List.generate(
      question['answers'].length,
      (index) => _selectedAnswers[_currentQuestionIndex] == index,
    );

    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "18개 중 ${_currentQuestionIndex + 1}번째 질문",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.only(left: 35, right: 35),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.cyan),
                ),
                child: Text(
                  question['question'],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Positioned(
                top: -20,
                left: -10,
                child: Image.asset(
                  "assets/flower_img/pink_flower.png",
                  width: 50,
                  height: 50,
                ),
              ),
              Positioned(
                top: -20,
                right: -10,
                child: Image.asset(
                  "assets/flower_img/top_right_leaf.png",
                  width: 50,
                  height: 50,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          height: 370,
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.2,
            ),
            itemCount: question['answers'].length,
            itemBuilder: (context, index) {
              var answer = question['answers'][index];
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: verticalImageTextButton(
                      imagePath: _currentQuestionIndex <= 4
                        ? 'assets/qna_button_img/q${_currentQuestionIndex + 1}${answer['id'].toLowerCase()}.png'
                        : 'assets/qna_button_img/temporary_img.png',
                      buttonText: answer['text'],
                      onPressed: () {
                        setState(() {
                          _selectedAnswers[_currentQuestionIndex] = index;
                          debugPrint("현재 선택된 답변 리스트(질문 인덱스 : 답변 인덱스): $_selectedAnswers");
                        });
                      },
                      isSelected: pressedAnswers[index],
                    ),
                  ),
                  if (pressedAnswers[index])
                    Positioned(
                      top: -10,
                      right: 0,
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 30,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _changeQuestion(bool isNext) {
    setState(() {
      if (isNext) {
        if (_currentQuestionIndex < _data!['questions'].length - 1) {
          _currentQuestionIndex++;
        }
      } else {
        if (_currentQuestionIndex > 0) {
          _currentQuestionIndex--;
        }
      }
    });
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        dialogContext = context; 
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("AI 건강비서가\n분석을 진행중입니다.\n잠시만 기다려주세요 🤗"),
            ],
          ),
        );
      },
    );
  }

  void _hideLoadingDialog() {
    Navigator.of(dialogContext).pop();
  }

  Future<void> _sendResponseToLambda() async {
    var sortedAnswers = Map.fromEntries(
      _selectedAnswers.entries.toList()
        ..sort((e1, e2) => e1.key.compareTo(e2.key)),
    );

    final multipleChoiceResponse = [];
    final textResponse = [];

    if (_data != null) {
      for (var entry in sortedAnswers.entries) {
        var questionIndex = entry.key;
        var answerIndex = entry.value;
        var question = _data!['questions'][questionIndex];
        var answer = question['answers'][answerIndex];
        multipleChoiceResponse.add({
          'question_id': question['id'],
          'answer_id': answer['id'],
          'text': answer['text'],
        });
      }

      _subjectiveAnswers.forEach((questionIndex, subjectiveAnswer) {
        textResponse.add({
          'question_id': _data!['questions'][questionIndex]['id'],
          'text': subjectiveAnswer,
        });
      });
    }

    final encodedId = await FitbitAuthService.getUserId();
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);

    _showLoadingDialog();

    final gptResponse = await http.post(
      Uri.parse(gptApiGatewayUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'choice_result': multipleChoiceResponse + textResponse,
      }),
    );

    if (gptResponse.statusCode == 200) {
      final gptResult = json.decode(gptResponse.body)['analysis'];

      final Map<String, dynamic> saveRequestBody = {
        'encodedId': encodedId,
        'date': formattedDate,
        'question': _data!['questions'],
        'multiple_choice_response': multipleChoiceResponse,
        'text_response': textResponse,
        'gpt_qna_analysis': gptResult,
      };

      print('[DB 저장 요청 JSON]');
      print(const JsonEncoder.withIndent('  ').convert(saveRequestBody));

      final saveResponse = await http.post(
        Uri.parse(saveApiGatewayUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(saveRequestBody),
      );

      _hideLoadingDialog();
      if (mounted) _showResponseDialog(json.encode({'analysis': gptResult}));
    } else {
      _hideLoadingDialog();
      print('GPT 호출 실패: ${gptResponse.body}');
    }
  }

  void _showResponseDialog(String responseBody) async {
    Map<String, dynamic> jsonResponse = json.decode(responseBody);
    String analysisText = jsonResponse['analysis'];
    String result = analysisText.replaceAll(r'\n', '\n');

    final encodedId = await FitbitAuthService.getUserId();
    if (encodedId != null) {
      await http.post(
        Uri.parse('https://yr3c93xvrf.execute-api.ap-northeast-2.amazonaws.com/default/update-qna-mission'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'encodedId': encodedId}),
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Image.asset(
                'assets/flower_img/pink_flower.png',
                width: 50,
                height: 50,
              ),
              SizedBox(width: 10),
              Text(
                'AI 분석 결과',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                result,
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/main');
              },
              child: Text(
                '메인으로 돌아가기',
                style: TextStyle(fontSize: 18, color: Colors.orange),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSubjectiveAnswerDialog() {
    TextEditingController controller = TextEditingController();
    controller.text = _subjectiveAnswers[_currentQuestionIndex] ?? ''; 

    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(Duration(milliseconds: 100), () {
          FocusScope.of(context).requestFocus(FocusNode());
        });

        return AlertDialog(
          title: Text("기타 답변 입력"),
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: "답변을 입력해주세요."),
              maxLines: 3,
              autofocus: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _subjectiveAnswers[_currentQuestionIndex] = controller.text;
                });
                Navigator.of(context).pop();
              },
              child: Text("저장"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("취소"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '오늘의 건강 문답'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildQuestionAndAnswers(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_currentQuestionIndex > 0)
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => _changeQuestion(false),
                      ),
                      Text("이전", style: TextStyle(fontSize: 16, color: Colors.black)),
                    ],
                  )
                else
                  SizedBox(width: 70),

                const SizedBox(width: 40),
                if (_currentQuestionIndex < 17)
                  Row(
                    children: [
                      Text("다음", style: TextStyle(fontSize: 16, color: Colors.black)),
                      IconButton(
                        icon: Icon(Icons.arrow_forward),
                        onPressed: () => _changeQuestion(true),
                      ),
                    ],
                  )
                else
                  ElevatedButton(
                    onPressed: _sendResponseToLambda,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[200],
                      foregroundColor: Colors.black, 
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 16,
                      ),
                    ),
                    child: Text("응답 마치기"),
                  ),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSubjectiveAnswerDialog,
        backgroundColor: Colors.orange,
        child: Icon(Icons.edit),
      ),
    );
  }
}

