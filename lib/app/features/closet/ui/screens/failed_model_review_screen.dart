import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/features/closet/ui/screens/batch_model_upload_progress_screen.dart';
import 'package:ginfit/core/core.dart';

class FailedModelReviewScreen extends StatefulWidget {
  final List<FailedModelInfo> failedPhotos;

  const FailedModelReviewScreen({
    super.key,
    required this.failedPhotos,
  });

  @override
  State<FailedModelReviewScreen> createState() =>
      _FailedModelReviewScreenState();
}

class _FailedModelReviewScreenState extends State<FailedModelReviewScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSkip() {
    if (_currentPage < widget.failedPhotos.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _onComplete();
    }
  }

  void _onManualAdd(FailedModelInfo failedPhoto) async {
    final result = await context.router.push(
      ModelItemFormScreenRoute(imageFile: failedPhoto.imageFile),
    );

    if (result != null) {
      if (_currentPage < widget.failedPhotos.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _onComplete();
      }
    }
  }

  void _onComplete() {
    context.router.popUntilRoot();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Başarısız Modeller (${_currentPage + 1}/${widget.failedPhotos.length})',
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _onComplete,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: ((_currentPage + 1) / widget.failedPhotos.length),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(context.baseColor),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: widget.failedPhotos.length,
                itemBuilder: (context, index) {
                  final failedPhoto = widget.failedPhotos[index];
                  return _buildPhotoPage(failedPhoto);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPage(FailedModelInfo failedPhoto) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          SizedBox(height: 16.h),

          // Photo Preview
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.file(
                  failedPhoto.imageFile,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Failure Reason
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.red.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Neden Başarısız?',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: Text(
                      failedPhoto.reason,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _onSkip,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    side: BorderSide(color: Colors.grey[400]!, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    _currentPage < widget.failedPhotos.length - 1
                        ? 'Atla'
                        : 'Bitir',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => _onManualAdd(failedPhoto),
                  icon: Icon(Icons.edit, size: 20.sp),
                  label: Text(
                    'Manuel Ekle',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.baseColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
