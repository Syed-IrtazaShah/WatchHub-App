import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adminapp/controllers/reviews/review_controller.dart';
import 'package:adminapp/widget/custom_table.dart';

class ReviewsTableView extends StatefulWidget {
  const ReviewsTableView({super.key});

  @override
  State<ReviewsTableView> createState() => _ReviewsTableViewState();
}

class _ReviewsTableViewState extends State<ReviewsTableView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch reviews list on startup
      context.read<ReviewController>().fetchReviews();
    });
  }

  // Helper widget to draw stars icon list
  Widget _buildStars(int count) {
    return Row(
      children: List.generate(
        5,
        (i) => Icon(
          i < count ? Icons.star : Icons.star_border,
          size: 14,
          color: Colors.amber,
        ),
      ),
    );
  }

  // Status badge to distinguish between approved and pending review items
  Widget _buildStatusBadge(bool isVerified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isVerified
            ? Colors.green.withAlpha(50)
            : Colors.orange.withAlpha(50),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isVerified ? 'Approved' : 'Pending',
        style: TextStyle(
          color: isVerified ? Colors.green : Colors.orange,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Triggers confirm delete dialog box
  void _confirmDelete(
    BuildContext context,
    dynamic id,
    ReviewController controller,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this review?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              controller.deleteReview(id);
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviewController = Provider.of<ReviewController>(context);

    if (reviewController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Map rows content
    final tableData = reviewController.reviews
        .map(
          (r) => {
            'id': r['id'],
            'product': r['joined_product'],
            'customer': r['joined_customer'],
            'rating': r['rating'] ?? 0,
            'comment': r['comment'] ?? '',
            'date': r['created_at'],
            'verified': r['is_verified_purchase'] ?? false,
          },
        )
        .toList();

    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ResponsiveTableView(
            title: 'Reviews Management',
            data: tableData,
            headerActions: [
              // Pending reviews filter trigger
              ElevatedButton.icon(
                onPressed: () {
                  reviewController.fetchReviews(onlyPending: true);
                },
                icon: const Icon(Icons.pending, size: 18),
                label: const Text("Pending Only"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Refresh reviews list
              ElevatedButton.icon(
                onPressed: () => reviewController.refreshReview(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Refresh"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  side: const BorderSide(color: Colors.black12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
            headers: const [
              'Product',
              'Customer',
              'Rating',
              'Comment',
              'Date',
              'Status',
              'Actions',
            ],
            rowBuilder: (context, header, value, item) {
              switch (header) {
                case 'Rating':
                  return _buildStars(value);
                case 'Status':
                  return _buildStatusBadge(item['verified']);
                case 'Date':
                  final dt = DateTime.parse(value.toString());
                  return Text(
                    "${dt.day}/${dt.month}/${dt.year}",
                    style: const TextStyle(fontSize: 12),
                  );
                case 'Actions':
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Delete button
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 18,
                        ),
                        onPressed: () => _confirmDelete(context, item['id'], reviewController),
                      ),
                      // Verified switch toggle status button
                      IconButton(
                        icon: Icon(
                          item['verified'] ? Icons.check_circle : Icons.check_circle_outline,
                          color: Colors.green,
                          size: 18,
                        ),
                        onPressed: () => reviewController.updateStatus(item['id'], item['verified']),
                      ),
                    ],
                  );
                default:
                  return Text(
                    value.toString(),
                    style: const TextStyle(fontSize: 12),
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}
