import 'package:cure_app/providers/cart_provider.dart';
import 'package:cure_app/utils/constants.dart';
import 'package:cure_app/utils/helpers.dart';
import 'package:cure_app/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  // <--- تم التغيير إلى StatefulWidget للسماح بالتحكم في حالة الحقول
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _formKey =
      GlobalKey<FormState>(); // مفتاح النموذج للتحقق من صحة حقول الإدخال
  final TextEditingController _phoneController =
      TextEditingController(); // متحكم لرقم الهاتف
  final TextEditingController _addressController =
      TextEditingController(); // متحكم للعنوان

  @override
  void dispose() {
    // مهم: التخلص من المتحكمات لمنع تسرب الذاكرة
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('عربة الخدمات',
                style: TextStyle(color: Colors.white)),
            backgroundColor: kPrimaryColor,
          ),
          body: cartProvider.cartItems.isEmpty
              ? const EmptyState(
                  message: 'عربة الخدمات فارغة. ابدأ بإضافة بعض الخدمات!',
                  icon: Icons.shopping_cart_outlined,
                )
              : Column(
                  children: [
                    // اختيار نوع مقدم الخدمة
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'نوع مقدم الخدمة',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ChoiceChip(
                                label: Text(ServiceProviderType.unspecified
                                    .toArabicString()),
                                selected: cartProvider.serviceProviderType ==
                                    ServiceProviderType.unspecified
                                        .toArabicString(),
                                selectedColor: kPrimaryColor.withOpacity(0.2),
                                labelStyle: TextStyle(
                                  color: cartProvider.serviceProviderType ==
                                          ServiceProviderType.unspecified
                                              .toArabicString()
                                      ? kPrimaryColor
                                      : Colors.black,
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    cartProvider.setServiceProviderType(
                                        ServiceProviderType.unspecified
                                            .toArabicString());
                                  }
                                },
                              ),
                              ChoiceChip(
                                label: Text(ServiceProviderType.nurseMale
                                    .toArabicString()),
                                selected: cartProvider.serviceProviderType ==
                                    ServiceProviderType.nurseMale
                                        .toArabicString(),
                                selectedColor: kPrimaryColor.withOpacity(0.2),
                                labelStyle: TextStyle(
                                  color: cartProvider.serviceProviderType ==
                                          ServiceProviderType.nurseMale
                                              .toArabicString()
                                      ? kPrimaryColor
                                      : Colors.black,
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    cartProvider.setServiceProviderType(
                                        ServiceProviderType.nurseMale
                                            .toArabicString());
                                  }
                                },
                              ),
                              ChoiceChip(
                                label: Text(ServiceProviderType.nurseFemale
                                    .toArabicString()),
                                selected: cartProvider.serviceProviderType ==
                                    ServiceProviderType.nurseFemale
                                        .toArabicString(),
                                selectedColor: kPrimaryColor.withOpacity(0.2),
                                labelStyle: TextStyle(
                                  color: cartProvider.serviceProviderType ==
                                          ServiceProviderType.nurseFemale
                                              .toArabicString()
                                      ? kPrimaryColor
                                      : Colors.black,
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    cartProvider.setServiceProviderType(
                                        ServiceProviderType.nurseFemale
                                            .toArabicString());
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        itemCount: cartProvider.cartItems.length,
                        itemBuilder: (context, index) {
                          final service = cartProvider.cartItems[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  service.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.broken_image,
                                        color: Colors.grey, size: 30),
                                  ),
                                ),
                              ),
                              title: Text(service.name),
                              subtitle: Text(
                                  '${service.price.toStringAsFixed(2)} جنيه مصري'),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () {
                                  cartProvider.removeItem(service);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        // <--- استخدام Form لتضمين حقول الإدخال والتحقق من صحتها
                        key: _formKey, // تعيين مفتاح النموذج
                        child: Column(
                          children: [
                            // الإجمالي
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('الإجمالي:',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                  '${cartProvider.totalPrice.toStringAsFixed(2)} جنيه مصري',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // **حقل رقم الهاتف الجديد (إجباري)**
                            TextFormField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                labelText: 'رقم الهاتف للتواصل',
                                hintText: 'مثال: 01xxxxxxxxx',
                                prefixIcon: const Icon(Icons.phone),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال رقم الهاتف';
                                }
                                if (value.length < 10 ||
                                    value.length > 15 ||
                                    !RegExp(r'^[0-9]+$').hasMatch(value)) {
                                  return 'رقم هاتف غير صالح';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // **حقل العنوان الجديد (إجباري)**
                            TextFormField(
                              controller: _addressController,
                              decoration: InputDecoration(
                                labelText: 'عنوان الخدمة (المنزل/الموقع)',
                                hintText: 'مثال: 123 شارع النيل، فيوم',
                                prefixIcon: const Icon(Icons.location_on),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              keyboardType: TextInputType.streetAddress,
                              maxLines: 2, // يسمح بسطرين للعنوان
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال العنوان';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // اختيار موعد الخدمة (اختياري)
                            ListTile(
                              title: Text(
                                cartProvider.selectedAppointmentDate == null
                                    ? 'اختر موعد الخدمة (اختياري)'
                                    : 'الموعد: ${formatDateTime(cartProvider.selectedAppointmentDate!)}',
                              ),
                              trailing: const Icon(Icons.calendar_today),
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 365)),
                                );
                                if (pickedDate != null) {
                                  TimeOfDay? pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (pickedTime != null) {
                                    final fullDateTime = DateTime(
                                      pickedDate.year,
                                      pickedDate.month,
                                      pickedDate.day,
                                      pickedTime.hour,
                                      pickedTime.minute,
                                    );
                                    cartProvider
                                        .setAppointmentDate(fullDateTime);
                                  }
                                }
                              },
                            ),

                            const SizedBox(height: 16),

                            // ملاحظات إضافية
                            TextField(
                              onChanged: (value) =>
                                  cartProvider.setNotes(value),
                              decoration: InputDecoration(
                                labelText: 'ملاحظات إضافية (اختياري)',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                prefixIcon: const Icon(Icons.note),
                              ),
                              maxLines: 3,
                            ),

                            const SizedBox(height: 24),

                            // زر الطلب مع موعد
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: cartProvider.isPlacingOrder ||
                                            cartProvider.cartItems.isEmpty
                                        ? null
                                        : () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              // <--- التحقق من صحة النموذج قبل الإرسال
                                              cartProvider.placeOrder(
                                                  _phoneController.text
                                                      .trim(), // تمرير رقم الهاتف
                                                  _addressController.text
                                                      .trim(), // تمرير العنوان
                                                  context,
                                                  requiresAppointment: true);
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kPrimaryColor,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 50, vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: cartProvider.isPlacingOrder
                                        ? const CircularProgressIndicator(
                                            color: Colors.white)
                                        : const Text(
                                            'اطلب الآن مع تحديد موعد',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white),
                                          ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // زر الطلب بدون موعد
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: cartProvider.isPlacingOrder ||
                                            cartProvider.cartItems.isEmpty
                                        ? null
                                        : () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              // <--- التحقق من صحة النموذج قبل الإرسال
                                              cartProvider
                                                  .setAppointmentDate(null);
                                              cartProvider.placeOrder(
                                                  _phoneController.text
                                                      .trim(), // تمرير رقم الهاتف
                                                  _addressController.text
                                                      .trim(), // تمرير العنوان
                                                  context,
                                                  requiresAppointment: false);
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 50, vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: cartProvider.isPlacingOrder
                                        ? const CircularProgressIndicator(
                                            color: Colors.white)
                                        : const Text(
                                            'اطلب الآن بدون موعد',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white),
                                          ),
                                  ),
                                ),
                              ],
                            ),

                            // رسالة خطأ في الطلب (إن وجدت)
                            if (cartProvider.orderErrorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  cartProvider.orderErrorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
