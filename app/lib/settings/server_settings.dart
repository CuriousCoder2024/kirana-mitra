import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_provider.dart';
import '../api/dio_api_client.dart';

/// Runtime override for the backend base URL, so a built APK can be pointed
/// at another server (laptop on Wi-Fi, Cloud Run) without a rebuild.
///
/// Stored in shared_preferences under [prefKey]. [DioApiClient] reads it via
/// [ServerSettings.load] before falling back to the `API_BASE_URL`
/// dart-define. Reached by long-pressing the title on the onboarding screen.
abstract final class ServerSettings {
  static const prefKey = 'server_url';

  /// The saved override, or null when the build default should be used.
  static Future<String?> load() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getString(prefKey)?.trim();
    return (v == null || v.isEmpty) ? null : v;
  }

  static Future<void> save(String? url) async {
    final p = await SharedPreferences.getInstance();
    final v = url?.trim() ?? '';
    if (v.isEmpty) {
      await p.remove(prefKey);
    } else {
      await p.setString(prefKey, v);
    }
  }

  /// Accepts `http(s)://host[:port][/path]`, nothing else.
  static String? validate(String? raw) {
    final v = (raw ?? '').trim();
    if (v.isEmpty) return null; // empty = use the build default
    final uri = Uri.tryParse(v);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      return 'Use http://host:port';
    }
    return null;
  }
}

/// Opens the Server sheet. Saving re-runs the startup health check so the
/// app switches between live and mock for the new URL.
Future<void> showServerSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _ServerSheet(),
  );
}

class _ServerSheet extends ConsumerStatefulWidget {
  const _ServerSheet();

  @override
  ConsumerState<_ServerSheet> createState() => _ServerSheetState();
}

class _ServerSheetState extends ConsumerState<_ServerSheet> {
  final _ctrl = TextEditingController();
  String? _error;
  String? _status;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    ServerSettings.load().then((v) {
      if (mounted) setState(() => _ctrl.text = v ?? '');
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _effectiveUrl =>
      _ctrl.text.trim().isEmpty ? DioApiClient.defaultBaseUrl() : _ctrl.text.trim();

  Future<void> _test() async {
    final err = ServerSettings.validate(_ctrl.text);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _status = 'Checking $_effectiveUrl ...';
    });
    final ok = await DioApiClient(baseUrl: _effectiveUrl).healthz();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _status = ok ? 'Server OK (live)' : 'No reply: app will use the demo mock';
    });
  }

  Future<void> _save() async {
    final err = ServerSettings.validate(_ctrl.text);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    await ServerSettings.save(_ctrl.text);
    if (!mounted) return;
    // Close the sheet first: re-resolving live vs mock rebuilds the app root
    // (splash, then back to onboarding), which disposes this sheet.
    final container = ProviderScope.containerOf(context);
    Navigator.of(context).pop();
    container.invalidate(apiClientFutureProvider);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Server', style: text.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Backend address. Leave empty for the build default '
            '(${DioApiClient.defaultBaseUrl()}).',
            style: text.bodySmall,
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('server_url_field'),
            controller: _ctrl,
            keyboardType: TextInputType.url,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            onChanged: (_) => setState(() {
              _error = null;
              _status = null;
            }),
            decoration: InputDecoration(
              labelText: 'Base URL',
              hintText: 'http://192.168.1.23:8080',
              prefixIcon: const Icon(Icons.dns_outlined),
              errorText: _error,
              suffixIcon: _ctrl.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() {
                        _ctrl.clear();
                        _error = null;
                        _status = null;
                      }),
                    ),
            ),
          ),
          if (_status != null) ...[
            const SizedBox(height: 10),
            Text(_status!, style: text.bodySmall),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : _test,
                  child: const Text('Test'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  key: const Key('server_url_save'),
                  onPressed: _busy ? null : _save,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
