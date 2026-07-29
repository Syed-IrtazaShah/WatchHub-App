import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/support_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

class FeedbackView extends StatefulWidget {
  const FeedbackView({super.key});

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupportController>().fetchUserFeedbacks();
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supportController = Provider.of<SupportController>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Submit Feedback",
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "We value your thoughts",
                            style: AppTextStyles.subheading.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Report bugs, request features, or tell us what you love about the app.",
                            style: AppTextStyles.body,
                          ),
                          const SizedBox(height: 20),
                          
                          // Feedback details
                          TextFormField(
                            controller: _feedbackController,
                            maxLines: 5,
                            validator: (val) => val == null || val.isEmpty ? "Please write some feedback" : null,
                            decoration: InputDecoration(
                              hintText: "Enter your feedback description...",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Submit feedback CTA
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!_formKey.currentState!.validate()) return;

                                final success = await supportController.submitFeedback(
                                  feedbackText: _feedbackController.text.trim(),
                                );

                                if (success) {
                                  _feedbackController.clear();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Feedback submitted successfully!"), backgroundColor: Colors.green),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(supportController.errorMessage), backgroundColor: Colors.red),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                              child: Text(
                                "SUBMIT FEEDBACK",
                                style: AppTextStyles.subheading.copyWith(color: Colors.white, fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // History feedback list
                  if (supportController.userFeedbacks.isNotEmpty) ...[
                    Text("Your Previous Feedbacks", style: AppTextStyles.subheading.copyWith(fontSize: 16)),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: supportController.userFeedbacks.length,
                      itemBuilder: (context, index) {
                        final fb = supportController.userFeedbacks[index];
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
                                    "Feedback Ticket #${fb['id']}",
                                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    fb['created_at']?.toString().split('T').first ?? '',
                                    style: AppTextStyles.body.copyWith(fontSize: 10),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(fb['feedback_text'] ?? '', style: AppTextStyles.body),
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
