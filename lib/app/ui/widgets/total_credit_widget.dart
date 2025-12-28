import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/core/core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ginfit/generated/l10n.dart';

class TotalCreditWidget extends StatelessWidget {
  final bool navigateAvailable;
  const TotalCreditWidget({super.key, required this.navigateAvailable});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(
              includeMetadataChanges:
                  false), // Sadece gerçek data değişikliklerini dinle
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(AppLocalizations.of(context).errorLoadingCredits);
        }

        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        final totalCredit = userData?['profile_info']?['totalCredit'] ??
            userData?['totalCredit'] ??
            userData?['profile_info']?['credits'] ??
            userData?['credits'] ??
            0;

        return _buildCreditWidget(context, totalCredit, true);
      },
    );
  }

  Widget _buildCreditWidget(
      BuildContext context, int totalCredit, bool isAuthenticated) {
    return GestureDetector(
      onTap: () {
        if (isAuthenticated) {
          // Platform'a göre farklı payment screen'e git
          if (Platform.isIOS) {
            context.router.push(PaymentsScreenRoute());
          } else {
            context.router.push(PaymentsScreenRoute());
          }
        } else {
          context.router.push(const LoginScreenRoute());
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: context.gray100,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          spacing: 4.w,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              PngPaths.coin,
              height: 24.h,
              width: 24.w,
            ),
            Text(
              totalCredit.toString(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.black,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
