import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/camion_decharge.dart';
import '../repositories/local_repository.dart';
import '../services/auth_service.dart';
import 'camion_decharge_form_page.dart';

class CamionDechargeListPage extends StatefulWidget {
  const CamionDechargeListPage({super.key});

  @override
  State<CamionDechargeListPage> createState() => _CamionDechargeListPageState();
}

class _CamionDechargeListPageState extends State<CamionDechargeListPage> {
  final LocalRepository _localRepository = LocalRepository();
  List<CamionDecharge> _camions = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCamions();
  }

  Future<void> _loadCamions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final camions = await _localRepository.getAllCamionDecharges();
      setState(() {
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

  List<CamionDecharge> get _filteredCamions {
    if (_searchQuery.isEmpty) {
      return _camions;
    }
    return _camions.where((camion) {
      return camion.matCamion.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (camion.bateau?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (camion.maree?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  Future<void> _deleteCamion(CamionDecharge camion) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Êtes-vous sûr de vouloir supprimer le déchargement camion "${camion.matCamion}"?\n\nCela supprimera également tous les tests de qualité et de moule associés.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _localRepository.deleteCamionDecharge(camion.idDecharge!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Déchargement camion supprimé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          _loadCamions();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _navigateToForm([CamionDecharge? camion]) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => CamionDechargeFormPage(camion: camion),
      ),
    );

    if (result == true) {
      _loadCamions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Déchargements Camion'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          if (AuthService.hasPermission('write'))
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _navigateToForm(),
              tooltip: 'Ajouter un Nouveau Déchargement',
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Rechercher par camion, bateau ou marée...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCamions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_shipping_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Aucun déchargement de camion trouvé'
                                  : 'Aucun résultat pour "$_searchQuery"',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            if (AuthService.hasPermission('write') && _searchQuery.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: ElevatedButton.icon(
                                  onPressed: () => _navigateToForm(),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Ajouter le Premier Déchargement'),
                                ),
                              ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadCamions,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _filteredCamions.length,
                          itemBuilder: (context, index) {
                            final camion = _filteredCamions[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: camion.isExported ? Colors.green : Colors.orange,
                                  child: Icon(
                                    Icons.local_shipping,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  camion.matCamion,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (camion.bateau != null)
                                      Text('Boat: ${camion.bateau}'),
                                    if (camion.maree != null)
                                      Text('Tide: ${camion.maree}'),
                                    if (camion.temperature != null)
                                      Text('Temperature: ${camion.temperature}°C'),
                                    Text(
                                      'Created: ${DateFormat('MMM dd, yyyy HH:mm').format(camion.dateCreation)}',
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
                                    if (!camion.isSynced)
                                      Icon(
                                        Icons.sync_problem,
                                        color: Colors.orange,
                                        size: 16,
                                      ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        switch (value) {
                                          case 'view':
                                            _showDetails(camion);
                                            break;
                                          case 'edit':
                                            if (AuthService.hasPermission('write')) {
                                              _navigateToForm(camion);
                                            }
                                            break;
                                          case 'delete':
                                            if (AuthService.hasPermission('delete')) {
                                              _deleteCamion(camion);
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
                                onTap: () => _showDetails(camion),
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

  void _showDetails(CamionDecharge camion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Truck Discharge Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Truck Registration', camion.matCamion),
              _buildDetailRow('Boat', camion.bateau ?? 'Not specified'),
              _buildDetailRow('Tide', camion.maree ?? 'Not specified'),
              _buildDetailRow(
                'Discharge Time',
                camion.heureDecharge != null
                    ? DateFormat('MMM dd, yyyy HH:mm').format(camion.heureDecharge!)
                    : 'Not specified',
              ),
              _buildDetailRow(
                'Treatment Time',
                camion.heureTraitement != null
                    ? DateFormat('MMM dd, yyyy HH:mm').format(camion.heureTraitement!)
                    : 'Not specified',
              ),
              _buildDetailRow(
                'Temperature',
                camion.temperature != null ? '${camion.temperature}°C' : 'Not measured',
              ),
              _buildDetailRow(
                'Quality Tests Count',
                camion.nbrAgraigeQualite?.toString() ?? '0',
              ),
              _buildDetailRow(
                'Mold Tests Count',
                camion.nbrAgraigeMoule?.toString() ?? '0',
              ),
              _buildDetailRow('Exported', camion.isExported ? 'Yes' : 'No'),
              _buildDetailRow('Synced', camion.isSynced ? 'Yes' : 'No'),
              _buildDetailRow(
                'Created',
                DateFormat('MMM dd, yyyy HH:mm').format(camion.dateCreation),
              ),
              _buildDetailRow(
                'Modified',
                DateFormat('MMM dd, yyyy HH:mm').format(camion.dateModification),
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
                _navigateToForm(camion);
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