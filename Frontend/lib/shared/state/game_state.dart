import 'dart:async';
import 'package:flutter/foundation.dart';

// ── Enums ────────────────────────────────────────────────────────────────────

enum UserRole { host, participant }

/// States the buzzer button can be in — matches the prototype's 6 states.
enum BuzzerState { waiting, ready, enabled, winner, late, locked }

// ── GameState ────────────────────────────────────────────────────────────────

/// Central state machine for the Buzz It prototype.
/// Provides navigation, buzzer lifecycle, scores and participant simulation.
class GameState extends ChangeNotifier {
  // ── Navigation ──────────────────────────────────────────────────────────
  String route = 'home';

  // ── Role ────────────────────────────────────────────────────────────────
  UserRole role = UserRole.host;

  // ── Game session ─────────────────────────────────────────────────────────
  int round = 1;
  BuzzerState buzzerState = BuzzerState.waiting;
  int? timerSeconds;
  String? winnerName;
  String winnerTime = '1.42';
  String userName = 'Diego';

  // ── Scores (prototype simulation) ────────────────────────────────────────
  Map<String, int> scores = {
    'Lucia'  : 3,
    'Mateo'  : 2,
    'Carmen' : 1,
    'Diego'  : 2,
    'Sofia'  : 0,
  };

  // ── Participants list ─────────────────────────────────────────────────────
  List<String> participants = ['Lucia'];
  Set<String> newlyJoined = {};

  // ── Flash overlay trigger ─────────────────────────────────────────────────
  int flashTrigger = 0;

  // ── Language ──────────────────────────────────────────────────────────────
  String lang = 'es';

  // ── Room code (prototype uses fixed value) ────────────────────────────────
  final String roomCode = 'K7M9';

  // ── Internal ──────────────────────────────────────────────────────────────
  Timer? _autoWinnerTimer;
  Timer? _participantJoinTimer;
  Timer? _autoEnableTimer;

  // ── Derived ──────────────────────────────────────────────────────────────
  List<MapEntry<String, int>> get sortedScores =>
      scores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

  // ── Navigation ────────────────────────────────────────────────────────────

  void goto(String r) {
    route = r;
    notifyListeners();
  }

  void toggleLang() {
    lang = lang == 'es' ? 'en' : 'es';
    notifyListeners();
  }

  // ── Role selection ────────────────────────────────────────────────────────

  void chooseHost() {
    role = UserRole.host;
    route = 'create-room';
    _startParticipantSimulation();
    notifyListeners();
  }

  void chooseParticipant() {
    role = UserRole.participant;
    route = 'join-room';
    notifyListeners();
  }

  // ── Join room (participant) ───────────────────────────────────────────────

  void joinRoom(String name) {
    if (name.isNotEmpty) userName = name;
    route = 'waiting';
    // Auto-advance participant to buzzer after host starts (simulated)
    Timer(const Duration(milliseconds: 3500), () {
      if (route == 'waiting' && role == UserRole.participant) {
        buzzerState = BuzzerState.waiting;
        route = 'buzzer';
        notifyListeners();
        _scheduleAutoEnable();
      }
    });
    notifyListeners();
  }

  // ── Host: start contest ───────────────────────────────────────────────────

  void startContest() {
    buzzerState = BuzzerState.waiting;
    route = 'host-panel';
    notifyListeners();
  }

  // ── Host: activate now (flash) ────────────────────────────────────────────

  void activateNow() {
    _cancelAutoWinner();
    flashTrigger++;
    buzzerState = BuzzerState.enabled;
    _scheduleAutoWinner();
    notifyListeners();
  }

  // ── Host: start countdown timer ───────────────────────────────────────────

  void startTimer(int seconds) {
    _cancelAutoWinner();
    timerSeconds = seconds;
    buzzerState = BuzzerState.ready;
    notifyListeners();
  }

  /// Called by TimerDisplay when countdown reaches zero.
  void timerDone() {
    timerSeconds = null;
    flashTrigger++;
    buzzerState = BuzzerState.enabled;
    _scheduleAutoWinner();
    notifyListeners();
  }

  // ── Participant: press buzzer ──────────────────────────────────────────────

