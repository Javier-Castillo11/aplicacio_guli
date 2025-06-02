import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';

class FilterMenu extends StatelessWidget {
  final Function(String) onFilterSelected;

  const FilterMenu({Key? key, required this.onFilterSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return PopupMenuButton<String>(
      icon: Icon(Icons.filter_list, color: Theme.of(context).iconTheme.color),
      onSelected: onFilterSelected,
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            value: 'reciente',
            child: Text(languageProvider.currentLanguage == 'es'
                ? 'Más reciente'
                : 'Most recent')),
          PopupMenuItem(
              value: '30dias',
              child: Text(languageProvider.currentLanguage == 'es'
                  ? 'Últimos 30 días'
                  : 'Last 30 days')),
          PopupMenuItem(
              value: 'antiguo',
              child: Text(languageProvider.currentLanguage == 'es'
                  ? 'Más antiguo'
                  : 'Oldest')),
        ];
      },
    );
  }
}