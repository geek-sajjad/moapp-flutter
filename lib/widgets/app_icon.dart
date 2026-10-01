import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';

/// Same icon set as the web app (`assets/icons/*.svg`).
enum AppIconName {
  arrowLeft('arrow-left'),
  user('user'),
  phone('phone'),
  mapPin('map-pin'),
  edit('edit'),
  dollarSign('dollar-sign'),
  calendar('calendar'),
  plus('plus'),
  save('save'),
  x('x'),
  fileText('file-text'),
  file('file'),
  minus('minus'),
  share('share'),
  logOut('log-out'),
  book('book'),
  users('users'),
  search('search'),
  lock('lock'),
  alertCircle('alert-circle'),
  info('info'),
  userPlus('user-plus'),
  chevronLeft('chevron-left'),
  chevronRight('chevron-right'),
  loading('loading'),
  flag('flag'),
  download('download'),
  upload('upload'),
  database('database');

  final String fileName;
  const AppIconName(this.fileName);
}

class AppIcon extends StatelessWidget {
  final AppIconName name;
  final double size;
  final Color color;

  const AppIcon(
    this.name, {
    super.key,
    this.size = 20,
    this.color = AppColors.gray900,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/${name.fileName}.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

/// The `loading` icon with `animate-spin`.
class SpinningIcon extends StatefulWidget {
  final double size;
  final Color color;

  const SpinningIcon({
    super.key,
    this.size = 20,
    this.color = AppColors.blue600,
  });

  @override
  State<SpinningIcon> createState() => _SpinningIconState();
}

class _SpinningIconState extends State<SpinningIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: AppIcon(AppIconName.loading, size: widget.size, color: widget.color),
    );
  }
}
