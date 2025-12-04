import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/home_model.dart';
import '../../providers/home_provider.dart';
import '../../core/platform_channel/home_channel.dart';

class HomeDetailView extends StatefulWidget {
  final HomeModel home;

  const HomeDetailView({Key? key, required this.home}) : super(key: key);

  @override
  State<HomeDetailView> createState() => _HomeDetailViewState();
}

class _HomeDetailViewState extends State<HomeDetailView> {
  bool _isLoading = false;
  HomeModel? _detailedHome;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHomeDetails();
  }

  Future<void> _loadHomeDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await HomeChannel.getHomeDetail(
        homeId: widget.home.homeId,
      );
      setState(() {
        _detailedHome = HomeModel.fromJson(result);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final home = _detailedHome ?? widget.home;

    return Scaffold(
      appBar: AppBar(
        title: Text(home.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHomeDetails,
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 8),
                    Text('Rename'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                _showRenameDialog();
              } else if (value == 'delete') {
                _showDeleteConfirmation();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorView()
          : _buildContent(home),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error: $_errorMessage',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadHomeDetails,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(HomeModel home) {
    return RefreshIndicator(
      onRefresh: _loadHomeDetails,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Home Header Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(
                        Icons.home,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      home.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (home.geoName.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            home.geoName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (home.isAdmin) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.admin_panel_settings,
                              size: 16,
                              color: Colors.green,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Administrator',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Statistics Section
            const Text(
              'Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.meeting_room,
                    label: 'Rooms',
                    value: home.roomCount.toString(),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.devices,
                    label: 'Devices',
                    value: home.deviceCount.toString(),
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            if (home.groupCount != null) ...[
              const SizedBox(height: 12),
              _buildStatCard(
                icon: Icons.group_work,
                label: 'Groups',
                value: home.groupCount.toString(),
                color: Colors.purple,
              ),
            ],
            const SizedBox(height: 24),

            // Location Section
            if (home.latitude != 0.0 || home.longitude != 0.0) ...[
              const Text(
                'Location',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.my_location),
                  title: const Text('Coordinates'),
                  subtitle: Text(
                    'Lat: ${home.latitude.toStringAsFixed(6)}\n'
                    'Lng: ${home.longitude.toStringAsFixed(6)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.map),
                    onPressed: () {
                      // TODO: Open in maps
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Open in maps - Coming soon'),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Home ID Section
            const Text(
              'Home Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.fingerprint),
                title: const Text('Home ID'),
                subtitle: Text(home.homeId.toString()),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    // TODO: Copy to clipboard
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Home ID copied to clipboard'),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to devices
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Devices - Coming soon')),
                  );
                },
                icon: const Icon(Icons.devices),
                label: const Text('View Devices'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Navigate to rooms
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rooms - Coming soon')),
                  );
                },
                icon: const Icon(Icons.meeting_room),
                label: const Text('Manage Rooms'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog() {
    final controller = TextEditingController(text: widget.home.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Home'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Home Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                Navigator.pop(context);
                final success = await context
                    .read<HomeProvider>()
                    .updateHomeName(widget.home.homeId, newName);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Home renamed successfully')),
                  );
                  _loadHomeDetails();
                }
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Home'),
        content: Text('Are you sure you want to delete "${widget.home.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<HomeProvider>().deleteHome(
                widget.home.homeId,
              );
              if (success && mounted) {
                Navigator.pop(context); // Go back to home list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Home deleted successfully')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
