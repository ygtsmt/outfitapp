import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:comby/app/features/closet/models/model_item_model.dart';
import 'package:comby/app/features/closet/models/wardrobe_item_model.dart';
import 'package:comby/app/features/try_on/ui/widgets/virtual_cabin_tab_content.dart';
import 'package:comby/app/features/try_on/ui/widgets/quick_try_tab_content.dart';

class TryOnScreen extends StatefulWidget {
  final ModelItem? initialModel;
  final List<WardrobeItem>? initialClothes;
  final String? alternativeModelUrl; // Combine photo URL for toggle

  const TryOnScreen({
    super.key,
    this.initialModel,
    this.initialClothes,
    this.alternativeModelUrl,
  });

  @override
  State<TryOnScreen> createState() => _TryOnScreenState();
}

class _TryOnScreenState extends State<TryOnScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            TabBar(
              indicatorColor: Theme.of(context).primaryColor,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              labelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
              tabs: const [
                Tab(text: 'Sanal Kabin'),
                Tab(text: 'Hızlı Dene'),
              ],
            ),
            Expanded(
              child: TabBarView(
                physics:
                    const NeverScrollableScrollPhysics(), // Disable swipe if camera interferes
                children: [
                  VirtualCabinTabContent(
                    initialModel: widget.initialModel,
                    initialClothes: widget.initialClothes,
                    alternativeModelUrl: widget.alternativeModelUrl,
                  ),
                  const QuickTryTabContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
