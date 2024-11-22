import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_project_berry/src/blocs/timer_bloc.dart';
import 'package:iot_project_berry/src/config/palette.dart';
import 'package:iot_project_berry/src/screens/screen_doorLock_temporarypassword.dart';
import 'package:iot_project_berry/src/screens/screen_home.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}


class _MainTabViewState extends State<MainTabView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TimerBloc _mainTimerBloc;
  late TimerBloc _tempTimerBloc;
  int _index = 0;

  @override
  void initState() {
    _tabController = TabController(length: _navItems.length, vsync: this);
    _mainTimerBloc = TimerBloc('firstauthentication');
    _tempTimerBloc = TimerBloc('temporarypassword');
    super.initState();

    // _tabController = TabController(length: _navItems.length, vsync: this);
    _tabController.addListener(tabListener);
    _tabController.animation!.addListener(tabListener);
  }

  @override
  void dispose() {
    //_tabController.removeListener(tabListener);
    _tabController.animation!.removeListener(tabListener);
    _tabController.dispose();
    _mainTimerBloc.close();
    super.dispose();
  }

  void tabListener() {
    if(_tabController.index!=_index){
      setState(() {
        _index = _tabController.index;
        print('이게 여러번 호출인가??');
      });
      // TimerBloc 관련 로직
      if (_index == 1) { // ScreenTimer의 인덱스라고 가정
        _mainTimerBloc.add(SetActiveStatus(true));
        _mainTimerBloc.loadSavedTimer();
      } else {
        _mainTimerBloc.add(SetActiveStatus(false));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _mainTimerBloc,
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Palette.tabviewselected,
          unselectedItemColor: Palette.tabviewunselected,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 10,
          ),
          type: BottomNavigationBarType.fixed,
          onTap: (int index) {
            _tabController.animateTo(index);
          },
          currentIndex: _index,
          items: _navItems.map((item) {
            return BottomNavigationBarItem(
              icon: Icon(
                _index == item.index ? item.activeIcon : item.inactiveIcon,
              ),
              label: item.label,
            );
          }).toList(),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            MainScreen(),
            ScreenTemporaryPassword(),
            Center(child: Text('My')),
          ],
        ),
      ),
    );
  }
}

class NavItem {
  final int index;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  const NavItem({
    required this.index,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
  });
}

const _navItems = [
  NavItem(
    index: 0,
    activeIcon: Icons.home,
    inactiveIcon: Icons.home_outlined,
    label: 'home',
  ),
  NavItem(
    index: 1,
    activeIcon: Icons.lock,
    inactiveIcon: Icons.lock_outlined,
    label: '얼굴인증',
  ),
  NavItem(
    index: 2,
    activeIcon: Icons.settings,
    inactiveIcon: Icons.settings_outlined,
    label: '세팅',
  ),
  // NavItem(
  //   index: 3,
  //   activeIcon: Icons.person,
  //   inactiveIcon: Icons.person_outline,
  //   label: 'My',
  // ),
];
