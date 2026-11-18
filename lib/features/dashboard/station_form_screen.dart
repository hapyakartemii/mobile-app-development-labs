import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';
import 'package:flutter_lab1/domain/validation/validators.dart';
import 'package:flutter_lab1/features/shared/widgets/app_button.dart';
import 'package:flutter_lab1/features/shared/widgets/app_text_field.dart';
import 'package:flutter_lab1/features/shared/widgets/page_body.dart';

/// Create (no [initial]) or edit a station.
/// Returns a valid [StationDraft] via `Navigator.pop`; saving is done by
/// the dashboard, which owns the list.
class StationFormScreen extends StatefulWidget {
  const StationFormScreen({super.key, this.initial});

  final WeatherStation? initial;

  @override
  State<StationFormScreen> createState() => _StationFormScreenState();
}

class _StationFormScreenState extends State<StationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _location = TextEditingController(text: widget.initial?.location);

  bool get _isEditing => widget.initial != null;

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(
      context,
      StationDraft(name: _name.text, location: _location.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редагувати станцію' : 'Нова станція'),
      ),
      body: PageBody(
        maxWidth: 600,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.m,
            children: [
              AppTextField(
                label: 'Назва',
                hint: 'Наприклад, Двір',
                icon: Icons.sensors,
                controller: _name,
                validator: Validators.stationName,
              ),
              AppTextField(
                label: 'Розташування',
                hint: 'Місто, район',
                icon: Icons.place_outlined,
                controller: _location,
                validator: Validators.location,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: AppSpacing.s),
              AppButton(
                label: _isEditing ? 'Зберегти зміни' : 'Додати станцію',
                icon: _isEditing ? Icons.save_outlined : Icons.add,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
