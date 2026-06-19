import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/dia_colors.dart';
import '../../utils/l10n_ext.dart';
import '../main_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
        _nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => MainScaffold()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(l.registerTitle),
        leading: BackButton(color: AppColors.accent),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: l.nameLabel,
                    prefixIcon: Icon(Icons.person_outline,
                        color: context.colors.textSecondary),
                  ),
                  style: TextStyle(color: context.colors.textPrimary),
                  validator: (v) =>
                      v == null || v.isEmpty ? l.nameRequired : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l.emailLabel,
                    prefixIcon: Icon(Icons.email_outlined,
                        color: context.colors.textSecondary),
                  ),
                  style: TextStyle(color: context.colors.textPrimary),
                  validator: (v) =>
                      v == null || !v.contains('@') ? l.invalidEmail : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: l.passwordLabel,
                    prefixIcon: Icon(Icons.lock_outline,
                        color: context.colors.textSecondary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: context.colors.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  style: TextStyle(color: context.colors.textPrimary),
                  validator: (v) =>
                      v == null || v.length < 6 ? l.minChars : null,
                ),
                if (auth.error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                    ),
                    child: Text(auth.error!,
                        style:
                            const TextStyle(color: AppColors.error, fontSize: 13)),
                  ),
                ],
                const SizedBox(height: 24),
                auth.loading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.accent))
                    : ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52)),
                        child: Text(l.registerButton,
                            style: const TextStyle(fontSize: 17)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
