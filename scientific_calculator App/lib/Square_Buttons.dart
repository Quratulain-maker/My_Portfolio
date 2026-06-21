import 'package:flutter/material.dart';

class SquareButton extends StatelessWidget{
  final String btnName;
  final Icon? icon;
  final Color? bgColor;
  final TextStyle? textStyle;
  final VoidCallback? callBack;


  SquareButton({
       required this.btnName,
      this.icon,
      this.bgColor,
      this.textStyle,
      this.callBack});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: (){

         callBack!();


    },
      style: ElevatedButton.styleFrom(
        fixedSize: Size(82.2,75.9),
backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.zero),

        )
      ),
        child: Text(btnName,

            style: TextStyle(fontSize:19  ,fontWeight: FontWeight.w900),
        )

    );
  }

}