// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ginfit/core/core.dart';
import 'package:ginfit/generated/l10n.dart';

class PaymentWatchAdButton extends StatefulWidget {
  const PaymentWatchAdButton({
    super.key,
  });

  @override
  State<PaymentWatchAdButton> createState() => _PaymentWatchAdButtonState();
}

class _PaymentWatchAdButtonState extends State<PaymentWatchAdButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.1, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 16.h, right: 8.h),
        child: ScaleTransition(
            scale: _animation,
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.amber,
              ),
              onPressed: () {
                // Firebase Auth durumunu kontrol et
                final user = FirebaseAuth.instance.currentUser;

                if (user == null) {
                  // Kullanıcı giriş yapmamışsa login ekranına git
                  context.router.push(const LoginScreenRoute());
                } else {
                  // Kullanıcı giriş yapmışsa bedava kredi ekranına git
                  context.router.push(FreeCreditScreenRoute());
                }
              },
              icon: Image.asset(
                color: context.baseColor,
                PngPaths.gift,
                height: 16,
                width: 16.w,
              ),
            )));
  }
}
