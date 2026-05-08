import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'realtime_manager.dart';
import 'realtime_status_badge.dart';

class ExampleRealtimeScreen extends StatefulWidget {
  const ExampleRealtimeScreen({super.key});

  @override
  State<ExampleRealtimeScreen> createState() => _ExampleRealtimeScreenState();
}

class _ExampleRealtimeScreenState extends State<ExampleRealtimeScreen> {
  late final RealtimeManager _realtimeManager;
  final List<Map<String, dynamic>> _activities = [];

  @override
  void initState() {
    super.initState();
    _setupRealtime();
  }

  void _setupRealtime() {
    _realtimeManager = RealtimeManager(
      supabase: Supabase.instance.client,
      channelName: 'public:activities',
      onSetupChannel: (channel) {
        // Define your postgres changes here
        channel.onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'activities',
          callback: (payload) {
            if (mounted) {
              setState(() {
                if (payload.newRecord != null) {
                  _activities.insert(0, payload.newRecord!);
                }
              });
            }
          },
        );
      },
    );

    // Start connecting
    _realtimeManager.connect();
  }

  @override
  void dispose() {
    _realtimeManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Activities'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: RealtimeStatusBadge(
                stateStream: _realtimeManager.stateStream,
                onRetry: _realtimeManager.retryNow,
              ),
            ),
          ),
        ],
      ),
      body: _activities.isEmpty
          ? const Center(child: Text('No activities yet. Wait for realtime inserts.'))
          : ListView.builder(
              itemCount: _activities.length,
              itemBuilder: (context, index) {
                final activity = _activities[index];
                return ListTile(
                  title: Text(activity['title']?.toString() ?? 'Unknown Activity'),
                  subtitle: Text(activity['created_at']?.toString() ?? ''),
                );
              },
            ),
    );
  }
}
