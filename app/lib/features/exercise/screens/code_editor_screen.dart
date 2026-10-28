import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/sources/remote/code_runner_source.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/code_runner_provider.dart';

class CodeEditorScreen extends ConsumerStatefulWidget {
  final int levelId;
  final String levelTitle;

  const CodeEditorScreen({
    required this.levelId,
    required this.levelTitle,
    super.key,
  });

  @override
  ConsumerState<CodeEditorScreen> createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends ConsumerState<CodeEditorScreen> {
  String _selectedLanguage = 'cpp';
  late TextEditingController _codeController;
  CodeRunResult? _result;
  bool _isLoading = false;
  String? _errorMessage;

  static const _cppStarter = '''#include <iostream>

int main() {
    std::cout << "Halo KODIRA" << std::endl;
    return 0;
}''';

  static const _javaStarter = '''public class Main {
    public static void main(String[] args) {
        System.out.println("Halo KODIRA");
    }
}''';

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: _cppStarter);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onLanguageChanged(String lang) {
    if (_selectedLanguage == lang) return;

    final currentCode = _codeController.text.trim();
    final isCurrentStarter =
        currentCode == _cppStarter.trim() || currentCode == _javaStarter.trim();

    setState(() {
      _selectedLanguage = lang;
      if (isCurrentStarter) {
        _codeController.text = lang == 'cpp' ? _cppStarter : _javaStarter;
      }
    });
  }

  Future<void> _runCode() async {
    setState(() {
      _isLoading = true;
      _result = null;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(codeRunnerRepositoryProvider);
      final result = await repository.runCode(
        sourceCode: _codeController.text,
        language: _selectedLanguage,
      );

      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KodiraColors.neutral100,
      appBar: AppBar(
        title: Text('Latihan Coding — Level ${widget.levelId}'),
        backgroundColor: Colors.white,
        foregroundColor: KodiraColors.neutral900,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language Selector
              Semantics(
                label: 'Pilih bahasa pemrograman',
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'cpp',
                      label: Text('C++'),
                      icon: Icon(Icons.code),
                    ),
                    ButtonSegment(
                      value: 'java',
                      label: Text('Java'),
                      icon: Icon(Icons.coffee),
                    ),
                  ],
                  selected: {_selectedLanguage},
                  onSelectionChanged: (Set<String> selection) {
                    _onLanguageChanged(selection.first);
                  },
                  showSelectedIcon: false,
                  style: SegmentedButton.styleFrom(
                    backgroundColor: Colors.white,
                    selectedBackgroundColor: KodiraColors.primary100,
                    selectedForegroundColor: KodiraColors.primary700,
                    side: const BorderSide(color: KodiraColors.neutral200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(KodiraRadius.md),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Code Editor Box
              Container(
                decoration: BoxDecoration(
                  color: KodiraColors.codeBg,
                  borderRadius: BorderRadius.circular(KodiraRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Editor Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(KodiraRadius.md),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _selectedLanguage == 'cpp'
                                ? 'main.cpp'
                                : 'Main.java',
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 12,
                              color: KodiraColors.neutral300,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _codeController.text =
                                    _selectedLanguage == 'cpp'
                                    ? _cppStarter
                                    : _javaStarter;
                              });
                            },
                            child: const Text(
                              'Reset',
                              style: TextStyle(
                                fontSize: 12,
                                color: KodiraColors.primary500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Editor Field
                    SizedBox(
                      height: 260,
                      child: TextField(
                        controller: _codeController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 13,
                          color: Colors.white,
                          height: 1.5,
                        ),
                        cursorColor: KodiraColors.primary500,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(16),
                          border: InputBorder.none,
                          hintText: 'Tulis kodemu di sini...',
                          hintStyle: TextStyle(color: KodiraColors.neutral500),
                        ),
                        keyboardType: TextInputType.multiline,
                        autocorrect: false,
                        enableSuggestions: false,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Run Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: Semantics(
                  label: 'Tombol jalankan kode',
                  button: true,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _runCode,
                    icon: _isLoading
                        ? const SizedBox.shrink()
                        : const Icon(Icons.play_arrow, size: 20),
                    label: Text(_isLoading ? 'Menjalankan...' : 'Jalankan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KodiraColors.primary700,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: KodiraColors.neutral300,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(KodiraRadius.md),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Output/Loading Section
              if (_isLoading)
                const KodiraLoadingWidget(message: 'Mengeksekusi kode...')
              else if (_errorMessage != null)
                _buildErrorPanel(_errorMessage!)
              else if (_result != null)
                _buildOutputPanel(_result!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorPanel(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KodiraColors.alert100,
        borderRadius: BorderRadius.circular(KodiraRadius.md),
        border: Border.all(color: KodiraColors.alert500.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.error_outline, color: KodiraColors.alert700, size: 18),
              SizedBox(width: 8),
              Text(
                'Terjadi Kesalahan',
                style: TextStyle(
                  color: KodiraColors.alert700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: KodiraColors.alert700, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputPanel(CodeRunResult result) {
    final bool success = result.isSuccess;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Output',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: KodiraColors.neutral900,
              ),
            ),
            const Spacer(),
            // Status Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: success
                    ? KodiraColors.success100
                    : KodiraColors.alert100,
                borderRadius: BorderRadius.circular(KodiraRadius.full),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    success ? Icons.check_circle : Icons.error,
                    size: 14,
                    color: success
                        ? KodiraColors.success700
                        : KodiraColors.alert700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    result.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: success
                          ? KodiraColors.success700
                          : KodiraColors.alert700,
                    ),
                  ),
                ],
              ),
            ),
            if (result.time.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                '${result.time}s',
                style: const TextStyle(
                  fontSize: 12,
                  color: KodiraColors.neutral500,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Semantics(
          label: 'Hasil eksekusi kode',
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KodiraColors.neutral900,
              borderRadius: BorderRadius.circular(KodiraRadius.md),
            ),
            child: SingleChildScrollView(
              child: Text(
                result.displayOutput,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 12,
                  color: Colors.white,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
