import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon.dart';
import '../models/mood_entry_draft_model.dart';

/// Tek cümle kuralı: satır atlama boşluğa döner, 140 karakter (grafem) üstü kesilir.
class SingleSentenceFormatter extends TextInputFormatter {
  final int maxLength;

  const SingleSentenceFormatter([this.maxLength = MoodEntryDraftModel.maxNoteLength]);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(RegExp(r'[\r\n]+'), ' ');
    final chars = text.characters;
    if (chars.length > maxLength) text = chars.take(maxLength).toString();
    if (text == newValue.text) return newValue;
    final offset = newValue.selection.baseOffset.clamp(0, text.length);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

/// Not alanı (`note-field`): 18 px yarıçap, odakta kenar `fg`; altta kilit
/// bilgisi ve mono `0/140` sayaç (sınırda tehlike rengi). Yazarken hareket yok.
class NoteField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final bool showLockIcon;

  const NoteField({super.key, required this.value, required this.onChanged, this.showLockIcon = true});

  @override
  State<NoteField> createState() => _NoteFieldState();
}

class _NoteFieldState extends State<NoteField> {
  late final TextEditingController _text = TextEditingController(text: widget.value);
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(NoteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _text.text) _text.text = widget.value;
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final length = widget.value.characters.length;
    final atLimit = length >= MoodEntryDraftModel.maxNoteLength;
    final small = AppTypography.body(12, height: 1.4, color: p.muted);
    return GestureDetector(
      onTap: _focus.requestFocus,
      child: AnimatedContainer(
        duration: AppMotion.press,
        curve: AppMotion.easeOut,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _focus.hasFocus ? p.fg : p.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppStrings.noteLabel, style: small),
            const SizedBox(height: 4),
            SizedBox(
              height: 46,
              child: TextField(
                controller: _text,
                focusNode: _focus,
                onChanged: widget.onChanged,
                inputFormatters: const [SingleSentenceFormatter()],
                minLines: 2,
                maxLines: 2,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.sentences,
                style: AppTypography.body(16, height: 1.4, color: p.fg),
                cursorColor: p.fg,
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: AppStrings.notePlaceholder,
                  hintStyle: AppTypography.body(16, height: 1.4, color: p.muted),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                if (widget.showLockIcon) ...[
                  AppIcon(AppIcons.lock, size: 14, color: p.muted),
                  const SizedBox(width: 5),
                ],
                Expanded(child: Text(AppStrings.noteLocked, style: small)),
                Text(
                  AppStrings.noteCount(length, MoodEntryDraftModel.maxNoteLength),
                  style: AppTypography.mono(
                    12,
                    weight: atLimit ? FontWeight.w600 : FontWeight.w400,
                    color: atLimit ? p.danger : p.muted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
