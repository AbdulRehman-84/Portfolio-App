import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../globals/app_colors.dart';
import '../globals/app_text_styles.dart';
import '../globals/constants.dart';
import 'about_me.dart';
import 'contact_us.dart';
import 'footer_class.dart';
import 'home_page.dart';
import 'my_portfolio.dart';
import 'my_services.dart';

class MainDashBoard extends StatefulWidget {
  const MainDashBoard({Key? key}) : super(key: key);

  @override
  _MainDashBoardState createState() => _MainDashBoardState();
}

class _MainDashBoardState extends State<MainDashBoard>
    with SingleTickerProviderStateMixin {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ScrollOffsetListener scrollOffsetListener =
      ScrollOffsetListener.create();
  final onMenuHover = Matrix4.identity()..scale(1.0);

  final menuItems = <String>[
    'Home',
    'About',
    'Services',
    'Portfolio',
    'Contact',
  ];

  var menuIndex = 0;

  final screensList = <Widget>[
    HomePage(),
    AboutMe(),
    MyServices(),
    MyPortfolio(),
    ContactUs(),
    FooterClass(),
  ];

  final yourScrollController = ScrollController();

  // Gradient animation
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation1;
  late Animation<Color?> _colorAnimation2;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..repeat(reverse: true);

    _colorAnimation1 =
        ColorTween(begin: Colors.blue, end: Colors.purple).animate(_controller);
    _colorAnimation2 =
        ColorTween(begin: Colors.pink, end: Colors.orange).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future scrollTo({required int index}) async {
    _itemScrollController
        .scrollTo(
            index: index,
            duration: const Duration(seconds: 2),
            curve: Curves.fastLinearToSlowEaseIn)
        .whenComplete(() {
      setState(() {
        menuIndex = index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_colorAnimation1.value!, _colorAnimation2.value!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                buildAppBar(size),
                Expanded(
                  child: Scrollbar(
                    trackVisibility: true,
                    thumbVisibility: true,
                    thickness: 8,
                    interactive: true,
                    controller: yourScrollController,
                    child: ScrollablePositionedList.builder(
                      itemCount: screensList.length,
                      itemScrollController: _itemScrollController,
                      itemPositionsListener: itemPositionsListener,
                      scrollOffsetListener: scrollOffsetListener,
                      itemBuilder: (context, index) {
                        return screensList[index];
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget buildAppBar(Size size) {
    return AppBar(
      backgroundColor: Colors.transparent,
      toolbarHeight: 60,
      titleSpacing: 40,
      elevation: 0,
      title: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 768) {
            // Mobile view
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Portfolio',
                  style: GoogleFonts.signikaNegative(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                PopupMenuButton(
                  icon: Icon(
                    Icons.menu_sharp,
                    size: 32,
                    color: AppColors.white,
                  ),
                  color: AppColors.bgColor2,
                  position: PopupMenuPosition.under,
                  constraints: BoxConstraints.tightFor(width: size.width * 0.9),
                  itemBuilder: (BuildContext context) => menuItems
                      .asMap()
                      .entries
                      .map(
                        (e) => PopupMenuItem(
                          textStyle: AppTextStyles.headerTextStyle(),
                          onTap: () {
                            scrollTo(index: e.key);
                          },
                          child: Text(e.value),
                        ),
                      )
                      .toList(),
                ),
              ],
            );
          } else {
            // Desktop view
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Portfolio',
                  style: GoogleFonts.signikaNegative(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 30,
                  child: ListView.separated(
                    itemCount: menuItems.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (context, child) =>
                        Constants.sizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          scrollTo(index: index);
                        },
                        borderRadius: BorderRadius.circular(100),
                        onHover: (value) {
                          setState(() {
                            if (value) {
                              menuIndex = index;
                            } else {
                              menuIndex = 0;
                            }
                          });
                        },
                        child: buildNavBarAnimatedContainer(
                            index, menuIndex == index),
                      );
                    },
                  ),
                ),
                Constants.sizedBox(width: 30),
              ],
            );
          }
        },
      ),
    );
  }

  AnimatedContainer buildNavBarAnimatedContainer(int index, bool hover) {
    return AnimatedContainer(
      alignment: Alignment.center,
      width: hover ? 80 : 75,
      duration: const Duration(milliseconds: 200),
      transform: hover ? onMenuHover : null,
      child: Text(
        menuItems[index],
        style: AppTextStyles.headerTextStyle(
            color: hover ? AppColors.themeColor : AppColors.white),
      ),
    );
  }
}
