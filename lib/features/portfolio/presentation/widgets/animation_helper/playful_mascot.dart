// A small shape-shifting creature (Morph-inspired) that reacts to whichever
// portfolio section is currently on screen with a scripted moment — instead
// of wandering randomly. Outside those sections it plays mischievously in
// place: glancing around, wiggling, sleeping, stretching, pouncing, flipping.
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

enum MascotSection { none, hero, about, skills, projects }

class PlayfulMascot extends StatefulWidget {
  const PlayfulMascot({
    required this.section,
    this.color = const Color(0xFF164E1D),
    this.topSafeArea = 96,
    this.size = 60,
    super.key,
  });

  final MascotSection section;
  final Color color;
  final double topSafeArea;
  final double size;

  @override
  State<PlayfulMascot> createState() => _PlayfulMascotState();
}

class _SectionScript {
  const _SectionScript({
    required this.target,
    this.message,
    this.wink = false,
    this.facingAway = false,
    this.typewriter = false,
    this.nuzzle = false,
  });

  final Offset target;
  final String? message;
  final bool wink;
  final bool facingAway;
  final bool typewriter;
  final bool nuzzle;
}

class _PlayfulMascotState extends State<PlayfulMascot>
    with TickerProviderStateMixin {
  final _random = Random();

  late final AnimationController _breathController;
  late final AnimationController _flightController;
  late final AnimationController _reactController;
  late final AnimationController _moveController;
  late final AnimationController _eyeController;
  late final AnimationController _mouthController;
  late final AnimationController _tiltController;
  late final AnimationController _stretchController; // cat-like stretch
  late final AnimationController _hopController; // playful pounce hop

  bool _mounted = true;
  bool _idleActive = false;
  bool _facingAway = false;
  bool _winkingRight = false;
  bool _sleeping = false;

  String? _speech;
  bool _bubbleVisible = false;
  Timer? _typeTimer;
  Timer? _talkFlapTimer;
  Timer? _holdTimer;
  int _speakToken = 0;

  Offset _position = Offset.zero;
  Offset _origin = Offset.zero;
  Offset _target = Offset.zero;
  Size _bounds = Size.zero;
  bool _ready = false;
  bool _blinking = false;

  Offset _eyeFrom = Offset.zero;
  Offset _eyeTo = Offset.zero;
  double _mouthFrom = 0;
  double _mouthTo = 0;
  double _tiltFrom = 0;
  double _tiltTo = 0;
  double _stretchFrom = 0;
  double _stretchTo = 0;
  double _hopFrom = 0;
  double _hopTo = 0;

  Timer? _blinkTimer;

  static const _scripts = <MascotSection, _SectionScript>{
    MascotSection.hero: _SectionScript(
      target: Offset(0.78, 0.30),
      message: "Look at my friend, he's handsome!",
      nuzzle: true,
    ),
    MascotSection.about: _SectionScript(
      target: Offset(0.18, 0.46),
      message: '...and I love my friend Morph!',
      typewriter: true,
    ),
    MascotSection.skills: _SectionScript(
      target: Offset(0.62, 0.42),
      message: "I told you he's a genius.",
      wink: true,
    ),
    MascotSection.projects: _SectionScript(
      target: Offset(0.80, 0.60),
      message: 'My friend did amazing work here!',
      facingAway: true,
    ),
  };
  static const _idleTarget = Offset(0.88, 0.80);

  @override
  void initState() {
    super.initState();
    _breathController =
    AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _flightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _reactController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      lowerBound: -1,
      upperBound: 1,
    );
    _moveController = AnimationController(vsync: this)
      ..addListener(() {
        setState(() {
          _position = Offset.lerp(
            _origin,
            _target,
            Curves.easeInOutSine.transform(_moveController.value),
          )!;
        });
      });
    _eyeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() => setState(() {}));
    _mouthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    )..addListener(() => setState(() {}));
    _tiltController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addListener(() => setState(() {}));
    _stretchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() => setState(() {}));
    _hopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..addListener(() => setState(() {}));

    _scheduleBlink();
  }

  @override
  void didUpdateWidget(covariant PlayfulMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.section != widget.section && _ready) {
      _playSection(widget.section);
    }
  }

  @override
  void dispose() {
    _mounted = false;
    _breathController.dispose();
    _flightController.dispose();
    _reactController.dispose();
    _moveController.dispose();
    _eyeController.dispose();
    _mouthController.dispose();
    _tiltController.dispose();
    _stretchController.dispose();
    _hopController.dispose();
    _blinkTimer?.cancel();
    _typeTimer?.cancel();
    _talkFlapTimer?.cancel();
    _holdTimer?.cancel();
    super.dispose();
  }

  void _scheduleBlink() {
    _blinkTimer = Timer(
      Duration(milliseconds: 2600 + _random.nextInt(2800)),
          () async {
        if (!_mounted || _sleeping) return; // don't fight the sleep animation
        setState(() => _blinking = true);
        await Future.delayed(const Duration(milliseconds: 130));
        if (!_mounted) return;
        setState(() => _blinking = false);
        _scheduleBlink();
      },
    );
  }

  Offset get _eyeOffset => Offset.lerp(
    _eyeFrom,
    _eyeTo,
    Curves.easeInOutCubic.transform(_eyeController.value),
  )!;

  double get _mouthOpenness => _lerp(
    _mouthFrom,
    _mouthTo,
    Curves.easeOut.transform(_mouthController.value),
  );

  double get _tilt =>
      _lerp(_tiltFrom, _tiltTo, Curves.easeInOutSine.transform(_tiltController.value));

  double get _stretch => _lerp(
    _stretchFrom,
    _stretchTo,
    Curves.easeInOutSine.transform(_stretchController.value),
  );

  double get _hop =>
      _lerp(_hopFrom, _hopTo, Curves.easeOutCubic.transform(_hopController.value));

  void _lookTo(Offset target, {Duration? duration}) {
    _eyeFrom = _eyeOffset;
    _eyeTo = target;
    if (duration != null) _eyeController.duration = duration;
    _eyeController.forward(from: 0);
  }

  void _mouthTarget(double value, {Duration? duration}) {
    _mouthFrom = _mouthOpenness;
    _mouthTo = value;
    if (duration != null) _mouthController.duration = duration;
    _mouthController.forward(from: 0);
  }

  void _tiltTarget(double value, {Duration? duration}) {
    _tiltFrom = _tilt;
    _tiltTo = value;
    if (duration != null) _tiltController.duration = duration;
    _tiltController.forward(from: 0);
  }

  void _stretchTarget(double value, {Duration? duration}) {
    _stretchFrom = _stretch;
    _stretchTo = value;
    if (duration != null) _stretchController.duration = duration;
    _stretchController.forward(from: 0);
  }

  void _hopTarget(double value, {Duration? duration}) {
    _hopFrom = _hop;
    _hopTo = value;
    if (duration != null) _hopController.duration = duration;
    _hopController.forward(from: 0);
  }

  void _moveToFraction(Offset fraction, {double speedFactor = 1}) {
    if (_bounds.isEmpty) return;
    final maxX = max(_bounds.width - widget.size, 0.0);
    final maxY = max(_bounds.height - widget.size, widget.topSafeArea);
    final next = Offset(
      (fraction.dx * _bounds.width).clamp(0.0, maxX),
      (widget.topSafeArea + fraction.dy * max(maxY - widget.topSafeArea, 1.0))
          .clamp(widget.topSafeArea, maxY),
    );
    _origin = _position;
    _target = next;
    final distance = (_target - _origin).distance;
    _moveController
      ..duration = Duration(
        milliseconds:
        ((700 + distance * 3.2) / speedFactor).clamp(500, 2600).toInt(),
      )
      ..forward(from: 0);
    final dir = _target - _origin;
    if (dir.distance > 4) {
      _lookTo((dir / dir.distance) * 2.0,
          duration: const Duration(milliseconds: 350));
      _tiltTarget((dir.dx / dir.distance).clamp(-1, 1) * 0.14);
    }
  }

  // ---- Section-triggered scripted behavior ----
  Future<void> _playSection(MascotSection section) async {
    _idleActive = false;
    _sleeping = false;
    _cancelSpeech();

    final script = _scripts[section];
    _moveToFraction(script?.target ?? _idleTarget, speedFactor: 1.1);
    await Future.delayed(_moveController.duration!);
    if (!_mounted || widget.section != section) return;

    if (script == null) {
      _tiltTarget(0);
      _lookTo(Offset.zero, duration: const Duration(milliseconds: 500));
      _startIdleLoop();
      return;
    }

    if (script.nuzzle) await _nuzzleAnimation();
    if (!_mounted || widget.section != section) return;

    if (script.facingAway) setState(() => _facingAway = true);
    if (script.wink) await _winkAnimation();
    if (!_mounted || widget.section != section) return;

    _tiltTarget(0);
    _lookTo(Offset.zero, duration: const Duration(milliseconds: 400));

    if (script.message != null) {
      _speak(script.message!, typewriter: script.typewriter);
    }
  }

  Future<void> _nuzzleAnimation() async {
    for (var i = 0; i < 3 && _mounted; i++) {
      _tiltTarget(0.14);
      await Future.delayed(const Duration(milliseconds: 160));
      _tiltTarget(-0.14);
      await Future.delayed(const Duration(milliseconds: 160));
    }
    _tiltTarget(0);
  }

  Future<void> _winkAnimation() async {
    setState(() => _winkingRight = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (_mounted) setState(() => _winkingRight = false);
  }

  // ---- Speech: appear, flap mouth while "talking", hold, fade away ----
  void _cancelSpeech() {
    _speakToken++;
    _typeTimer?.cancel();
    _talkFlapTimer?.cancel();
    _holdTimer?.cancel();
    if (_mounted) {
      setState(() {
        _bubbleVisible = false;
        _speech = null;
        _facingAway = false;
        _winkingRight = false;
      });
    }
    _mouthTarget(0, duration: const Duration(milliseconds: 150));
  }

  void _speak(String text, {bool typewriter = false}) {
    final token = ++_speakToken;
    setState(() {
      _speech = typewriter ? '' : text;
      _bubbleVisible = true;
    });

    final talkDuration = Duration(
      milliseconds: (text.length * 42).clamp(600, 2600),
    );

    _talkFlapTimer = Timer.periodic(const Duration(milliseconds: 95), (t) {
      if (!_mounted || token != _speakToken) {
        t.cancel();
        return;
      }
      final open = _random.nextDouble() > 0.35;
      _mouthTarget(
        open ? 0.35 + _random.nextDouble() * 0.3 : 0.02,
        duration: const Duration(milliseconds: 90),
      );
    });

    if (typewriter) {
      final charInterval =
      (talkDuration.inMilliseconds / text.length).clamp(16, 70).toInt();
      var i = 0;
      _typeTimer = Timer.periodic(Duration(milliseconds: charInterval), (t) {
        if (!_mounted || token != _speakToken) {
          t.cancel();
          return;
        }
        i++;
        setState(() => _speech = text.substring(0, i.clamp(0, text.length)));
        if (i >= text.length) t.cancel();
      });
    }

    Future.delayed(talkDuration, () {
      if (!_mounted || token != _speakToken) return;
      _talkFlapTimer?.cancel();
      _mouthTarget(0, duration: const Duration(milliseconds: 180));

      _holdTimer = Timer(const Duration(seconds: 2), () {
        if (!_mounted || token != _speakToken) return;
        setState(() => _bubbleVisible = false);
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!_mounted || token != _speakToken) return;
          setState(() => _speech = null);
        });
      });
    });
  }

  // ---- Default: stays put, plays mischievously like a cat/dog ----
  void _startIdleLoop() {
    _idleActive = true;
    _idleCycle();
  }

  Future<void> _idleCycle() async {
    while (_mounted && _idleActive) {
      final roll = _random.nextDouble();
      if (roll < 0.20) {
        await _idleLookAround();
      } else if (roll < 0.34) {
        await _idleWiggle();
      } else if (roll < 0.46) {
        await _idleDoubleBlink();
      } else if (roll < 0.58) {
        await _idlePeekDown();
      } else if (roll < 0.68) {
        await _idleQuickSquish();
      } else if (roll < 0.78) {
        await _idleSomersault();
      } else if (roll < 0.88) {
        await _idleStretch();
      } else if (roll < 0.96) {
        await _idlePounce();
      } else {
        await _idleSleep();
      }
      if (!_mounted || !_idleActive) return;
      await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(900)));
    }
  }

  Future<void> _idleLookAround() async {
    _lookTo(Offset.zero, duration: const Duration(milliseconds: 400));
    await Future.delayed(Duration(milliseconds: 900 + _random.nextInt(900)));
    if (!_mounted) return;
    final angle = _random.nextDouble() * 2 * pi;
    _lookTo(Offset(cos(angle), sin(angle)) * 1.7,
        duration: const Duration(milliseconds: 400));
    await Future.delayed(Duration(milliseconds: 700 + _random.nextInt(500)));
  }

  Future<void> _idleWiggle() async {
    _tiltTarget(0.12, duration: const Duration(milliseconds: 200));
    await Future.delayed(const Duration(milliseconds: 220));
    if (!_mounted) return;
    _tiltTarget(-0.12, duration: const Duration(milliseconds: 220));
    await Future.delayed(const Duration(milliseconds: 220));
    if (!_mounted) return;
    _tiltTarget(0, duration: const Duration(milliseconds: 250));
    await Future.delayed(const Duration(milliseconds: 250));
  }

  Future<void> _idleDoubleBlink() async {
    for (var i = 0; i < 2 && _mounted; i++) {
      setState(() => _blinking = true);
      await Future.delayed(const Duration(milliseconds: 110));
      if (!_mounted) return;
      setState(() => _blinking = false);
      await Future.delayed(const Duration(milliseconds: 140));
    }
  }

  Future<void> _idlePeekDown() async {
    _lookTo(const Offset(0, 2.2), duration: const Duration(milliseconds: 350));
    _mouthTarget(0.2, duration: const Duration(milliseconds: 200));
    await Future.delayed(Duration(milliseconds: 600 + _random.nextInt(500)));
    if (!_mounted) return;
    _mouthTarget(0, duration: const Duration(milliseconds: 200));
    _lookTo(Offset.zero, duration: const Duration(milliseconds: 350));
    await Future.delayed(const Duration(milliseconds: 350));
  }

  Future<void> _idleQuickSquish() async {
    await _reactController.forward(from: 0);
    await _reactController.reverse();
  }

  /// A full playful somersault in place — tilt spins a full 2π and back.
  Future<void> _idleSomersault() async {
    _tiltTarget(2 * pi, duration: const Duration(milliseconds: 520));
    _mouthTarget(0.3, duration: const Duration(milliseconds: 150));
    await Future.delayed(const Duration(milliseconds: 520));
    if (!_mounted) return;
    _tiltController.value = 0; // snap back to 0 without an unwind animation
    _tiltFrom = 0;
    _tiltTo = 0;
    _mouthTarget(0, duration: const Duration(milliseconds: 200));
    await Future.delayed(const Duration(milliseconds: 150));
  }

  /// Cat-style stretch: elongates low and long, then snaps back up.
  Future<void> _idleStretch() async {
    _lookTo(const Offset(0, 1.4), duration: const Duration(milliseconds: 300));
    _stretchTarget(1, duration: const Duration(milliseconds: 420));
    _mouthTarget(0.15, duration: const Duration(milliseconds: 300));
    await Future.delayed(const Duration(milliseconds: 650));
    if (!_mounted) return;
    _stretchTarget(0, duration: const Duration(milliseconds: 320));
    _mouthTarget(0, duration: const Duration(milliseconds: 200));
    _lookTo(Offset.zero, duration: const Duration(milliseconds: 300));
    await Future.delayed(const Duration(milliseconds: 320));
  }

  /// Crouches like a cat about to pounce, then hops — playful, not travel.
  Future<void> _idlePounce() async {
    _stretchTarget(-0.6, duration: const Duration(milliseconds: 200)); // crouch
    _lookTo(const Offset(0, -1.2), duration: const Duration(milliseconds: 200));
    await Future.delayed(const Duration(milliseconds: 220));
    if (!_mounted) return;
    _stretchTarget(0, duration: const Duration(milliseconds: 120));
    _hopTarget(1, duration: const Duration(milliseconds: 180));
    _mouthTarget(0.4, duration: const Duration(milliseconds: 120));
    await Future.delayed(const Duration(milliseconds: 180));
    if (!_mounted) return;
    _hopTarget(0, duration: const Duration(milliseconds: 220));
    _mouthTarget(0, duration: const Duration(milliseconds: 200));
    _lookTo(Offset.zero, duration: const Duration(milliseconds: 250));
    await Future.delayed(const Duration(milliseconds: 220));
  }

  /// A short nap: eyes shut, gentle "Zzz" drifting up, then wakes with a blink.
  Future<void> _idleSleep() async {
    setState(() => _sleeping = true);
    _mouthTarget(0.05, duration: const Duration(milliseconds: 300));
    await Future.delayed(Duration(milliseconds: 1800 + _random.nextInt(1400)));
    if (!_mounted) return;
    setState(() => _sleeping = false);
    setState(() => _blinking = true);
    await Future.delayed(const Duration(milliseconds: 150));
    if (!_mounted) return;
    setState(() => _blinking = false);
    _mouthTarget(0.2, duration: const Duration(milliseconds: 150)); // little yawn
    await Future.delayed(const Duration(milliseconds: 250));
    if (!_mounted) return;
    _mouthTarget(0, duration: const Duration(milliseconds: 200));
  }

  void _onTap() {
    if (_speech != null) return;
    if (_sleeping) {
      setState(() => _sleeping = false); // waking him up is part of the fun
      return;
    }
    _reactController.forward(from: 0).then((_) => _reactController.reverse());
    _mouthTarget(0.5, duration: const Duration(milliseconds: 120));
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_mounted) _mouthTarget(0, duration: const Duration(milliseconds: 200));
    });
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      _bounds = Size(constraints.maxWidth, constraints.maxHeight);
      if (!_ready && _bounds.width > 0 && _bounds.height > 0) {
        _ready = true;
        _position = Offset(_bounds.width * _idleTarget.dx,
            widget.topSafeArea + _idleTarget.dy * 40);
        _origin = _position;
        _target = _position;
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _playSection(widget.section));
      }

      const bubbleWidth = 190.0;
      final bubbleLeft = (_position.dx - bubbleWidth / 2 + widget.size / 2)
          .clamp(8.0, max(_bounds.width - bubbleWidth - 8, 8.0));
      final bubbleTop = max(_position.dy - 78, widget.topSafeArea - 60);
      final hopOffsetY = -_hop * widget.size * 0.5;

      return Stack(
        children: [
          Positioned(
            left: _position.dx,
            top: _position.dy + hopOffsetY,
            child: GestureDetector(
              onTap: _onTap,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _breathController,
                  _flightController,
                  _reactController,
                ]),
                builder: (context, _) => CustomPaint(
                  size: Size(widget.size * 1.5, widget.size * 1.5),
                  painter: _MorphPainter(
                    wobble: _breathController.value,
                    hoverPhase: _flightController.value * 2 * pi,
                    squish: _reactController.value,
                    color: widget.color,
                    eyeOffset: _eyeOffset,
                    mouthOpenness: _mouthOpenness,
                    blink: _blinking || _sleeping,
                    winkRight: _winkingRight,
                    tilt: _tilt,
                    stretch: _stretch,
                    bodySize: widget.size,
                    facingAway: _facingAway,
                  ),
                ),
              ),
            ),
          ),
          if (_sleeping)
            Positioned(
              left: _position.dx + widget.size * 0.7,
              top: _position.dy - 22,
              child: _ZzzOverlay(phase: _flightController),
            ),
          if (_speech != null)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              left: bubbleLeft.toDouble(),
              top: bubbleTop,
              child: AnimatedOpacity(
                opacity: _bubbleVisible ? 1 : 0,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
                child: _SpeechBubble(text: _speech!, width: bubbleWidth),
              ),
            ),
        ],
      );
    },
  );
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

