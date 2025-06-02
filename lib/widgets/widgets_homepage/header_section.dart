import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({
    Key? key,
    
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 105,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  height: 60,
                  width: 60,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}