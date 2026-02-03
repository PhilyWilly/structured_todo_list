import 'package:fluent_ui/fluent_ui.dart';

class AnimatingTextfield extends StatefulWidget {
  final TextEditingController? controller;
  final double maxWidth;
  final Duration duration;
  final Curve curve;
  final void Function(String)? onSubmitted;

  const AnimatingTextfield({
    super.key,
    this.controller,
    this.maxWidth = 200.0,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOut,
    this.onSubmitted,
  });

  @override
  State<AnimatingTextfield> createState() => AnimatingTextfieldState();
}

class AnimatingTextfieldState extends State<AnimatingTextfield> {
  bool isOpen = false;

  void changeState(bool newState) {
    setState(() {
      isOpen = newState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: widget.duration,
      curve: widget.curve,
      child: SizedBox(
        width: isOpen ? widget.maxWidth : 0.0,
        child: TextBox(
          controller: widget.controller,
          onSubmitted: widget.onSubmitted,
        ),
      ),
    );
  }
}
