import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/project.dart';
import '../screens/home_screen.dart';
import '../screens/auth/login_screen.dart';
import '../services/auth_service.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Projects',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshData(context),
            tooltip: 'Refresh Projects',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Projects Yet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first budget project to get started',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateProjectDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Project'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header with project count
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Row(
                  children: [
                    Icon(
                      Icons.folder,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${provider.projects.length} Project${provider.projects.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _showCreateProjectDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('New'),
                    ),
                  ],
                ),
              ),
              
              // Projects list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.projects.length,
                  itemBuilder: (context, index) {
                    final project = provider.projects[index];
                    final isSelected = provider.currentProject?.id == project.id;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: isSelected ? 4 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isSelected
                            ? BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              )
                            : BorderSide.none,
                      ),
                      child: InkWell(
                        onTap: () => _selectProject(context, project),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: project.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      project.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Current',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) => _handleProjectAction(context, value, project),
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'duplicate',
                                        child: Row(
                                          children: [
                                            Icon(Icons.copy),
                                            SizedBox(width: 8),
                                            Text('Duplicate'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Delete', style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                project.description,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Budget: UGX ${project.totalBudget.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDate(project.createdAt),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateProjectDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _selectProject(BuildContext context, Project project) async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Loading project...'),
          ],
        ),
      ),
    );

    try {
      await provider.selectProject(project);
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to home screen
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load project: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreateProjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    Color selectedColor = Colors.blue;
    double budgetAmount = 0; // Start with 0 UGX

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Project'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Project Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: budgetAmount.toStringAsFixed(0),
                  decoration: const InputDecoration(
                    labelText: 'Initial Budget (UGX)',
                    border: OutlineInputBorder(),
                    prefixText: 'UGX ',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    budgetAmount = double.tryParse(value) ?? budgetAmount;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Project Color:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                    Colors.red,
                    Colors.teal,
                    Colors.pink,
                    Colors.indigo,
                  ].map((color) {
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: selectedColor == color
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a project name')),
                  );
                  return;
                }

                final project = Project(
                  id: '',
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  createdAt: DateTime.now(),
                  color: selectedColor,
                  totalBudget: budgetAmount,
                  currentBalance: budgetAmount,
                );

                final provider = Provider.of<AppProvider>(context, listen: false);
                await provider.createProject(project);

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Project created successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleProjectAction(BuildContext context, String action, Project project) {
    switch (action) {
      case 'edit':
        _showEditProjectDialog(context, project);
        break;
      case 'duplicate':
        _duplicateProject(context, project);
        break;
      case 'delete':
        _showDeleteProjectDialog(context, project);
        break;
    }
  }

  void _showEditProjectDialog(BuildContext context, Project project) {
    final nameController = TextEditingController(text: project.name);
    final descriptionController = TextEditingController(text: project.description);
    Color selectedColor = project.color;
    double budgetAmount = project.totalBudget;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Project'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Project Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: budgetAmount.toStringAsFixed(0),
                  decoration: const InputDecoration(
                    labelText: 'Total Budget (UGX)',
                    border: OutlineInputBorder(),
                    prefixText: 'UGX ',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    budgetAmount = double.tryParse(value) ?? budgetAmount;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Project Color:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                    Colors.red,
                    Colors.teal,
                    Colors.pink,
                    Colors.indigo,
                  ].map((color) {
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: selectedColor == color
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a project name')),
                  );
                  return;
                }

                final updatedProject = project.copyWith(
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  color: selectedColor,
                  totalBudget: budgetAmount,
                  lastModified: DateTime.now(),
                );

                final provider = Provider.of<AppProvider>(context, listen: false);
                await provider.updateProject(updatedProject);

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Project updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _duplicateProject(BuildContext context, Project project) async {
    final duplicatedProject = Project(
      id: '',
      name: '${project.name} (Copy)',
      description: project.description,
      createdAt: DateTime.now(),
      color: project.color,
      totalBudget: project.totalBudget,
      currentBalance: project.currentBalance,
    );

    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.createProject(duplicatedProject);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project duplicated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showDeleteProjectDialog(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${project.name}"?'),
            const SizedBox(height: 8),
            const Text(
              'This will permanently delete all categories, transactions, and data associated with this project.',
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<AppProvider>(context, listen: false);
              await provider.deleteProject(project.id);

              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Project deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _refreshData(BuildContext context) async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 16),
              Text('Refreshing projects...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      await provider.reloadData();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Projects refreshed successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh projects: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Logging out...'),
            ],
          ),
        ),
      );

      await AuthService.signOut();

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(initialMode: LoginMode.signIn),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
