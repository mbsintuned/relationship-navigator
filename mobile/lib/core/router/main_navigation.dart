import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Main navigation wrapper with bottom navigation bar
class MainNavigation extends StatefulWidget {
  final Widget child;

  const MainNavigation({
    super.key,
    required this.child,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.people_outline),
      selectedIcon: Icon(Icons.people),
      label: 'Profiles',
    ),
    NavigationDestination(
      icon: Icon(Icons.psychology_outlined),
      selectedIcon: Icon(Icons.psychology),
      label: 'Assessments',
    ),
    NavigationDestination(
      icon: Icon(Icons.lightbulb_outline),
      selectedIcon: Icon(Icons.lightbulb),
      label: 'Insights',
    ),
    NavigationDestination(
      icon: Icon(Icons.task_outlined),
      selectedIcon: Icon(Icons.task),
      label: 'Tasks',
    ),
  ];

  final List<String> _routes = [
    '/',
    '/profiles',
    '/assessments',
    '/insights',
    '/tasks',
  ];

  @override
  Widget build(BuildContext context) {
    // Update selected index based on current route
    final location = GoRouterState.of(context).location;
    for (int i = 0; i < _routes.length; i++) {
      if (location.startsWith(_routes[i]) && _routes[i] != '/') {
        if (_selectedIndex != i) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _selectedIndex = i;
              });
            }
          });
        }
        break;
      } else if (location == '/' && i == 0) {
        if (_selectedIndex != 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _selectedIndex = 0;
              });
            }
          });
        }
        break;
      }
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          context.go(_routes[index]);
        },
        destinations: _destinations,
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

/// Custom bottom navigation bar with more advanced features
class AdvancedBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<BottomNavigationDestination> destinations;

  const AdvancedBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.bottomNavigationBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: destinations.asMap().entries.map((entry) {
              final index = entry.key;
              final destination = entry.value;
              final isSelected = index == selectedIndex;
              
              return Expanded(
                child: _NavigationBarItem(
                  destination: destination,
                  isSelected: isSelected,
                  onTap: () => onDestinationSelected(index),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class BottomNavigationDestination {
  final Widget icon;
  final Widget? selectedIcon;
  final String label;
  final String? tooltip;
  final int? badgeCount;

  const BottomNavigationDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.tooltip,
    this.badgeCount,
  });
}

class _NavigationBarItem extends StatelessWidget {
  final BottomNavigationDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavigationBarItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final Color selectedColor = colorScheme.primary;
    final Color unselectedColor = colorScheme.onSurfaceVariant.withOpacity(0.6);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? selectedColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconTheme(
                    data: IconThemeData(
                      color: isSelected ? selectedColor : unselectedColor,
                      size: 24,
                    ),
                    child: isSelected && destination.selectedIcon != null
                        ? destination.selectedIcon!
                        : destination.icon,
                  ),
                ),
                
                // Badge
                if (destination.badgeCount != null && destination.badgeCount! > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        destination.badgeCount! > 99 
                            ? '99+' 
                            : destination.badgeCount.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onError,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: theme.textTheme.bodySmall!.copyWith(
                color: isSelected ? selectedColor : unselectedColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
              child: Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating Action Button for the main navigation
class MainNavigationFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? tooltip;
  final Widget? child;

  const MainNavigationFAB({
    super.key,
    this.onPressed,
    this.tooltip,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip ?? 'Add',
      child: child ?? const Icon(Icons.add),
    );
  }
}

/// Navigation rail for tablet/desktop layouts
class MainNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationRailDestination> destinations;
  final bool extended;

  const MainNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.extended = false,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      extended: extended,
      destinations: destinations,
    );
  }
}

/// Responsive navigation that adapts to screen size
class ResponsiveNavigation extends StatelessWidget {
  final Widget child;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;

  const ResponsiveNavigation({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 768) {
          // Tablet/Desktop: Use navigation rail
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  extended: constraints.maxWidth >= 1024,
                  destinations: destinations
                      .map((d) => NavigationRailDestination(
                            icon: d.icon,
                            selectedIcon: d.selectedIcon,
                            label: Text(d.label),
                          ))
                      .toList(),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: child),
              ],
            ),
          );
        } else {
          // Mobile: Use bottom navigation
          return Scaffold(
            body: child,
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: destinations,
            ),
          );
        }
      },
    );
  }
}
