import 'package:flutter/material.dart';
import '../service/auth_service.dart';
import '../data/repository/note_repository.dart';

void showProfilePopup(
    BuildContext context,
    String? userLastname,
    String? userFirstname,
    String? userEmail,
    ) async {
  final authService = AuthService();
  final noteRepository = NoteRepository();
  final userId = await authService.getCurrentUserId();
  // Récupère le nombre de notes ou 0 si userId est null
  final countNote = userId != null
      ? await noteRepository.getNoteCountForUser(userId.toString())
      : 0;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
    ),
    builder: (context) => Container(
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.5,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                const Text(
                  'Profil',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Icon(
                  Icons.account_circle,
                  size: 50,
                  color: Colors.blueAccent,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileItem(
                      'Nom',
                      userLastname ?? 'Non défini',
                      Icons.person,
                    ),
                    _buildProfileItem(
                      'Prénom',
                      userFirstname ?? 'Non défini',
                      Icons.person_outline,
                    ),
                    _buildProfileItem(
                      'Email',
                      userEmail ?? 'Non défini',
                      Icons.email,
                    ),
                    _buildProfileItem(
                      'Notes Total',
                      countNote.toString(),
                      Icons.note,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirmer la déconnexion'),
                      content: const Text(
                        'Voulez-vous vraiment vous déconnecter ?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            'Annuler',
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Déconnexion',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await _logout(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Déconnexion',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildProfileItem(String label, String value, IconData icon) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

//fonction pour se deconnecter
Future<void> _logout(BuildContext context) async {
  try {
    await AuthService().logout();
    Navigator.pop(context); // Ferme le Bottom Sheet
    Navigator.pushReplacementNamed(context, '/sign_in');
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur lors de la déconnexion: $e')),
    );
  }
}