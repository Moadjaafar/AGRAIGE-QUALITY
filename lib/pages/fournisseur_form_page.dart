import 'package:flutter/material.dart';
import '../models/fournisseur.dart';
import '../repositories/local_repository.dart';

class FournisseurFormPage extends StatefulWidget {
  final Fournisseur? fournisseur;

  const FournisseurFormPage({super.key, this.fournisseur});

  @override
  State<FournisseurFormPage> createState() => _FournisseurFormPageState();
}

class _FournisseurFormPageState extends State<FournisseurFormPage> {
  final _formKey = GlobalKey<FormState>();
  final LocalRepository _localRepository = LocalRepository();

  late final TextEditingController _nomFournisseurController;
  late final TextEditingController _descriptionController;

  bool _isLoading = false;

  bool get _isEditing => widget.fournisseur != null;

  @override
  void initState() {
    super.initState();

    _nomFournisseurController = TextEditingController(text: widget.fournisseur?.nomFournisseur ?? '');
    _descriptionController = TextEditingController(text: widget.fournisseur?.description ?? '');
  }

  @override
  void dispose() {
    _nomFournisseurController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final nomFournisseur = _nomFournisseurController.text.trim();

      // Check if name is unique
      final isUnique = await _localRepository.isFournisseurNameUnique(
        nomFournisseur,
        excludeId: widget.fournisseur?.idFournisseur,
      );

      if (!isUnique) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A supplier with this name already exists'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      final now = DateTime.now();

      final fournisseur = Fournisseur(
        idFournisseur: widget.fournisseur?.idFournisseur,
        nomFournisseur: nomFournisseur,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        dateCreation: widget.fournisseur?.dateCreation ?? now,
        dateModification: now,
        isSynced: false,
        serverId: widget.fournisseur?.serverId,
      );

      if (_isEditing) {
        await _localRepository.updateFournisseur(widget.fournisseur!.idFournisseur!, fournisseur);
      } else {
        await _localRepository.insertFournisseur(fournisseur);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Supplier updated successfully'
                  : 'Supplier created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Supplier' : 'Add New Supplier'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text(
                'SAVE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
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
                      Text(
                        'Supplier Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nomFournisseurController,
                        decoration: const InputDecoration(
                          labelText: 'Supplier Name *',
                          hintText: 'Enter supplier name',
                          prefixIcon: Icon(Icons.business),
                          helperText: 'Must be unique',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Supplier name is required';
                          }
                          if (value.trim().length < 2) {
                            return 'Supplier name must be at least 2 characters';
                          }
                          if (value.trim().length > 50) {
                            return 'Supplier name must be 50 characters or less';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter description (optional)',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        maxLength: 200,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _isEditing ? 'UPDATE BOAT' : 'CREATE BOAT',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
