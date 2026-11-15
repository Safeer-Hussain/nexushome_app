import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ai_copilot_provider.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/prompt_shortcuts.dart';

class AiHomeCopilotView extends ConsumerStatefulWidget {
  const AiHomeCopilotView({super.key});

  @override
  ConsumerState<AiHomeCopilotView> createState() => _AiHomeCopilotViewState();
}

class _AiHomeCopilotViewState extends ConsumerState<AiHomeCopilotView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    ref.read(aiCopilotProvider.notifier).sendUserPrompt(text);
    _textController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final copilotState = ref.watch(aiCopilotProvider);
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen(aiCopilotProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length ||
          prev?.messages.lastOrNull?.text != next.messages.lastOrNull?.text) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true, // CRITICAL: Standard resize
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'fab_ai_home_clear', // CRITICAL: Explicit Unique Hero Tag
        tooltip: 'Reset Conversation',
        child: const Icon(Icons.refresh_rounded),
        onPressed: () {
          ref.read(aiCopilotProvider.notifier).clearConversation();
        },
      ),
      body: Column(
        children: [
          // Header info banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: colorScheme.surfaceContainer,
            child: Row(
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 14,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'On-Device LLM Copilot • Local SQLite & Zero-Cloud Private Telemetry',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Chat message list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              itemCount: copilotState.messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: copilotState.messages[index]);
              },
            ),
          ),
          // Transient auditing status indicator
          if (copilotState.statusIndicator != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    copilotState.statusIndicator!,
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Prompt shortcuts bar
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: PromptShortcuts(onSelect: _sendMessage),
          ),
          // Bottom input bar
          SafeArea(
            top: false, // CRITICAL: NEVER double apply viewInsets on resizeToAvoidBottomInset: true
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                border: Border(
                  top: BorderSide(color: colorScheme.outlineVariant, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                      enabled: !copilotState.isStreaming,
                      decoration: InputDecoration(
                        hintText: copilotState.isStreaming
                            ? 'Copilot is synthesizing telemetry...'
                            : 'Ask Copilot about power, mesh, or tariffs...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: copilotState.isStreaming
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.arrow_upward_rounded, size: 20),
                    onPressed: copilotState.isStreaming
                        ? null
                        : () => _sendMessage(_textController.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
