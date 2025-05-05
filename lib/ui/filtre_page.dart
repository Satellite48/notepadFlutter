import 'package:flutter/material.dart';

import '../model/note.dart';

// Fonction pour afficher les options de filtrage
void showFilterOptions({
  required BuildContext context,
  required String? selectedFilter,
  required Function(String?) onFilterSelected,
}) {
  final filters = ['Toutes', 'Défaut', 'Important', 'Urgent'];

  //afficher le popup
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center, // Centrer le texte
              child: const Text(
                'Filtrer les notes',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            ...filters.map(
                  (filter) => ListTile(
                leading: Icon(
                  filter == 'Défaut'
                      ? Icons.low_priority
                      : filter == 'Important'
                      ? Icons.warning
                      : Icons.error,
                  color: Colors.blueAccent,
                ),
                title: Text(filter),
                onTap: () {
                  onFilterSelected(filter);
                  Navigator.pop(context);
                },
                trailing:
                selectedFilter == filter
                    ? const Icon(Icons.check, color: Colors.blueAccent)
                    : null,
              ),
            ),
          ],
        ),
      );
    },
  );
}

// Fonction pour filtrer les notes
List<Note> filterNotes({
  required List<Note> notes,
  required String query,
  required String? selectedFilter,
}) {
  //filtre la liste des notes
  return notes.where((note) {
    final matchesQuery =
        note.title.toLowerCase().contains(query.toLowerCase()) ||
            note.content.toLowerCase().contains(query.toLowerCase());

    if (selectedFilter == null || selectedFilter == 'Toutes') {
      return matchesQuery;
    }

    return matchesQuery && note.priority == selectedFilter;
  }).toList();
}
