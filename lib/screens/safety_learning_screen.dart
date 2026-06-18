import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_background.dart';

class SafetyLearningScreen extends StatefulWidget {
  const SafetyLearningScreen({super.key});

  @override
  State<SafetyLearningScreen> createState() => _SafetyLearningScreenState();
}

class _SafetyLearningScreenState extends State<SafetyLearningScreen> {
  final List<_SafetyQuestion> _questions = const [
    _SafetyQuestion(
      question: "A stranger asks you to go with them. What should you do?",
      answers: [
        "Say no and go to a trusted adult",
        "Go with them if they smile",
        "Keep it a secret",
      ],
      correctIndex: 0,
      tip: "Never go with someone you do not know. Find a trusted adult.",
    ),
    _SafetyQuestion(
      question: "You feel unsafe and cannot talk easily. What can help?",
      answers: [
        "Hide your phone",
        "Press the SOS button",
        "Wait without doing anything",
      ],
      correctIndex: 1,
      tip: "The SOS button is made to ask for help quickly.",
    ),
    _SafetyQuestion(
      question: "Which place is safer if you feel scared outside?",
      answers: [
        "A quiet empty place",
        "A place near people or security",
        "A place far from adults",
      ],
      correctIndex: 1,
      tip: "Go near people, a teacher, security, or a trusted adult.",
    ),
    _SafetyQuestion(
      question: "Someone tells you: do not tell your parents. What is best?",
      answers: [
        "Keep the secret",
        "Tell a trusted adult",
        "Delete the message",
      ],
      correctIndex: 1,
      tip: "Unsafe secrets should be shared with a trusted adult.",
    ),
    _SafetyQuestion(
      question: "What should you say loudly if you are in danger?",
      answers: [
        "Help me!",
        "Maybe later",
        "I am fine",
      ],
      correctIndex: 0,
      tip: "Use clear words like: Help me! Stop! I need help!",
    ),
  ];

  int _questionIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _answered = false;
  bool _quizFinished = false;

  _SafetyQuestion get _currentQuestion => _questions[_questionIndex];

  double get _progress => (_questionIndex + 1) / _questions.length;

