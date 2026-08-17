import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../theme.dart';

class AddPlaylistSheet extends StatefulWidget {
  const AddPlaylistSheet({super.key});

  @override
  State<AddPlaylistSheet> createState() => _AddPlaylistSheetState();
}

class _AddPlaylistSheetState extends State<AddPlaylistSheet> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _submitting = false;
  String? _error;

  final _xtName = TextEditingController();
  final _xtHost = TextEditingController();
  final _xtUser = TextEditingController();
  final _xtPass = TextEditingController();

  final _urlName = TextEditingController();
  final _url = TextEditingController();
  final _urlEpg = TextEditingController();

  final _fileName = TextEditingController();
  PlatformFile? _pickedM3u;
  PlatformFile? _pickedEpg;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in [_xtName, _xtHost, _xtUser, _xtPass, _urlName, _url, _urlEpg, _fileName]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickM3uFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['m3u', 'm3u8', 'txt'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedM3u = result.files.first);
    }
  }

  Future<void> _pickEpgFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xml'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedEpg = result.files.first);
    }
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _submitting = true;
    });
    final state = context.read<AppState>();
    try {
      switch (_tabController.index) {
        case 0:
          if (_xtName.text.trim().isEmpty ||
              _xtHost.text.trim().isEmpty ||
              _xtUser.text.trim().isEmpty ||
              _xtPass.text.isEmpty) {
            throw Exception('Name, host, username and password are all required.');
          }
          await state.addXtream(
            name: _xtName.text.trim(),
            host: _xtHost.text.trim(),
            username: _xtUser.text.trim(),
            password: _xtPass.text,
          );
          break;
        case 1:
          if (_urlName.text.trim().isEmpty || _url.text.trim().isEmpty) {
            throw Exception('Name and playlist URL are required.');
          }
          await state.addM3uUrl(
            name: _urlName.text.trim(),
            url: _url.text.trim(),
            epgUrl: _urlEpg.text.trim().isEmpty ? null : _urlEpg.text.trim(),
          );
          break;
        case 2:
          if (_fileName.text.trim().isEmpty || _pickedM3u == null || _pickedM3u!.bytes == null) {
            throw Exception('Name and a playlist file are required.');
          }
          await state.addM3uUpload(
            name: _fileName.text.trim(),
            m3uBytes: _pickedM3u!.bytes!,
            m3uFilename: _pickedM3u!.name,
            epgBytes: _pickedEpg?.bytes,
            epgFilename: _pickedEpg?.name,
          );
          break;
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.panel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 8, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Add a playlist', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.accent,
              unselectedLabelColor: AppColors.textDim,
              indicatorColor: AppColors.accent,
              tabs: const [
                Tab(text: 'Xtream login'),
                Tab(text: 'From URL'),
                Tab(text: 'From file'),
              ],
            ),
            const Divider(height: 1),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: SizedBox(
                  height: 300,
                  child: TabBarView(
                    controller: _tabController,
                    children: [_xtreamTab(), _urlTab(), _fileTab()],
                  ),
                ),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    child: Text(_submitting ? 'Adding…' : 'Add playlist'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {bool obscure = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: c,
          obscureText: obscure,
          decoration: InputDecoration(labelText: label),
        ),
      );

  Widget _xtreamTab() => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field(_xtName, 'Playlist name'),
            _field(_xtHost, 'Host URL (http://host:port)'),
            _field(_xtUser, 'Username'),
            _field(_xtPass, 'Password', obscure: true),
            const Text(
              "We'll sign in, pull your live channels and guide automatically.",
              style: TextStyle(fontSize: 12, color: AppColors.textFaint),
            ),
          ],
        ),
      );

  Widget _urlTab() => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field(_urlName, 'Playlist name'),
            _field(_url, 'M3U / M3U8 URL'),
            _field(_urlEpg, 'EPG (XMLTV) URL — optional'),
          ],
        ),
      );

  Widget _fileTab() => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field(_fileName, 'Playlist name'),
            OutlinedButton(onPressed: _pickM3uFile, child: const Text('Choose .m3u file…')),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(_pickedM3u?.name ?? 'No file chosen',
                  style: const TextStyle(fontSize: 12, color: AppColors.textFaint)),
            ),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: _pickEpgFile, child: const Text('Choose .xml guide (optional)…')),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(_pickedEpg?.name ?? 'No file chosen',
                  style: const TextStyle(fontSize: 12, color: AppColors.textFaint)),
            ),
          ],
        ),
      );
}