class _ZzzOverlay extends StatelessWidget {
  const _ZzzOverlay({required this.phase});
  final Animation<double> phase;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: phase,
    builder: (context, _) {
      final t = phase.value; // 0..1 looping
      return SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _z('Z', 14, t, 0),
            _z('z', 10, t, 0.33),
            _z('z', 8, t, 0.66),
          ],
        ),
      );
    },
  );

  Widget _z(String char, double fontSize, double t, double phaseOffset) {
    final local = ((t + phaseOffset) % 1.0);
    final opacity = (sin(local * pi)).clamp(0.0, 1.0);
    return Positioned(
      left: local * 18,
      top: -local * 26,
      child: Opacity(
        opacity: opacity,
        child: Text(
          char,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey.shade400,
          ),
        ),
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.text, required this.width});
  final String text;
  final double width;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
      ],
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ),
    ),
  );
}

class _MorphPainter extends CustomPainter {
  _MorphPainter({
    required this.wobble,
    required this.hoverPhase,
    required this.squish,
    required this.color,
    required this.eyeOffset,
    required this.mouthOpenness,
    required this.blink,
    required this.winkRight,
    required this.tilt,
    required this.stretch,
    required this.bodySize,
    required this.facingAway,
  });

  final double wobble;
  final double hoverPhase;
  final double squish;
  final Color color;
  final Offset eyeOffset;
  final double mouthOpenness;
  final bool blink;
  final bool winkRight;
  final double tilt;
  final double stretch; // -1 (crouch) .. 0 (normal) .. 1 (stretched long)
  final double bodySize;
  final bool facingAway;

