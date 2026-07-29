import 'package:adminapp/utils/app_colors.dart';
import 'package:flutter/material.dart';

typedef RowBuilder = Widget Function(
  BuildContext context,
  String header,
  dynamic value,
  Map<String, dynamic> item,
);

class ResponsiveTableView extends StatelessWidget {
  final String title;
  final List<String> headers;
  final List<Map<String, dynamic>> data;
  final List<Widget> headerActions;
  final RowBuilder? rowBuilder;

  const ResponsiveTableView({
    super.key,
    required this.title,
    required this.headers,      
    required this.data,
    this.headerActions = const [],
    this.rowBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TableHeader(
            title: title,
            headerActions: headerActions,
          ),
          if (data.isEmpty)
            const _EmptyState()
          else
            _DesktopTable(
              data: data,
              headers: headers,
              rowBuilder: rowBuilder,
            ),
        ],
      ),
    );
  }
}

// === Header Component ===
class _TableHeader extends StatelessWidget {
  final String title;
  final List<Widget> headerActions;

  const _TableHeader({
    required this.title,
    required this.headerActions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withAlpha(217),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            // Small Width: Stack title and action items vertically
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                if (headerActions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: headerActions,
                  ),
                ],
              ],
            );
          } else {
            // Normal Width: Display side-by-side
            return Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (headerActions.isNotEmpty) const SizedBox(width: 16),
                ...headerActions.map((action) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: action,
                    )),
              ],
            );
          }
        },
      ),
    );
  }
}

// === Empty State Component ===
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No data available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add new items to see them here',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

// === Desktop Table Component ===
class _DesktopTable extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final List<String> headers;
  final RowBuilder? rowBuilder;

  const _DesktopTable({
    required this.data,
    required this.headers,
    this.rowBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final columnCount = headers.length;
        final minColumnWidth = 100.0;
        final totalMinWidth = columnCount * minColumnWidth;
        
        // Auto-adjust column spacing based on available width
        final columnSpacing = availableWidth > totalMinWidth 
            ? ((availableWidth - totalMinWidth) / (columnCount + 1)).clamp(16.0, 32.0)
            : 16.0;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: availableWidth,
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.grey.shade100,
              ),
              child: DataTable(
                headingRowHeight: 52,
                dataRowMinHeight: 60,
                dataRowMaxHeight: 80,
                columnSpacing: columnSpacing,
                horizontalMargin: 24,
                headingRowColor: WidgetStateProperty.all(
                  Colors.grey.shade50,
                ),
                dataRowColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.hovered)) {
                      return AppColors.primary.withAlpha(10);
                    }
                    return Colors.transparent;
                  },
                ),
                columns: headers.map((h) {
                  return DataColumn(
                    label: Flexible(
                      child: Text(
                        h.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade700,
                          letterSpacing: 0.8,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
                rows: data.map((item) {
                  return DataRow(
                    cells: headers.map((header) {
                      final key = _getKeyFromHeader(header);
                      final value = item[key] ?? '-';
                      return DataCell(
                        rowBuilder != null
                            ? rowBuilder!(context, header, value, item)
                            : Text(
                                value.toString(),
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getKeyFromHeader(String header) =>
      header.toLowerCase().replaceAll(' ', '_');
}