  void participantBuzz() {
    if (buzzerState != BuzzerState.enabled) return;
    _cancelAutoWinner();
    final ms = 900 + (DateTime.now().millisecondsSinceEpoch % 700);
    winnerTime = (ms / 1000).toStringAsFixed(2);
    winnerName = userName;
    scores[userName] = (scores[userName] ?? 0) + 1;
    buzzerState = BuzzerState.winner;
    _scheduleResultNavigation();
    notifyListeners();
  }

  // ── Next round ────────────────────────────────────────────────────────────

  void nextRound() {
    _cancelAutoWinner();
    round++;
    winnerName = null;
    buzzerState = BuzzerState.waiting;
    timerSeconds = null;
    route = role == UserRole.host ? 'host-panel' : 'buzzer';
    notifyListeners();
  }

  // ── End show ──────────────────────────────────────────────────────────────

  void endShow() {
    _cancelAutoWinner();
    _cancelAutoEnable();
    _cancelParticipantSimulation();
    route = 'home';
    notifyListeners();
  }

  // ── Reset ────────────────────────────────────────────────────────────────

  void resetGame() {
    _cancelAutoWinner();
    _cancelAutoEnable();
    _cancelParticipantSimulation();
    round = 1;
    winnerName = null;
    buzzerState = BuzzerState.waiting;
    timerSeconds = null;
    flashTrigger = 0;
    scores = {
      'Lucia' : 0,
      'Mateo' : 0,
      'Carmen': 0,
      'Diego' : 0,
      'Sofia' : 0,
    };
    participants = ['Lucia'];
    newlyJoined = {};
    route = 'home';
    notifyListeners();
  }

  // ── Participant simulation (host lobby) ───────────────────────────────────

  void _startParticipantSimulation() {
    _cancelParticipantSimulation();
    participants = ['Lucia'];
    newlyJoined = {};
    final queue = ['Mateo', 'Carmen', 'Diego', 'Sofia'];
    int i = 0;
    _participantJoinTimer = Timer.periodic(
      const Duration(milliseconds: 1200),
      (t) {
        if (i >= queue.length) {
          t.cancel();
          return;
        }
        final name = queue[i++];
        participants = [...participants, name];
        newlyJoined = {name};
        notifyListeners();
        // Clear "new" badge after 700ms
        Timer(const Duration(milliseconds: 700), () {
          newlyJoined = {};
          notifyListeners();
        });
      },
    );
  }

  void _cancelParticipantSimulation() {
    _participantJoinTimer?.cancel();
    _participantJoinTimer = null;
  }

  // ── Auto-winner simulation ────────────────────────────────────────────────

  void _scheduleAutoWinner() {
    _cancelAutoWinner();
    _autoWinnerTimer = Timer(const Duration(milliseconds: 1800), () {
      _autoWinnerTimer = null;
      final ms = 1300 + (DateTime.now().millisecondsSinceEpoch % 600);
      winnerTime = (ms / 1000).toStringAsFixed(2);
      winnerName = 'Lucia';
      scores['Lucia'] = (scores['Lucia'] ?? 0) + 1;
      buzzerState = BuzzerState.winner;
      _scheduleResultNavigation();
      notifyListeners();
    });
  }

  void _scheduleResultNavigation() {
    Timer(const Duration(milliseconds: 2400), () {
      if (buzzerState == BuzzerState.winner) {
        route = 'result';
        notifyListeners();
      }
    });
  }

  void _cancelAutoWinner() {
    _autoWinnerTimer?.cancel();
    _autoWinnerTimer = null;
  }

  // ── Auto-enable buzzer (participant demo flow) ─────────────────────────────

  void _scheduleAutoEnable() {
    _autoEnableTimer?.cancel();
    _autoEnableTimer = Timer(const Duration(seconds: 5), () {
      _autoEnableTimer = null;
      if (route == 'buzzer' && buzzerState == BuzzerState.waiting) {
        flashTrigger++;
        buzzerState = BuzzerState.enabled;
        _scheduleAutoWinner();
        notifyListeners();
      }
    });
  }

  void _cancelAutoEnable() {
    _autoEnableTimer?.cancel();
    _autoEnableTimer = null;
  }

  @override
  void dispose() {
    _cancelAutoWinner();
    _cancelAutoEnable();
    _cancelParticipantSimulation();
    super.dispose();
  }
}
