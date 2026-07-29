import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/support_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

class SupportView extends StatefulWidget {
  const SupportView({super.key});

  @override
  State<SupportView> createState() => _SupportViewState();
}

class _SupportViewState extends State<SupportView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<SupportController>();
      controller.fetchUserDetails();
      controller.fetchUserMessages();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supportController = Provider.of<SupportController>(context);

    // Autofill name if available
    if (_nameController.text.isEmpty && supportController.userName.isNotEmpty) {
      _nameController.text = supportController.userName;
    }

    final faqItems = [
      {
        "q": "What are your shipping delivery times?",
        "a": "Standard domestic delivery takes between 2 to 4 business days. Express shipping options take 1 to 2 business days."
      },
      {
        "q": "Do you offer authentic brand warranties?",
        "a": "Yes! All watches sold on WatchHub are 100% authentic and come with standard official brand warranties."
      },
      {
        "q": "What payment options are supported?",
        "a": "We support Credit/Debit Cards, PayPal transactions, and Cash on Delivery (COD) services."
      },
      {
        "q": "What is your refund & exchange policy?",
        "a": "We offer a hassle-free 14-day return and exchange policy on all watches provided the item is in original unworn condition."
      }
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Customer Support",
          style: AppTextStyles.heading.copyWith(color: Colors.white, fontSize: 18),
        ),
      ),
      body: supportController.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Live Chat Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.accent, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.forum_outlined, color: AppColors.accent, size: 40),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Live Support Chat",
                                style: AppTextStyles.subheading.copyWith(color: Colors.white, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "We are available 24/7. Send a message to talk directly to an assistant.",
                                style: AppTextStyles.body.copyWith(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 2. FAQ Section
                  Text("Frequently Asked Questions", style: AppTextStyles.subheading.copyWith(fontSize: 16)),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: faqItems.length,
                    itemBuilder: (context, index) {
                      final item = faqItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: ExpansionTile(
                          iconColor: AppColors.accent,
                          collapsedIconColor: AppColors.textSecondary,
                          title: Text(
                            item['q']!,
                            style: AppTextStyles.subheading.copyWith(fontSize: 13, color: AppColors.textPrimary),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Text(
                                item['a']!,
                                style: AppTextStyles.body.copyWith(fontSize: 12, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // 3. Contact Us Form
                  Text("Send Us a Message", style: AppTextStyles.subheading.copyWith(fontSize: 16)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Name input
                          TextFormField(
                            controller: _nameController,
                            validator: (val) => val == null || val.isEmpty ? "Name required" : null,
                            decoration: InputDecoration(
                              labelText: "Your Full Name",
                              labelStyle: const TextStyle(fontSize: 13),
                              prefixIcon: const Icon(Icons.person_outline, color: AppColors.accent, size: 20),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Message input
                          TextFormField(
                            controller: _messageController,
                            maxLines: 4,
                            validator: (val) => val == null || val.isEmpty ? "Message required" : null,
                            decoration: InputDecoration(
                              labelText: "How can we help you?",
                              labelStyle: const TextStyle(fontSize: 13),
                              prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.accent, size: 20),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!_formKey.currentState!.validate()) return;
                                
                                final success = await supportController.submitMessage(
                                  fullName: _nameController.text.trim(),
                                  message: _messageController.text.trim(),
                                );

                                if (success) {
                                  _messageController.clear();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Message sent successfully!"), backgroundColor: Colors.green),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(supportController.errorMessage), backgroundColor: Colors.red),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                              child: Text(
                                "SUBMIT INQUIRY",
                                style: AppTextStyles.subheading.copyWith(color: Colors.white, fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 4. Messages History List
                  if (supportController.userMessages.isNotEmpty) ...[
                    Text("Your Previous Messages", style: AppTextStyles.subheading.copyWith(fontSize: 16)),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: supportController.userMessages.length,
                      itemBuilder: (context, index) {
                        final msg = supportController.userMessages[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    msg['full_name'] ?? 'Support Ticket',
                                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    msg['created_at']?.toString().split('T').first ?? '',
                                    style: AppTextStyles.body.copyWith(fontSize: 10),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(msg['message'] ?? '', style: AppTextStyles.body),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
