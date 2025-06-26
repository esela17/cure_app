import 'package:cure_app/providers/cart_provider.dart';
import 'package:cure_app/providers/active_order_provider.dart';
import 'package:cure_app/screens/location_picker_screen.dart';
import 'package:cure_app/screens/order_tracking_screen.dart';
import 'package:cure_app/utils/constants.dart';
import 'package:cure_app/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _navigateToTracking(String? orderId) {
    if (orderId != null && mounted) {
      return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderTrackingScreen(orderId: orderId),
        ),
      );
    }
    return Future.value();
  }

  void _orderNow(CartProvider cartProvider) {
    if (_formKey.currentState!.validate()) {
      cartProvider.setAppointmentDate(null);
      cartProvider
          .placeOrder(
        _phoneController.text.trim(),
        _addressController.text.trim(),
        context,
        requiresAppointment: false,
      )
          .then((orderId) async {
        if (orderId != null) {
          await context.read<ActiveOrderProvider>().refreshActiveOrder();
          _navigateToTracking(orderId);
        }
      });
    }
  }

  Future<void> _orderWithAppointment(CartProvider cartProvider) async {
    if (!_formKey.currentState!.validate()) return;

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: kPrimaryColor,
                  surface: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: kPrimaryColor,
                    surface: Colors.white,
                  ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null && mounted) {
        final fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        cartProvider.setAppointmentDate(fullDateTime);

        final newOrderId = await cartProvider.placeOrder(
          _phoneController.text.trim(),
          _addressController.text.trim(),
          context,
          requiresAppointment: true,
        );

        if (newOrderId != null) {
          await context.read<ActiveOrderProvider>().refreshActiveOrder();
          _navigateToTracking(newOrderId);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        if (cartProvider.cartItems.isEmpty) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [kPrimaryColor, Colors.white],
                  stops: [0.0, 0.3],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    _buildCustomAppBar(context, 'عربة الخدمات'),
                    const Expanded(
                      child: EmptyState(
                        message: 'عربة الخدمات فارغة. ابدأ بإضافة بعض الخدمات!',
                        icon: Icons.shopping_cart_outlined,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kPrimaryColor, Colors.white],
                stops: [0.0, 0.3],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildCustomAppBar(context, 'مراجعة الطلب'),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildGlassCard(
                                  child: _buildServicesList(cartProvider),
                                  title: 'الخدمات المطلوبة',
                                  icon: Icons.medical_services_outlined,
                                ),
                                const SizedBox(height: 20),
                                _buildGlassCard(
                                  title: 'بيانات التواصل',
                                  icon: Icons.contact_phone_outlined,
                                  child: Column(
                                    children: [
                                      _buildModernTextField(
                                        controller: _phoneController,
                                        label: 'رقم هاتف للتواصل',
                                        icon: Icons.phone_outlined,
                                        keyboardType: TextInputType.phone,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'رقم الهاتف مطلوب';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      _buildModernTextField(
                                        controller: _addressController,
                                        label: 'العنوان بالتفصيل',
                                        icon: Icons.location_on_outlined,
                                        maxLines: 2,
                                        validator: (value) =>
                                            (value == null || value.isEmpty)
                                                ? 'العنوان مطلوب'
                                                : null,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildLocationButton(cartProvider),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildGlassCard(
                                  title: 'نوع مقدم الخدمة',
                                  icon: Icons.person_outline,
                                  child:
                                      _buildProviderTypeSelector(cartProvider),
                                ),
                                const SizedBox(height: 20),
                                _buildGlassCard(
                                  title: 'ملاحظات إضافية',
                                  icon: Icons.notes_outlined,
                                  child: _buildModernTextField(
                                    onChanged: (value) =>
                                        cartProvider.setNotes(value),
                                    label:
                                        'هل تحتاج أن نشتري لك أي أدوات؟ (اختياري)',
                                    icon: Icons.edit_note_outlined,
                                    maxLines: 3,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildPricingCard(cartProvider),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomAppBar(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({
    required Widget child,
    required String title,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: kPrimaryColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    TextEditingController? controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kPrimaryColor),
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: kPrimaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildLocationButton(CartProvider cartProvider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () async {
          final selectedLocation = await Navigator.push<LatLng>(
            context,
            MaterialPageRoute(
              builder: (context) => const LocationPickerScreen(),
            ),
          );

          if (selectedLocation != null) {
            cartProvider.setSelectedLocation(
              selectedLocation.latitude,
              selectedLocation.longitude,
            );

            _addressController.text =
                'الموقع: ${selectedLocation.latitude.toStringAsFixed(5)}, ${selectedLocation.longitude.toStringAsFixed(5)}';
          }
        },
        icon: const Icon(Icons.map_outlined, color: Colors.white),
        label: const Text(
          'اختر الموقع من الخريطة',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildProviderTypeSelector(CartProvider cartProvider) {
    final types = ['ممرض', 'ممرضة', 'غير محدد'];
    return Row(
      children: types.map((type) {
        final isSelected = cartProvider.serviceProviderType == type;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: kPrimaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: ElevatedButton(
                onPressed: () => cartProvider.setServiceProviderType(type),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: isSelected ? Colors.white : Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildServicesList(CartProvider cartProvider) {
    return ListView.builder(
      itemCount: cartProvider.cartItems.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final service = cartProvider.cartItems[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(service.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(
              service.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              '${service.price.toStringAsFixed(2)} جنيه',
              style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon:
                    const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => cartProvider.removeItem(service),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPricingCard(CartProvider cartProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kPrimaryColor,
            kPrimaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الإجمالي:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${cartProvider.totalPrice.toStringAsFixed(2)} جنيه',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    text: 'اطلب الآن',
                    onPressed: cartProvider.isPlacingOrder
                        ? null
                        : () => _orderNow(cartProvider),
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    text: 'حدد موعد',
                    onPressed: cartProvider.isPlacingOrder
                        ? null
                        : () => _orderWithAppointment(cartProvider),
                    color: Colors.white,
                    textColor: kPrimaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback? onPressed,
    required Color color,
    Color? textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: textColor ?? Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
