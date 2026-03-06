import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/registrant_model.dart';
import '../providers/registration_provider.dart';

class RegistrantListPage extends StatefulWidget {
  const RegistrantListPage({super.key});

  @override
  State<RegistrantListPage> createState() => _RegistrantListPageState();
}

class _RegistrantListPageState extends State<RegistrantListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Registrant> _filtered(List<Registrant> source) {
    if (_query.trim().isEmpty) return source;
    final q = _query.toLowerCase();
    return source.where((r) {
      return r.name.toLowerCase().contains(q) ||
          r.email.toLowerCase().contains(q) ||
          r.programStudi.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<RegistrationProvider>(
          builder: (context, provider, _) {
            final filteredCount = _filtered(provider.registrants).length;
            if (_query.trim().isNotEmpty) {
              return Text('Daftar Peserta ($filteredCount/${provider.count})');
            }
            return Text('Daftar Peserta (${provider.count})');
          },
        ),
      ),
      body: Consumer<RegistrationProvider>(
        builder: (context, provider, child) {
          final items = _filtered(provider.registrants);

          if (provider.registrants.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada pendaftar',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Daftar sekarang di halaman registrasi!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Cari nama, email, atau prodi...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text('Tidak ada hasil pencarian'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final registrant = items[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(registrant.name[0].toUpperCase()),
                              ),
                              title: Text(
                                registrant.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${registrant.programStudi} • ${registrant.email}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/edit',
                                        arguments: registrant.id,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Hapus Pendaftar?'),
                                          content: Text(
                                            'Yakin hapus ${registrant.name}?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
                                              child: const Text('Batal'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                provider.removeRegistrant(
                                                  registrant.id,
                                                );
                                                Navigator.pop(ctx);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              child: const Text('Hapus'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/detail',
                                  arguments: registrant.id,
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
