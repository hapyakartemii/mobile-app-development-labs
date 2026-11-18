import 'package:flutter/material.dart';

/// Row with an icon, a label and a value (profile data, station details).
class InfoTile extends StatelessWidget {
  const InfoTile({
    required this.icon,
    required this.label,
    super.key,
    this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = value;

    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      subtitle: text == null ? null : Text(text),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
