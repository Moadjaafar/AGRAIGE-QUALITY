import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/agraige_moul_tests.dart';
import '../models/camion_decharge.dart';
import '../repositories/local_repository.dart';
import '../services/auth_service.dart';
import 'agraige_moul_form_page.dart';

class AgraigeMoulListPage extends StatefulWidget {
  const AgraigeMoulListPage({super.key});

  @override
  State<AgraigeMoulListPage> createState() => _AgraigeMoulListPageState();
}

class _AgraigeMoulListPageState extends State<AgraigeMoulListPage> {
  final LocalRepository _localRepository = LocalRepository();
  List<AgraigeMoulTests> _moulTests = [];
  List<CamionDecharge> _camions = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int? _selectedCamionFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tests = await _localRepository.getAllMoulTests();
      final camions = await _localRepository.getAllCamionDecharges();
      setState(() {
        _moulTests = tests;
        _camions = camions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<AgraigeMoulTests> get _filteredTests {
    var filtered = _moulTests;

    if (_selectedCamionFilter != null) {
      filtered = filtered.where((test) => test.idCamionDecharge == _selectedCamionFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((test) {
        final camion = _camions.firstWhere(
          (c) => c.idDecharge == test.idCamionDecharge,
          orElse: () => CamionDecharge(
            matCamion: 'Unknown',
            dateCreation: DateTime.now(),
            dateModification: DateTime.now(),
          ),
        );
        return camion.matCamion.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            test.id.toString().contains(_searchQuery);
      }).toList();
    }

    return filtered;
  }

  Future<void> _deleteTest(AgraigeMoulTests test) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this mold test?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _localRepository.deleteMoulTest(test.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mold test deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _navigateToForm([AgraigeMoulTests? test]) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AgraigeMoulFormPage(test: test),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  String _getCamionName(int camionId) {
    try {
      final camion = _camions.firstWhere((c) => c.idDecharge == camionId);
      return camion.matCamion;
    } catch (e) {
      return 'Unknown Truck';
    }
  }

  String _getTopSizes(AgraigeMoulTests test) {
    final distribution = test.sizeDistribution;
    final sorted = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top = sorted.take(3).where((e) => e.value > 0);
    if (top.isEmpty) return 'No data';

    return top.map((e) => '${e.key}: ${e.value}').join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mold Tests'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        actions: [
          if (AuthService.hasPermission('write'))
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _navigateToForm(),
              tooltip: 'Add New Mold Test',
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search by truck or test ID...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int?>(
                  decoration: const InputDecoration(
                    labelText: 'Filter by Truck',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_shipping),
                  ),
                  value: _selectedCamionFilter,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('All Trucks'),
                    ),
                    ..._camions.map((camion) => DropdownMenuItem<int?>(
                      value: camion.idDecharge,
                      child: Text(camion.matCamion),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCamionFilter = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTests.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.straighten_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty && _selectedCamionFilter == null
                                  ? 'No mold tests found'
                                  : 'No results found',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            if (AuthService.hasPermission('write') &&
                                _searchQuery.isEmpty &&
                                _selectedCamionFilter == null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: ElevatedButton.icon(
                                  onPressed: () => _navigateToForm(),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add First Mold Test'),
                                ),
                              ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _filteredTests.length,
                          itemBuilder: (context, index) {
                            final test = _filteredTests[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: test.isSynced ? Colors.orange : Colors.grey,
                                  child: Icon(
                                    Icons.straighten,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  'Test #${test.id} - ${_getCamionName(test.idCamionDecharge)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total Quantity: ${test.totalQuantity}'),
                                    Text('Top sizes: ${_getTopSizes(test)}'),
                                    Text(
                                      'Created: ${DateFormat('MMM dd, yyyy HH:mm').format(test.dateCreation)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!test.isSynced)
                                      Icon(
                                        Icons.sync_problem,
                                        color: Colors.orange,
                                        size: 16,
                                      ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        switch (value) {
                                          case 'view':
                                            _showDetails(test);
                                            break;
                                          case 'edit':
                                            if (AuthService.hasPermission('write')) {
                                              _navigateToForm(test);
                                            }
                                            break;
                                          case 'delete':
                                            if (AuthService.hasPermission('delete')) {
                                              _deleteTest(test);
                                            }
                                            break;
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'view',
                                          child: ListTile(
                                            leading: Icon(Icons.visibility),
                                            title: Text('View Details'),
                                          ),
                                        ),
                                        if (AuthService.hasPermission('write'))
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: ListTile(
                                              leading: Icon(Icons.edit),
                                              title: Text('Edit'),
                                            ),
                                          ),
                                        if (AuthService.hasPermission('delete'))
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: ListTile(
                                              leading: Icon(Icons.delete, color: Colors.red),
                                              title: Text('Delete'),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                onTap: () => _showDetails(test),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showDetails(AgraigeMoulTests test) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mold Test #${test.id} Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Truck', _getCamionName(test.idCamionDecharge)),
              const Divider(),
              Text(
                'Size Distribution',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ...test.sizeDistribution.entries.map((entry) =>
                _buildDetailRow(entry.key, entry.value.toString())),
              const Divider(),
              _buildDetailRow('Total Quantity', test.totalQuantity.toString()),
              _buildDetailRow('Synced', test.isSynced ? 'Yes' : 'No'),
              _buildDetailRow(
                'Created',
                DateFormat('MMM dd, yyyy HH:mm').format(test.dateCreation),
              ),
              _buildDetailRow(
                'Modified',
                DateFormat('MMM dd, yyyy HH:mm').format(test.dateModification),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (AuthService.hasPermission('write'))
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToForm(test);
              },
              child: const Text('Edit'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}