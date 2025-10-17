import 'package:flutter/material.dart';
import '../models/usine.dart';
import '../repositories/local_repository.dart';

class UsineFormPage extends StatefulWidget {
  final Usine? usine;

  const UsineFormPage({super.key, this.usine});

  @override
  State<UsineFormPage> createState() => _UsineFormPageState();
}

class _UsineFormPageState extends State<UsineFormPage> {
  final _formKey = GlobalKey<FormState>();
  final LocalRepository _localRepository = LocalRepository();

  late final TextEditingController _nomUsineController;
  late final TextEditingController _adresseController;
  late final TextEditingController _descriptionController;

  bool _isLoading = false;

  bool get _isEditing => widget.usine != null;

  @override
  void initState() {
    super.initState();

    _nomUsineController = TextEditingController(text: widget.usine?.nomUsine ?? '');
    _adresseController = TextEditingController(text: widget.usine?.adresse ?? '');
    _descriptionController = TextEditingController(text: widget.usine?.description ?? '');
  }

  @override
  void dispose() {
    _nomUsineController.dispose();
    _adresseController.dispose();
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
      final nomUsine = _nomUsineController.text.trim();

      // Check if name is unique
      final isUnique = await _localRepository.isUsineNameUnique(
        nomUsine,
        excludeId: widget.usine?.idUsine,
      );

      if (!isUnique) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A factory with this name already exists'),
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

      final usine = Usine(
        idUsine: widget.usine?.idUsine,
        nomUsine: nomUsine,
        adresse: _adresseController.text.trim().isEmpty
            ? null
            : _adresseController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        dateCreation: widget.usine?.dateCreation ?? now,
        dateModification: now,
        isSynced: false,
        serverId: widget.usine?.serverId,
      );

      if (_isEditing) {
        await _localRepository.updateUsine(widget.usine!.idUsine!, usine);
      } else {
        await _localRepository.insertUsine(usine);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Factory updated successfully'
                  : 'Factory created successfully',
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
        title: Text(_isEditing ? 'Edit Factory' : 'Add New Factory'),
        backgroundColor: Colors.orange[700],
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
                        'Factory Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nomUsineController,
                        decoration: const InputDecoration(
                          labelText: 'Factory Name *',
                          hintText: 'Enter factory name',
                          prefixIcon: Icon(Icons.factory),
                          helperText: 'Must be unique',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Factory name is required';
                          }
                          if (value.trim().length < 2) {
                            return 'Factory name must be at least 2 characters';
                          }
                          if (value.trim().length > 50) {
                            return 'Factory name must be 50 characters or less';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _adresseController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          hintText: 'Enter factory address (optional)',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        maxLines: 2,
                        maxLength: 200,
                        textCapitalization: TextCapitalization.sentences,
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
                    backgroundColor: Colors.orange[700],
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
                          _isEditing ? 'UPDATE FACTORY' : 'CREATE FACTORY',
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
