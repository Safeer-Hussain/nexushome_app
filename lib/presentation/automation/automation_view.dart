import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_feedback.dart';
import '../providers/security_provider.dart';
import 'widgets/scenes_tab.dart';
import 'widgets/security_sentinel_tab.dart';
import 'widgets/create_rule_sheet.dart';

class AutomationView extends ConsumerStatefulWidget {
  const AutomationView({super.key});

  @override
  ConsumerState<AutomationView> createState() => _AutomationViewState();
}

class _AutomationViewState extends ConsumerState<AutomationView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final fab = _tabController.index == 0
        ? FloatingActionButton.extended(
            heroTag: 'fab_create_automation_rule', // CRITICAL: Unique Hero Tag
            icon: const Icon(Icons.add_rounded),
            label: const Text('New Rule'),
            onPressed: () => CreateRuleSheet.show(context),
          )
        : FloatingActionButton.extended(
            heroTag: 'fab_security_arm_all', // CRITICAL: Unique Hero Tag
            icon: const Icon(Icons.security_rounded),
            label: const Text('Arm All Zones'),
            onPressed: () {
              ref.read(securityModeProvider.notifier).state = 'Armed Away';
              AppFeedback.showSuccess(context, 'All zones armed away.');
            },
          );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: colorScheme.surfaceContainer,
          child: TabBar(
            controller: _tabController,
            indicatorColor: colorScheme.primary,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            tabs: const [
              Tab(
                icon: Icon(Icons.auto_mode_rounded, size: 18),
                text: 'Scenes & Rules',
              ),
              Tab(
                icon: Icon(Icons.security_rounded, size: 18),
                text: 'Security Sentinel',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: fab,
      body: TabBarView(
        controller: _tabController,
        children: const [ScenesTab(), SecuritySentinelTab()],
      ),
    );
  }
}
