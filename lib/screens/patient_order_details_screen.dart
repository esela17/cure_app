import 'package:cure_app/models/order.dart';
import 'package:cure_app/models/user_model.dart';
import 'package:cure_app/screens/leave_review_screen.dart';
import 'package:cure_app/services/firestore_service.dart';
import 'package:cure_app/utils/constants.dart';
import 'package:cure_app/utils/helpers.dart';
import 'package:cure_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class PatientOrderDetailsScreen extends StatefulWidget {
  final Order order;
  const PatientOrderDetailsScreen({Key? key, required this.order})
      : super(key: key);

  @override
  State<PatientOrderDetailsScreen> createState() =>
      _PatientOrderDetailsScreenState();
}

class _PatientOrderDetailsScreenState extends State<PatientOrderDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildGlassAppBar(),
      body: Container(
        decoration: _buildGradientBackground(),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // قسم تفاصيل الممرض (يظهر فقط إذا تم قبول الطلب)
                    if (widget.order.nurseId != null)
                      FutureBuilder<UserModel?>(
                        future: firestoreService.getUser(widget.order.nurseId!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _buildLoadingCard();
                          }
                          if (!snapshot.hasData || snapshot.data == null) {
                            return _buildErrorCard(
                                'لا يمكن تحميل بيانات الممرض');
                          }
                          final nurse = snapshot.data!;
                          return _buildNurseCard(nurse);
                        },
                      ),

                    const SizedBox(height: 24),

                    // قسم تفاصيل الطلب
                    _buildOrderDetailsCard(),

                    const SizedBox(height: 30),

                    // زر تقييم الخدمة
                    if (widget.order.status == 'completed' &&
                        !widget.order.isRated)
                      _buildRatingButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildGlassAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.15),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
      title: Text(
        'تفاصيل الطلب',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withOpacity(0.2),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  BoxDecoration _buildGradientBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color.fromARGB(255, 98, 116, 255),
          const Color.fromARGB(255, 140, 146, 255),
          const Color.fromARGB(255, 131, 148, 255),
          const Color.fromARGB(255, 166, 174, 244),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ),
    );
  }

  Widget _buildGlassCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(-5, -5),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return _buildGlassCard(
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return _buildGlassCard(
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.red.withOpacity(0.8),
                  Colors.redAccent.withOpacity(0.6),
                ],
              ),
            ),
            child:
                const Icon(Icons.error_outline, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNurseCard(UserModel nurse) {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('مقدم الخدمة', Icons.medical_services),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: nurse.profileImageUrl != null
                      ? Image.network(
                          nurse.profileImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person,
                                  color: Colors.white, size: 35),
                        )
                      : const Icon(Icons.person, color: Colors.white, size: 35),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nurse.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: nurse.averageRating,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFD700),
                          ),
                          itemCount: 5,
                          itemSize: 22.0,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: Text(
                            '(${nurse.ratingCount})',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('تفاصيل طلبك', Icons.receipt_long),
          const SizedBox(height: 20),
          _buildDetailRow(
            Icons.tag,
            'رقم الطلب:',
            widget.order.id.substring(0, 8),
          ),
          _buildDetailRow(
            Icons.calendar_today_rounded,
            'تاريخ الطلب:',
            formatDateTime(widget.order.orderDate),
          ),
          _buildDetailRow(
            Icons.info_outline_rounded,
            'الحالة:',
            widget.order.status,
            statusColor: _getStatusColor(widget.order.status),
            showStatusBadge: true,
          ),
          const SizedBox(height: 20),
          _buildDivider(),
          const SizedBox(height: 20),
          _buildSectionHeader('الخدمات المطلوبة', Icons.medical_information,
              isSubSection: true),
          const SizedBox(height: 16),
          ...widget.order.services.map((service) => _buildServiceItem(service)),
          const SizedBox(height: 20),
          _buildDivider(),
          const SizedBox(height: 20),
          _buildTotalRow(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon,
      {bool isSubSection = false}) {
    return Row(
      children: [
        Container(
          width: isSubSection ? 40 : 45,
          height: isSubSection ? 40 : 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.1),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: isSubSection ? 20 : 22,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: isSubSection ? 18 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? statusColor,
    bool showStatusBadge = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withOpacity(0.15),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(icon, color: Colors.white.withOpacity(0.8), size: 18),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: showStatusBadge
                ? _buildStatusBadge(value, statusColor!)
                : Text(
                    value,
                    style: TextStyle(
                      color: statusColor ?? Colors.white,
                      fontSize: 16,
                      fontWeight: statusColor != null
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withOpacity(0.2),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildServiceItem(dynamic service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              service.name,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00C9FF).withOpacity(0.3),
                  const Color(0xFF92FE9D).withOpacity(0.3),
                ],
              ),
            ),
            child: Text(
              '${service.price.toStringAsFixed(2)} جنيه',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.15),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
            ),
            child:
                const Icon(Icons.attach_money, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          const Text(
            'الإجمالي:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            '${widget.order.totalPrice.toStringAsFixed(2)} جنيه مصري',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildRatingButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFD700),
            Color(0xFFFFA500),
            Color(0xFFFF6B35),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LeaveReviewScreen(order: widget.order),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: const Icon(Icons.star_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Text(
                  'قيّم الخدمة الآن',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFF9500);
      case 'accepted':
        return const Color(0xFF007AFF);
      case 'completed':
        return const Color(0xFF34C759);
      case 'rejected':
        return const Color(0xFFFF3B30);
      default:
        return const Color(0xFF8E8E93);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'في الانتظار';
      case 'accepted':
        return 'مقبول';
      case 'completed':
        return 'مكتمل';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }
}
