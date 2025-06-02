import 'package:flutter/material.dart';

class HeaderImage extends StatelessWidget {
  const HeaderImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.42,
      child: Image.network(
        "https://cdn.builder.io/api/v1/image/assets/07b7b4c075d4456b854e11b352f3a209/cd2108b44906ab67b4333de98ffac628313c51b71e3904e53306f24c69a17d39?placeholderIfAbsent=true",
        fit: BoxFit.contain,
        
      ),
    );
  }
}