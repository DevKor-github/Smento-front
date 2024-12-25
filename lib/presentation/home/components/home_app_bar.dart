import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:on_time_front/presentation/shared/constants/constants.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  HomeAppBar({super.key, this.title, this.actions});

  final Widget? title;
  final List<Widget>? actions;

  final bellSvg = SvgPicture.asset(
    'assets/bell.svg',
    semanticsLabel: 'bell',
    height: 21,
    fit: BoxFit.contain,
  );

  final friendsSvg = SvgPicture.asset(
    'assets/friends.svg',
    semanticsLabel: 'friends',
    height: 21,
    fit: BoxFit.contain,
  );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      actions: actions ??
          [
            IconButton(
              icon: friendsSvg,
              onPressed: () {},
            ),
            IconButton(
              icon: bellSvg,
              onPressed: () {},
            )
          ],
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(appBarHeight);
}
