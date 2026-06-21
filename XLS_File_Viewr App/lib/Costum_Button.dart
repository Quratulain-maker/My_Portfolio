import 'package:flutter/material.dart';

class Costum_Button extends StatefulWidget {
  final String btnName;
  final Icon? icon;
  final Image? image;
  final VoidCallback? callBack;

  const Costum_Button({
    Key? key,
    required this.btnName,
    this.icon,
    this.image,
    this.callBack,
  }) : super(key: key);

  @override
  State<Costum_Button> createState() => _Costum_ButtonState();
}

class _Costum_ButtonState extends State<Costum_Button> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(12),
        backgroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: widget.callBack,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.image != null)
            SizedBox(width: 50, height: 50, child: widget.image!)
          else if (widget.icon != null)
            widget.icon!,
          const SizedBox(height: 8),
          Text(
            widget.btnName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E754C)),
          ),
        ],
      ),
    );
  }
}
