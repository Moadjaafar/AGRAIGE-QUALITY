import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../repositories/local_repository.dart';
import 'login_page.dart';
import 'camion_decharge_list_page.dart';
import 'agraige_qualite_list_page.dart';
import 'agraige_moul_list_page.dart';
import 'bateau_list_page.dart';
import 'fournisseur_list_page.dart';
import 'usine_list_page.dart';
import 'export_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final LocalRepository _localRepository = LocalRepository();
  Map<String, int> _dataCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      // Recalculate test counts to ensure accuracy
      await _localRepository.recalculateAllTestCounts();

      final counts = await _localRepository.getDataCounts();
      setState(() {
        _dataCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _logout() {
    AuthService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord - Industrie Poissonnière'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person, color: Colors.blue[700]),
                                const SizedBox(width: 8),
                                Text(
                                  'Bienvenue, ${AuthService.currentUser}!',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Type de Compte: ${AuthService.getUserRole(AuthService.currentUser!)}',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.blue[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aperçu des Données',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 200,
                            child: _buildDataCard(
                              'Déchargements Camion',
                              _dataCounts['camions'] ?? 0,
                              Icons.local_shipping,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 200,
                            child: _buildDataCard(
                              'Tests de Qualité',
                              _dataCounts['qualiteTests'] ?? 0,
                              Icons.science,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 200,
                            child: _buildDataCard(
                              'Tests de Moule',
                              _dataCounts['moulTests'] ?? 0,
                              Icons.straighten,
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 200,
                            child: _buildDataCard(
                              'Enregistrements Non Synchronisés',
                              (_dataCounts['unsyncedCamions'] ?? 0) +
                                  (_dataCounts['unsyncedQualiteTests'] ?? 0) +
                                  (_dataCounts['unsyncedMoulTests'] ?? 0),
                              Icons.sync_problem,
                              Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Actions Rapides',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Column(
                        children: [
                          if (AuthService.hasPermission('read'))
                            ListTile(
                              leading: const Icon(Icons.local_shipping, color: Colors.blue),
                              title: const Text('Déchargements Camion'),
                              subtitle: const Text('Gérer les enregistrements de déchargement de camion'),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const CamionDechargeListPage(),
                                  ),
                                );
                              },
                            ),
                          if (AuthService.hasPermission('read'))
                            ListTile(
                              leading: const Icon(Icons.science, color: Colors.green),
                              title: const Text('Tests de Qualité'),
                              subtitle: const Text('Gérer les enregistrements de tests de qualité du poisson'),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const AgraigeQualiteListPage(),
                                  ),
                                );
                              },
                            ),
                          if (AuthService.hasPermission('read'))
                            ListTile(
                              leading: const Icon(Icons.straighten, color: Colors.orange),
                              title: const Text('Tests de Moule'),
                              subtitle: const Text('Gérer les enregistrements de tests de taille de moule du poisson'),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const AgraigeMoulListPage(),
                                  ),
                                );
                              },
                            ),
                          if (AuthService.hasPermission('write'))
                            ListTile(
                              leading: const Icon(Icons.directions_boat, color: Colors.teal),
                              title: const Text('Gérer les Bateaux'),
                              subtitle: const Text('Ajouter, modifier ou supprimer des bateaux'),
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const BateauListPage(),
                                  ),
                                );
                                _loadDashboardData();
                              },
                            ),
                          if (AuthService.hasPermission('write'))
                            ListTile(
                              leading: const Icon(Icons.business, color: Colors.indigo),
                              title: const Text('Gérer les Fournisseurs'),
                              subtitle: const Text('Ajouter, modifier ou supprimer des fournisseurs'),
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const FournisseurListPage(),
                                  ),
                                );
                                _loadDashboardData();
                              },
                            ),
                          if (AuthService.hasPermission('write'))
                            ListTile(
                              leading: const Icon(Icons.factory, color: Colors.deepOrange),
                              title: const Text('Gérer les Usines'),
                              subtitle: const Text('Ajouter, modifier ou supprimer des usines'),
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const UsineListPage(),
                                  ),
                                );
                                _loadDashboardData();
                              },
                            ),
                          if (AuthService.hasPermission('export'))
                            ListTile(
                              leading: const Icon(Icons.download, color: Colors.purple),
                              title: const Text('Exporter les Données'),
                              subtitle: const Text('Exporter vers Excel et partager via WhatsApp/Gmail'),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const ExportPage(),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDataCard(String title, int count, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}