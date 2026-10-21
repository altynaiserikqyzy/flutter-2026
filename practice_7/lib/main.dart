import 'package:flutter/material.dart';

import 'summary_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
    home: const SignUpScreen(),
  );
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthController = TextEditingController();

  final _emailFocus = FocusNode();

  String? _group;
  DateTime? _birthDate;
  bool _agreed = false;

  int _passwordLength = 0;
  bool _done = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm, _birthController]) {
      c.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Account created')));
      setState(() {
        _done = true;
      });
    }
  }

  void _resetForm() {
    _name.clear();
    _email.clear();
    _password.clear();
    _confirm.clear();
    _birthController.clear();
    _emailFocus.unfocus();
    setState(() {
      _group = null;
      _birthDate = null;
      _agreed = false;
      _passwordLength = 0;
      _done = false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        _birthDate = picked;
        final day = picked.day.toString().padLeft(2, '0');
        final month = picked.month.toString().padLeft(2, '0');
        final year = picked.year;
        _birthController.text = '$day.$month.$year';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: _done
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SummaryCard(
                    name: _name.text,
                    email: _email.text,
                    group: _group ?? '',
                    birthDate: _birthController.text,
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: _resetForm,
                    child: const Text('Start over'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _name,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Name'),
                      onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      validator: (v) {
                        final val = (v ?? '').trim();
                        if (val.length < 2) return 'Name is too short';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'name@kbtu.kz',
                      ),
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      validator: (v) {
                        final val = v ?? '';
                        if (!val.contains('@') || !val.contains('.')) {
                          return 'Email looks wrong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        helperText: 'At least 8 characters',
                      ),
                      onChanged: (v) {
                        setState(() {
                          _passwordLength = v.length;
                        });
                      },
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      validator: (v) {
                        final val = v ?? '';
                        if (val.length < 8) return 'Password is too short';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Text('$_passwordLength of 8'),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirm,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Confirm password',
                      ),
                      onFieldSubmitted: (_) => _submitForm(),
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      validator: (v) {
                        final val = v ?? '';
                        if (val != _password.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _group,
                      decoration: const InputDecoration(labelText: 'Group'),
                      items: groups
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _group = v;
                        });
                      },
                      validator: (g) => g == null ? 'Choose a group' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _birthController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Birth Date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: _pickDate,
                      validator: (_) =>
                          _birthDate == null ? 'Choose a date' : null,
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('I agree to the rules'),
                      value: _agreed,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) {
                        setState(() {
                          _agreed = v ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _agreed ? _submitForm : null,
                      child: const Text('Sign up'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