  static const _lumps = [
    Offset(-0.02, -0.05),
    Offset(-0.42, -0.36),
    Offset(0.28, -0.4),
    Offset(0.58, -0.02),
    Offset(0.5, 0.32),
    Offset(0.02, 0.5),
    Offset(-0.4, 0.34),
    Offset(-0.6, -0.02),
  ];
  static const _lumpRadii = [0.62, 0.34, 0.36, 0.32, 0.26, 0.28, 0.26, 0.3];

  static const _loose = [
    _Bubble(Offset(-1.15, 0.55), 0.12, 0.4, 3.2),
    _Bubble(Offset(1.25, 0.35), 0.1, 2.1, 2.6),
    _Bubble(Offset(0.55, 1.05), 0.09, 4.0, 3.6),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final hoverAmplitude = facingAway ? 0.8 : 3.5;
    final hover = sin(hoverPhase) * hoverAmplitude;
    final bodyCenter = center + Offset(0, hover);
    final baseRadius = bodySize / 2 - 4;

    if (facingAway) _drawChair(canvas, bodyCenter, baseRadius);

    // stretch > 0: elongate horizontally & flatten (cat stretch)
    // stretch < 0: compress into a crouch (wider & shorter, pounce prep)
    final stretchX = 1 + (stretch > 0 ? stretch * 0.55 : -stretch * 0.18);
    final stretchY = 1 - (stretch > 0 ? stretch * 0.28 : -stretch * 0.3);

    canvas.save();
    canvas.translate(bodyCenter.dx, bodyCenter.dy);
    canvas.rotate(tilt);
    canvas.scale(stretchX, stretchY);
    canvas.translate(-bodyCenter.dx, -bodyCenter.dy);

    Path? bodyPath;
    for (var i = 0; i < _lumps.length; i++) {
      final breathe = sin(wobble * 2 * pi + i * 0.9) * 1.4;
      final squishScale = 1 + squish.abs() * 0.18;
      final r = (baseRadius * _lumpRadii[i] + breathe) * squishScale;
      final lumpCenter = bodyCenter + _lumps[i] * baseRadius;
      final lumpPath = Path()..addOval(Rect.fromCircle(center: lumpCenter, radius: r));
      bodyPath = bodyPath == null
          ? lumpPath
          : Path.combine(PathOperation.union, bodyPath, lumpPath);
    }
    if (bodyPath == null) {
      canvas.restore();
      return;
    }

    canvas.drawShadow(bodyPath, Colors.black.withOpacity(0.28), 6, true);
    canvas.drawPath(
      bodyPath,
      Paint()
        ..shader = RadialGradient(
          colors: [color.withOpacity(0.98), _darken(color, 0.18)],
          center: const Alignment(-0.3, -0.5),
        ).createShader(Rect.fromCircle(center: bodyCenter, radius: baseRadius + 12)),
    );

    canvas.save();
    canvas.clipPath(bodyPath);
    for (final blotch in [
      bodyCenter + Offset(baseRadius * 0.55, baseRadius * 0.5),
      bodyCenter + Offset(-baseRadius * 0.1, baseRadius * 0.7),
      bodyCenter + Offset(baseRadius * 0.4, -baseRadius * 0.35),
    ]) {
      canvas.drawCircle(
        blotch,
        baseRadius * 0.32,
        Paint()
          ..color = Colors.black.withOpacity(0.16)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
    if (facingAway) {
      canvas.drawLine(
        bodyCenter + Offset(0, -baseRadius * 0.5),
        bodyCenter + Offset(0, baseRadius * 0.5),
        Paint()
          ..color = Colors.black.withOpacity(0.12)
          ..strokeWidth = 3,
      );
    }
    canvas.restore();

    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = _darken(color, 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    if (!facingAway) _drawFace(canvas, bodyCenter, baseRadius);

    canvas.restore();

    for (final bubble in _loose) {
      final bobY = sin(hoverPhase + bubble.phase) * bubble.amplitude;
      final bubbleCenter = bodyCenter + bubble.offset * baseRadius + Offset(0, bobY);
      final r = baseRadius * bubble.radius;
      canvas.drawShadow(
        Path()..addOval(Rect.fromCircle(center: bubbleCenter, radius: r)),
        Colors.black.withOpacity(0.2),
        3,
        true,
      );
      canvas.drawCircle(
        bubbleCenter,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [color.withOpacity(0.95), _darken(color, 0.15)],
            center: const Alignment(-0.3, -0.4),
          ).createShader(Rect.fromCircle(center: bubbleCenter, radius: r)),
      );
    }
  }

  void _drawFace(Canvas canvas, Offset bodyCenter, double baseRadius) {
    final eyeY = bodyCenter.dy - baseRadius * 0.30 + eyeOffset.dy * 0.3;
    final leftEyeCenter = Offset(bodyCenter.dx - baseRadius * 0.38, eyeY);
    final rightEyeCenter = Offset(bodyCenter.dx + baseRadius * 0.16, eyeY);
    final eyeW = baseRadius * 0.42;
    final clampedOffset = Offset(
      eyeOffset.dx.clamp(-1.4, 1.4),
      eyeOffset.dy.clamp(-1.4, 1.4),
    );

    void drawEye(Offset eyeCenter, bool closed) {
      final eyeH = closed ? 1.6 : baseRadius * 0.58;
      canvas.drawOval(
        Rect.fromCenter(center: eyeCenter, width: eyeW, height: eyeH),
        Paint()..color = const Color(0xFFE8CFC2),
      );
      if (!closed) {
        final pupilCenter = eyeCenter + clampedOffset;
        canvas.drawCircle(pupilCenter, eyeW * 0.28, Paint()..color = Colors.black87);
        canvas.drawCircle(
          pupilCenter + Offset(-eyeW * 0.08, -eyeW * 0.1),
          eyeW * 0.09,
          Paint()..color = Colors.white,
        );
      }
      canvas.drawOval(
        Rect.fromCenter(center: eyeCenter, width: eyeW, height: eyeH),
        Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    drawEye(leftEyeCenter, blink);
    drawEye(rightEyeCenter, blink || winkRight);

    _drawMouth(canvas, bodyCenter, baseRadius);
  }

  void _drawMouth(Canvas canvas, Offset bodyCenter, double baseRadius) {
    final mouthCenter =
    Offset(bodyCenter.dx - baseRadius * 0.02, bodyCenter.dy + baseRadius * 0.16);
    const closedThreshold = 0.16;

    if (mouthOpenness <= closedThreshold) {
      final t = (mouthOpenness / closedThreshold).clamp(0.0, 1.0);
      final halfW = baseRadius * (0.16 + t * 0.06);
      final peakLift = baseRadius * (0.05 + t * 0.04);
      final dip = baseRadius * 0.03 * (1 - t);

      final left = mouthCenter + Offset(-halfW, dip);
      final peak = mouthCenter + Offset(0, -peakLift);
      final right = mouthCenter + Offset(halfW, dip);

      final chevron = Path()
        ..moveTo(left.dx, left.dy)
        ..quadraticBezierTo(
          mouthCenter.dx - halfW * 0.3,
          peak.dy + baseRadius * 0.01,
          peak.dx,
          peak.dy,
        )
        ..quadraticBezierTo(
          mouthCenter.dx + halfW * 0.3,
          peak.dy + baseRadius * 0.01,
          right.dx,
          right.dy,
        );

      canvas.drawPath(
        chevron,
        Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round,
      );
      return;
    }

    final mouthW = baseRadius * (0.3 + mouthOpenness * 0.08);
    final mouthH = baseRadius * (0.08 + mouthOpenness * 0.5);

    canvas.drawOval(
      Rect.fromCenter(center: mouthCenter, width: mouthW, height: mouthH),
      Paint()..color = const Color(0xFF3D0F16),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: mouthCenter + Offset(0, mouthH * 0.22),
        width: mouthW * 0.28,
        height: mouthH * 0.5,
      ),
      Paint()..color = const Color(0xFFB5493F),
    );
    canvas.drawOval(
      Rect.fromCenter(center: mouthCenter, width: mouthW, height: mouthH.clamp(2, 999)),
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawChair(Canvas canvas, Offset bodyCenter, double baseRadius) {
    final chairPaint = Paint()
      ..color = const Color(0xFF6B4A32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final seatY = bodyCenter.dy + baseRadius * 0.55;
    final seatLeft = bodyCenter.dx - baseRadius * 0.55;
    final seatRight = bodyCenter.dx + baseRadius * 0.55;

    canvas.drawLine(Offset(seatLeft, seatY), Offset(seatRight, seatY), chairPaint);
    canvas.drawLine(
      Offset(seatLeft, seatY),
      Offset(seatLeft, seatY - baseRadius * 0.9),
      chairPaint,
    );
    canvas.drawLine(
      Offset(seatLeft, seatY - baseRadius * 0.9),
      Offset(seatLeft + baseRadius * 0.5, seatY - baseRadius * 1.05),
      chairPaint,
    );
    canvas.drawLine(
      Offset(seatLeft + 3, seatY),
      Offset(seatLeft + 1, seatY + baseRadius * 0.6),
      chairPaint,
    );
    canvas.drawLine(
      Offset(seatRight - 3, seatY),
      Offset(seatRight - 1, seatY + baseRadius * 0.6),
      chairPaint,
    );
  }

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  bool shouldRepaint(covariant _MorphPainter oldDelegate) => true;
}

class _Bubble {
  const _Bubble(this.offset, this.radius, this.phase, this.amplitude);
  final Offset offset;
  final double radius;
  final double phase;
  final double amplitude;
}