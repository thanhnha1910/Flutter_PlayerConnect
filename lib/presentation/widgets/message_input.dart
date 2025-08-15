import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSend;
  final bool enabled;
  final String? hintText;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.enabled = true,
    this.hintText,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final isComposing = widget.controller.text.trim().isNotEmpty;
    if (isComposing != _isComposing) {
      setState(() {
        _isComposing = isComposing;
      });
    }
  }

  void _handleSend() {
    final text = widget.controller.text.trim();
    if (text.isNotEmpty && widget.enabled) {
      widget.onSend(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: AppTheme.borderColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                  border: Border.all(
                    color: _isComposing ? AppTheme.primaryAccent.withOpacity(0.5) : AppTheme.borderColor,
                    width: _isComposing ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        enabled: widget.enabled,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: widget.hintText ?? 'Type a message...',
                          hintStyle: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingL,
                            vertical: AppTheme.spacingM,
                          ),
                        ),
                        style: AppTheme.bodyMedium,
                        onSubmitted: widget.enabled ? (_) => _handleSend() : null,
                      ),
                    ),
                    _buildAttachmentButton(),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingS),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentButton() {
    return IconButton(
      onPressed: widget.enabled ? _showAttachmentOptions : null,
      icon: Icon(
        Icons.attach_file,
        color: widget.enabled ? AppTheme.textSecondary : AppTheme.borderColor,
        size: AppTheme.iconSizeMedium,
      ),
    );
  }

  Widget _buildSendButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: _isComposing && widget.enabled
            ? LinearGradient(
                colors: [AppTheme.primaryAccent, AppTheme.primaryAccent.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: _isComposing && widget.enabled
            ? null
            : AppTheme.borderColor,
        shape: BoxShape.circle,
        boxShadow: _isComposing && widget.enabled
            ? [
                BoxShadow(
                  color: AppTheme.primaryAccent.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: IconButton(
        onPressed: _isComposing && widget.enabled ? _handleSend : null,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            Icons.send,
            key: ValueKey(_isComposing),
            color: _isComposing && widget.enabled
                ? Colors.white
                : AppTheme.textSecondary,
            size: AppTheme.iconSizeMedium,
          ),
        ),
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusL),
        ),
      ),
      builder: (context) => _buildAttachmentSheet(),
    );
  }

  Widget _buildAttachmentSheet() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'Send Attachment',
            style: AppTheme.headingSmall,
          ),
          const SizedBox(height: AppTheme.spacingL),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAttachmentOption(
                icon: Icons.photo_camera,
                label: 'Camera',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement camera functionality
                },
              ),
              _buildAttachmentOption(
                icon: Icons.photo_library,
                label: 'Gallery',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement gallery functionality
                },
              ),
              _buildAttachmentOption(
                icon: Icons.insert_drive_file,
                label: 'Document',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement document picker
                },
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primaryAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryAccent,
              size: AppTheme.iconSizeLarge,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            label,
            style: AppTheme.caption,
          ),
        ],
      ),
    );
  }
}