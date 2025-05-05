import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoteCard extends StatelessWidget {
  //proprietes
  final String title;
  final String content;
  final int type; // 0: Normal, 1: Important, 2: Urgent
  final DateTime date;
  final bool isFavorite;
  final String category;
  final VoidCallback? onTap;
  final VoidCallback? onStarPressed;
  final VoidCallback? onEditPressed;
  final VoidCallback? onArchivePressed;
  final VoidCallback? onDeletePressed;

  //iconstructeur pour in initialiser les proprietes
  const NoteCard({
    super.key,
    required this.title,
    required this.content,
    required this.type,
    required this.date,
    required this.category,
    this.isFavorite = false,
    this.onTap,
    this.onStarPressed,
    this.onEditPressed,
    this.onArchivePressed,
    this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    final noteColor = _getNoteColor(
      type,
    ); //recuperer la couleur en fonction du type de note
    final noteIcon = _getNoteIcon(
      type,
    ); // recuperer l'icone en fonction du type de note

    //creation de la card
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: noteColor.withOpacity(0.3), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec type, catégorie et date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: noteColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(noteIcon, size: 16, color: noteColor),
                            const SizedBox(width: 4),
                            //typope de la note
                            Text(
                              _getNoteTypeText(type),
                              style: TextStyle(
                                color: noteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),

                        //category de la note
                        child: Text(
                          category,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  //date de la note
                  Text(
                    _formatDate(date),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Titre de la note
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Contenu de la note
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Pied de card avec heure et actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //heure
                  Text(
                    DateFormat('HH:mm').format(date),
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  Row(
                    //actions
                    children: [
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          color:
                              isFavorite
                                  ? Colors.yellow[700]
                                  : Colors.grey[400],
                          size: 22,
                        ),
                        onPressed: onStarPressed,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.blueAccent[400],
                          size: 22,
                        ),
                        onPressed: onEditPressed,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),

                      //Archivage
                      IconButton(
                        icon: Icon(
                          Icons.archive_outlined,
                          color: Colors.blueAccent[400],
                          size: 22,
                        ),
                        onPressed: onArchivePressed,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),

                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                          size: 22,
                        ),
                        onPressed: onDeletePressed,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //couleur pour le type de note
  Color _getNoteColor(int type) {
    switch (type) {
      case 1: // Important
        return Colors.orange;
      case 2: // Urgent
        return Colors.red;
      default: // Normal
        return Colors.blue;
    }
  }

  //icone pour le type de note
  IconData _getNoteIcon(int type) {
    switch (type) {
      case 1: // Important
        return Icons.warning;
      case 2: // Urgent
        return Icons.error;
      default: // Normal
        return Icons.low_priority;
    }
  }

  //type de note
  String _getNoteTypeText(int type) {
    switch (type) {
      case 1:
        return 'Important';
      case 2:
        return 'Urgent';
      default:
        return 'Normal';
    }
  }

  //formater la date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Aujourd'hui";
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}
