import 'package:flutter/material.dart';
import '../models/bateau.dart';
import '../repositories/local_repository.dart';

class BateauFormPage extends StatefulWidget {
  final Bateau? bateau;

  const BateauFormPage({super.key, this.bateau});

  @override
  State<BateauFormPage> createState() => _BateauFormPageState();
}

class _BateauFormPageState extends State<BateauFormPage> {
  final _formKey = GlobalKey<FormState>();
  final LocalRepository _localRepository = LocalRepository();

  late final TextEditingController _nomBateauController;
  late final TextEditingController _descriptionController;

  bool _isLoading = false;

  bool get _isEditing => widget.bateau != null;

  @override
  void initState() {
    super.initState();

    _nomBateauController = TextEditingController(text: widget.bateau?.nomBateau ?? '');
    _descriptionController = TextEditingController(text: widget.bateau?.description ?? '');
  }

  @override
  void dispose() {
    _nomBateauController.dispose();
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
      final nomBateau = _nomBateauController.text.trim();

      // Check if name is unique
      final isUnique = await _localRepository.isBateauNameUnique(
        nomBateau,
        excludeId: widget.bateau?.idBateau,
      );

      if (!isUnique) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A boat with this name already exists'),
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

      final bateau = Bateau(
        idBateau: widget.bateau?.idBateau,
        nomBateau: nomBateau,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        dateCreation: widget.bateau?.dateCreation ?? now,
        dateModification: now,
        isSynced: false,
        serverId: widget.bateau?.serverId,
      );

      if (_isEditing) {
        await _localRepository.updateBateau(widget.bateau!.idBateau!, bateau);
      } else {
        await _localRepository.insertBateau(bateau);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Boat updated successfully'
                  : 'Boat created successfully',
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
        title: Text(_isEditing ? 'Edit Boat' : 'Add New Boat'),
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
                        'Boat Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nomBateauController,
                        decoration: const InputDecoration(
                          labelText: 'Boat Name *',
                          hintText: 'Enter boat name',
                          prefixIcon: Icon(Icons.directions_boat),
                          helperText: 'Must be unique',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Boat name is required';
                          }
                          if (value.trim().length < 2) {
                            return 'Boat name must be at least 2 characters';
                          }
                          if (value.trim().length > 50) {
                            return 'Boat name must be 50 characters or less';
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
