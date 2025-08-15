import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/location/location_bloc.dart' as location;
import '../../core/theme/app_theme.dart';

class LocationHeader extends StatelessWidget {
  final VoidCallback onTap;
  
  const LocationHeader({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<location.LocationBloc, location.LocationState>(
      builder: (context, locationState) {
        String locationText = 'Giao đến: Chọn địa chỉ';
        bool hasLocation = false;
        
        if (locationState is location.LocationAvailable && locationState.address != null) {
          locationText = 'Giao đến: ${locationState.address!}';
          hasLocation = true;
        } else if (locationState is location.LocationLoading) {
          locationText = 'Đang lấy vị trí...';
        } else if (locationState is location.LocationPermissionDenied) {
          locationText = 'Giao đến: Cần quyền truy cập vị trí';
        } else if (locationState is location.LocationError) {
          locationText = 'Giao đến: Không thể lấy vị trí';
        }
        
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingS,
              vertical: AppTheme.spacingXS,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.white.withOpacity(0.9),
                  size: 16,
                ),
                const SizedBox(width: AppTheme.spacingXS),
                Flexible(
                  child: Text(
                    locationText,
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingXS),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white.withOpacity(0.7),
                  size: 18,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}