  void _selectAnswer(int index) {
    if (_answered) return;

    setState(() {
      _selectedAnswerIndex = index;
      _answered = true;

      if (index == _currentQuestion.correctIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      if (_questionIndex == _questions.length - 1) {
        _quizFinished = true;
      } else {
        _questionIndex++;
        _selectedAnswerIndex = null;
        _answered = false;
      }
    });
  }

  void _restartQuiz() {
    setState(() {
      _questionIndex = 0;
      _score = 0;
      _selectedAnswerIndex = null;
      _answered = false;
      _quizFinished = false;
    });
  }

  Future<void> _openVideo(BuildContext context, String url) async {
    final uri = Uri.parse(url);

    if (!await canLaunchUrl(uri)) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not open the video."),
        ),
      );
      return;
    }

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              children: [
                const SizedBox(height: 14),
                Row(
                  children: [
                    _BouncyIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Safety Learning",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Text(
                    "Learn simple safety steps, play a quick quiz, and become a Safety Hero.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Column(
                      children: [
                        _sectionTitle("Safety Quiz Game"),
                        _quizCard(),
                        const SizedBox(height: 16),
                        _sectionTitle("Short Safety Videos"),
                        _videoCard(
                          context: context,
                          icon: Icons.people_alt_rounded,
                          title: "Stranger Safety",
                          description:
                          "Learn what to do if a stranger talks to you or asks you to go somewhere.",
                          videoUrl:
                          "https://www.youtube.com/results?search_query=children+stranger+safety+video",
                        ),
                        _videoCard(
                          context: context,
                          icon: Icons.record_voice_over_rounded,
                          title: "How to Ask for Help",
                          description:
                          "Learn how to ask trusted adults for help when you feel scared.",
                          videoUrl:
                          "https://www.youtube.com/results?search_query=children+how+to+ask+for+help+safety",
                        ),
                        _videoCard(
                          context: context,
                          icon: Icons.warning_rounded,
                          title: "What to Do in Danger",
                          description:
                          "Simple steps to follow when you feel unsafe or in danger.",
                          videoUrl:
                          "https://www.youtube.com/results?search_query=children+safety+what+to+do+in+danger",
                        ),
                        const SizedBox(height: 16),
                        _sectionTitle("Quick Safety Tips"),
                        _tipCard(
                          icon: Icons.verified_user_rounded,
                          title: "Stay with trusted adults",
                          description:
                          "Stay close to your parent, teacher, or someone you trust.",
                        ),
                        _tipCard(
                          icon: Icons.do_not_disturb_alt_rounded,
                          title: "Do not go with strangers",
                          description:
                          "Never go with someone you do not know, even if they are nice.",
                        ),
                        _tipCard(
                          icon: Icons.campaign_rounded,
                          title: "Say help loudly",
                          description:
                          "If you feel scared, say: Help me! loudly and go to a safe place.",
                        ),
                        _tipCard(
                          icon: Icons.touch_app_rounded,
                          title: "Use the SOS button",
                          description:
                          "If talking is difficult, press the SOS button to ask for help.",
                        ),
                      ],
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

  Widget _quizCard() {
    if (_quizFinished) {
      final passed = _score >= 4;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: _whiteCardDecoration(),
        child: Column(
          children: [
            Icon(
              passed ? Icons.workspace_premium_rounded : Icons.favorite_rounded,
              color: passed ? const Color(0xffF39C12) : const Color(0xff2F6BFF),
              size: 62,
            ),
            const SizedBox(height: 10),
            Text(
              passed ? "Safety Hero!" : "Good Try!",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your score is $_score / ${_questions.length}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              passed
                  ? "Great job. You know how to ask for help and stay safe."
                  : "You learned useful safety steps. Try again to become a Safety Hero.",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black.withValues(alpha: 0.60),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _restartQuiz,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: const Text(
                  "Play Again",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2F6BFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _whiteCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xff2F6BFF).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.quiz_rounded,
                  color: Color(0xff2F6BFF),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Question ${_questionIndex + 1} of ${_questions.length}",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.black.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: _progress,
                        minHeight: 8,
                        backgroundColor:
                        const Color(0xff2F6BFF).withValues(alpha: 0.12),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xff2F6BFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _currentQuestion.question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(
            _currentQuestion.answers.length,
                (index) => _answerButton(index),
          ),
          if (_answered) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xff2ECC71).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xff2ECC71).withValues(alpha: 0.22),
                ),
              ),
              child: Text(
                _currentQuestion.tip,
                style: const TextStyle(
                  color: Color(0xff1E8449),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2F6BFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _questionIndex == _questions.length - 1
                      ? "Show Result"
                      : "Next Question",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _answerButton(int index) {
    final isSelected = _selectedAnswerIndex == index;
    final isCorrect = _currentQuestion.correctIndex == index;

    Color borderColor = Colors.black.withValues(alpha: 0.10);
    Color backgroundColor = Colors.white;
    IconData? trailingIcon;
    Color trailingColor = Colors.transparent;

    if (_answered && isCorrect) {
      borderColor = const Color(0xff2ECC71);
      backgroundColor = const Color(0xff2ECC71).withValues(alpha: 0.10);
      trailingIcon = Icons.check_circle_rounded;
      trailingColor = const Color(0xff2ECC71);
    } else if (_answered && isSelected && !isCorrect) {
      borderColor = const Color(0xffE74C3C);
      backgroundColor = const Color(0xffE74C3C).withValues(alpha: 0.10);
      trailingIcon = Icons.cancel_rounded;
      trailingColor = const Color(0xffE74C3C);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _selectAnswer(index),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.4),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _currentQuestion.answers[index],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon, color: trailingColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 4),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _videoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required String videoUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: _whiteCardDecoration(),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xff2F6BFF).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xff2F6BFF),
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withValues(alpha: 0.62),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _openVideo(context, videoUrl),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff2F6BFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Watch",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _tipCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: _whiteCardDecoration(),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xff2ECC71).withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xff2ECC71),
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withValues(alpha: 0.62),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static BoxDecoration _whiteCardDecoration() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 14,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}

class _SafetyQuestion {
  final String question;
  final List<String> answers;
  final int correctIndex;
  final String tip;

  const _SafetyQuestion({
    required this.question,
    required this.answers,
    required this.correctIndex,
    required this.tip,
  });
}

class _BouncyIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _BouncyIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  State<_BouncyIconButton> createState() => _BouncyIconButtonState();
}

class _BouncyIconButtonState extends State<_BouncyIconButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.92),
      onTapCancel: () => setState(() => _scale = 1),
      onTapUp: (_) {
        setState(() => _scale = 1);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 110),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.18),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}
