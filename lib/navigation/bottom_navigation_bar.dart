import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/pages/home/home_page.dart';
import 'package:acs_upb_mobile/pages/people/view/people_page.dart';
import 'package:acs_upb_mobile/pages/planner/view/planner_page.dart';
import 'package:acs_upb_mobile/pages/portal/view/portal_page.dart';
import 'package:acs_upb_mobile/pages/timetable/view/timetable_page.dart';
import 'package:flutter/material.dart';

class AppBottomNavigationBar extends StatefulWidget {
  const AppBottomNavigationBar({this.tabIndex = 0});

  final int tabIndex;

  @override
  _AppBottomNavigationBarState createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar>
    with TickerProviderStateMixin {
  List<Widget> tabs;
  TabController tabController;
  final PageStorageBucket bucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 5);
    tabs = [
      HomePage(key: const PageStorageKey('Home'), tabController: tabController),
      const TimetablePage(), // Cannot preserve state with PageStorageKey
      const PortalPage(key: PageStorageKey('Portal')),
      const PeoplePage(key: PageStorageKey('People')),
      const PlannerPage(key: PageStorageKey('Planner')),
    ];
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      initialIndex: widget.tabIndex,
      child: Scaffold(
        body: PageStorage(
          child: TabBarView(controller: tabController, children: tabs),
          bucket: bucket,
        ),
        bottomNavigationBar: SafeArea(
          child: SizedBox(
            height: 45,
            child: TabBar(
              controller: tabController,
              tabs: [
                Tab(
                  icon: const Icon(Icons.home),
                  text: S.of(context).navigationHome,
                  iconMargin: EdgeInsets.zero,
                ),
                Tab(
                  icon: const Icon(Icons.calendar_today_rounded),
                  text: S.of(context).navigationTimetable,
                  iconMargin: EdgeInsets.zero,
                ),
                Tab(
                  icon: const Icon(Icons.public),
                  text: S.of(context).navigationPortal,
                  iconMargin: EdgeInsets.zero,
                ),
                Tab(
                  icon: const Icon(Icons.people),
                  text: S.of(context).navigationPeople,
                  iconMargin: EdgeInsets.zero,
                ),
                Tab(
                  icon: const Icon(Icons.analytics_rounded),
                  text: S.of(context).navigationPlanner,
                  iconMargin: EdgeInsets.zero,
                ),
              ],
              labelColor: Theme.of(context).accentColor,
              labelPadding: EdgeInsets.zero,
              indicatorPadding: EdgeInsets.zero,
              unselectedLabelColor: Theme.of(context).unselectedWidgetColor,
              indicatorColor: Theme.of(context).accentColor,
            ),
          ),
        ),
      ),
    );
  }
}
