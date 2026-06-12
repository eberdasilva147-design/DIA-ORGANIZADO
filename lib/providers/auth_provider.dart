import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  /// Em modo local não há nuvem: o app pula o login e usa
  /// um nome padrão. Nenhuma chamada ao Supabase é feita.
  final bool localMode;

  User? _user;
  String _userName = '';
  bool _loading = false;
  String? _error;
  final Completer<void> _readyCompleter = Completer<void>();

  User? get user => _user;
  String get userName => _userName;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => localMode || _user != null;

  /// Completa quando o estado de autenticação está resolvido.
  /// Usado pelo splash para não navegar cedo demais.
  Future<void> get ready => _readyCompleter.future;

  AuthProvider({this.localMode = false}) {
    if (localMode) {
      _userName = 'Visitante';
      _readyCompleter.complete();
      return;
    }
    final auth = Supabase.instance.client.auth;
    // A sessão persistida já foi restaurada no Supabase.initialize()
    _user = auth.currentUser;
    _updateName();
    _readyCompleter.complete();

    auth.onAuthStateChange.listen((state) {
      _user = state.session?.user;
      _updateName();
      notifyListeners();
    });
  }

  void _updateName() {
    _userName = (_user?.userMetadata?['nome'] as String?) ??
        _user?.email?.split('@').first ??
        '';
  }

  Future<bool> signIn(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);
      _loading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = _authError(e);
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String nome, String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'nome': nome},
      );
      _loading = false;
      if (res.session == null) {
        // Confirmação de e-mail está ativada no projeto Supabase
        _error = 'Conta criada! Verifique seu e-mail para confirmar o cadastro.';
        notifyListeners();
        return false;
      }
      _userName = nome;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = _authError(e);
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    if (localMode) return;
    await Supabase.instance.client.auth.signOut();
    _user = null;
    _userName = '';
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _authError(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return 'E-mail ou senha incorretos.';
    }
    if (msg.contains('already registered')) {
      return 'E-mail já cadastrado.';
    }
    if (msg.contains('at least 6 characters') || msg.contains('weak')) {
      return 'Senha muito fraca. Use ao menos 6 caracteres.';
    }
    if (msg.contains('invalid email') || msg.contains('validate email')) {
      return 'E-mail inválido.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Confirme seu e-mail antes de entrar.';
    }
    if (msg.contains('rate limit') || msg.contains('too many')) {
      return 'Muitas tentativas. Tente novamente mais tarde.';
    }
    return 'Erro de autenticação. Tente novamente.';
  }
}
