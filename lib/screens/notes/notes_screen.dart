import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/note_model.dart';
import '../../providers/note_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/dia_colors.dart';
import '../../utils/l10n_ext.dart';

class NotesScreen extends StatelessWidget {
  NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(l.notesTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.accent),
            onPressed: () => showNoteModal(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              onChanged: context.read<NoteProvider>().setSearch,
              style: TextStyle(color: context.colors.textPrimary),
              decoration: InputDecoration(
                hintText: l.searchHint,
                prefixIcon:
                    Icon(Icons.search, color: context.colors.textSecondary),
                fillColor: context.colors.card,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.colors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.accent, width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<NoteProvider>(
              builder: (_, provider, __) {
                final notes = provider.notes;
                if (notes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sticky_note_2_outlined,
                            size: 56, color: context.colors.textSecondary),
                        SizedBox(height: 12),
                        Text(l.noNotes,
                            style: TextStyle(color: context.colors.textSecondary)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: notes.length,
                  itemBuilder: (_, i) =>
                      _NoteCard(note: notes[i]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_notas',
        onPressed: () => showNoteModal(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(l.newNoteFab, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

void showNoteModal(BuildContext context, {NoteModel? note}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<NoteProvider>(),
      child: _NoteCreateModal(note: note),
    ),
  );
}

class _NoteCard extends StatelessWidget {
  final NoteModel note;

  _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return GestureDetector(
      onLongPress: () => _confirmDelete(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.titulo,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (note.corpo.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                note.corpo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: context.colors.textSecondary, fontSize: 13),
              ),
            ],
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(note.dataCriacao),
                  style: TextStyle(
                      color: context.colors.textSecondary, fontSize: 11),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => showNoteModal(context, note: note),
                  icon: const Icon(Icons.edit_outlined,
                      size: 16, color: AppColors.accent),
                  label: Text(l.actionEdit,
                      style: TextStyle(color: AppColors.accent, fontSize: 13)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                IconButton(
                  onPressed: () => _confirmDelete(context),
                  icon: Icon(Icons.delete_outline,
                      size: 18, color: context.colors.textSecondary),
                  tooltip: l.actionDelete,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final l = context.l10n;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.colors.card,
        title: Text(l.moveToTrash,
            style: TextStyle(color: context.colors.textPrimary)),
        content: Text(l.moveToTrashNoteMsg,
            style: TextStyle(color: context.colors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<NoteProvider>().softDeleteNote(note.id);
            },
            child: Text(l.actionDelete,
                style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _NoteCreateModal extends StatefulWidget {
  final NoteModel? note;
  const _NoteCreateModal({this.note});

  @override
  State<_NoteCreateModal> createState() => _NoteCreateModalState();
}

class _NoteCreateModalState extends State<_NoteCreateModal> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    final n = widget.note;
    if (n != null) {
      _titleCtrl.text = n.titulo;
      _bodyCtrl.text = n.corpo;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    final provider = context.read<NoteProvider>();
    if (_isEditing) {
      await provider.updateNote(NoteModel(
        id: widget.note!.id,
        titulo: _titleCtrl.text.trim(),
        corpo: _bodyCtrl.text.trim(),
        dataCriacao: widget.note!.dataCriacao,
      ));
    } else {
      await provider.addNote(
        titulo: _titleCtrl.text.trim(),
        corpo: _bodyCtrl.text.trim(),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.backgroundSecondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: context.colors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(_isEditing ? l.editNoteTitle : l.newNoteTitle,
                style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              style: TextStyle(color: context.colors.textPrimary),
              decoration: InputDecoration(hintText: l.noteTitleHint),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyCtrl,
              maxLines: 4,
              style: TextStyle(color: context.colors.textPrimary),
              decoration: InputDecoration(
                hintText: l.noteContentHint,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
              child: Text(_isEditing ? l.saveChanges : l.saveNote),
            ),
          ],
        ),
      ),
    );
  }
}
