import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/registrant_model.dart';
import '../providers/registration_provider.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dateController = TextEditingController();

  bool _obscurePassword = true;
  String _selectedGender = 'Laki-laki';
  String? _selectedProdi;
  DateTime? _selectedDate;
  bool _agreeTerms = false;
  int _currentStep = 0;

  bool _isEditMode = false;
  String? _editingId;
  DateTime? _registeredAt;
  bool _argsLoaded = false;

  final List<String> _prodiList = [
    'Teknik Informatika',
    'Sistem Informasi',
    'Teknik Komputer',
    'Data Science',
    'Desain Komunikasi Visual',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsLoaded) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      final existing = context.read<RegistrationProvider>().getById(args);
      if (existing != null) {
        _isEditMode = true;
        _editingId = existing.id;
        _registeredAt = existing.registeredAt;
        _nameController.text = existing.name;
        _emailController.text = existing.email;
        _passwordController.text = 'password123';
        _selectedGender = existing.gender;
        _selectedProdi = existing.programStudi;
        _selectedDate = existing.dateOfBirth;
        _dateController.text = _formatDate(existing.dateOfBirth);
        _agreeTerms = true;
      }
    }

    _argsLoaded = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2004, 1, 1),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Lahir',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  bool _validateStep0() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passwordController.text;

    final emailRegex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return name.length >= 3 && emailRegex.hasMatch(email) && pass.length >= 8;
  }

  bool _validateStep1() {
    return _selectedProdi != null && _selectedDate != null;
  }

  void _showStepError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lengkapi data pada step ini terlebih dahulu'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _continueStep() {
    if (_currentStep == 0 && !_validateStep0()) {
      _showStepError();
      setState(() {});
      return;
    }

    if (_currentStep == 1 && !_validateStep1()) {
      _showStepError();
      setState(() {});
      return;
    }

    if (_currentStep < 2) {
      setState(() => _currentStep += 1);
      return;
    }

    _submitForm();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap setujui syarat & ketentuan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final provider = context.read<RegistrationProvider>();
    if (provider.isEmailRegistered(
      _emailController.text.trim(),
      excludeId: _editingId,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email sudah terdaftar!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final registrant = Registrant(
      id: _editingId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      gender: _selectedGender,
      programStudi: _selectedProdi!,
      dateOfBirth: _selectedDate!,
      registeredAt: _registeredAt,
    );

    if (_isEditMode) {
      provider.updateRegistrant(registrant);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          title: const Text('Update Berhasil!'),
          content: Text('${registrant.name} berhasil diperbarui.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Kembali'),
            ),
          ],
        ),
      );
      return;
    }

    provider.addRegistrant(registrant);
    _resetForm();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Registrasi Berhasil!'),
        content: Text('${registrant.name} berhasil didaftarkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Daftar Lagi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/list');
            },
            child: const Text('Lihat Daftar'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _dateController.clear();
    setState(() {
      _selectedGender = 'Laki-laki';
      _selectedProdi = null;
      _selectedDate = null;
      _agreeTerms = false;
      _currentStep = 0;
    });
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Akun'),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        content: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap *',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama wajib diisi';
                }
                if (value.trim().length < 3) {
                  return 'Nama minimal 3 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
                hintText: 'nama@email.com',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email wajib diisi';
                }
                final emailRegex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Format email tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: _isEditMode ? 'Password (dummy) *' : 'Password *',
                prefixIcon: const Icon(Icons.lock),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password wajib diisi';
                }
                if (value.length < 8) {
                  return 'Password minimal 8 karakter';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Profil'),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Jenis Kelamin *', style: TextStyle(fontSize: 16)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Laki-laki'),
                    value: 'Laki-laki',
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() => _selectedGender = value!);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Perempuan'),
                    value: 'Perempuan',
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() => _selectedGender = value!);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedProdi,
              decoration: const InputDecoration(
                labelText: 'Program Studi *',
                prefixIcon: Icon(Icons.school),
                border: OutlineInputBorder(),
              ),
              hint: const Text('Pilih Program Studi'),
              items: _prodiList
                  .map(
                    (prodi) =>
                        DropdownMenuItem(value: prodi, child: Text(prodi)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedProdi = value);
              },
              validator: (value) {
                if (value == null) return 'Pilih program studi';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Tanggal Lahir *',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
              onTap: _pickDate,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tanggal lahir wajib diisi';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Konfirmasi'),
        isActive: _currentStep >= 2,
        content: Column(
          children: [
            CheckboxListTile(
              title: const Text('Saya setuju dengan syarat & ketentuan *'),
              subtitle: const Text('Wajib dicentang sebelum submit'),
              value: _agreeTerms,
              onChanged: (value) {
                setState(() => _agreeTerms = value ?? false);
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isEditMode
                        ? 'Klik Submit untuk menyimpan perubahan data.'
                        : 'Klik Submit untuk menyelesaikan pendaftaran.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Pendaftar' : 'Registrasi Event'),
        actions: [
          Consumer<RegistrationProvider>(
            builder: (context, provider, child) {
              return Badge(
                label: Text('${provider.count}'),
                isLabelVisible: provider.count > 0,
                child: IconButton(
                  icon: const Icon(Icons.people),
                  onPressed: () => Navigator.pushNamed(context, '/list'),
                ),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped: (value) => setState(() => _currentStep = value),
          onStepContinue: _continueStep,
          onStepCancel: () {
            if (_currentStep == 0) return;
            setState(() => _currentStep -= 1);
          },
          controlsBuilder: (context, details) {
            final isLast = _currentStep == 2;
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: details.onStepContinue,
                    icon: Icon(isLast ? Icons.check : Icons.arrow_forward),
                    label: Text(isLast ? 'Submit' : 'Lanjut'),
                  ),
                  const SizedBox(width: 8),
                  if (_currentStep > 0)
                    OutlinedButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Kembali'),
                    ),
                  const SizedBox(width: 8),
                  if (!_isEditMode)
                    TextButton(
                      onPressed: _resetForm,
                      child: const Text('Reset Form'),
                    ),
                ],
              ),
            );
          },
          steps: _buildSteps(),
        ),
      ),
    );
  }
}
