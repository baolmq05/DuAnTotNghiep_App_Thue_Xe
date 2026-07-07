import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/app_colors.dart';
import '../viewmodels/policy_viewmodel.dart';
import '../models/policy_model.dart';

class PolicyView extends StatefulWidget {
  final bool showAcceptance;
  final VoidCallback? onAccept;

  const PolicyView({
    super.key,
    this.showAcceptance = false,
    this.onAccept,
  });

  @override
  State<PolicyView> createState() => _PolicyViewState();
}

class _PolicyViewState extends State<PolicyView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PolicyViewModel>().loadPolicy();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      
      // Nếu người dùng cuộn đến gần cuối trang (còn 80px)
      if (currentScroll >= maxScroll - 80) {
        context.read<PolicyViewModel>().setHasReadFully(true);
      }
    }
  }

  void _scrollToSection(int index) {
    final viewModel = context.read<PolicyViewModel>();
    if (index >= 0 && index < viewModel.sectionKeys.length) {
      final keyContext = viewModel.sectionKeys[index].currentContext;
      if (keyContext != null) {
        Scrollable.ensureVisible(
          keyContext,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        viewModel.setActiveTab(index);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Chính sách & Quy định',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<PolicyViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi tải chính sách: ${viewModel.errorMessage}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      onPressed: () => viewModel.loadPolicy(),
                      child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          }

          if (viewModel.sections.isEmpty) {
            return const Center(
              child: Text(
                'Không tìm thấy thông tin chính sách.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            );
          }

          return Column(
            children: [
              // Anchor navigation bar (like a web sticky header)
              _buildAnchorBar(viewModel),
              
              // Policy text list
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Alert Banner
                      _buildAlertBanner(),
                      const SizedBox(height: 16),

                      // Generate Sections
                      ...List.generate(viewModel.sections.length, (index) {
                        final section = viewModel.sections[index];
                        return _buildSectionCard(section, viewModel.sectionKeys[index]);
                      }),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Sticky Bottom Acceptance Panel
              if (widget.showAcceptance) _buildAcceptancePanel(viewModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnchorBar(PolicyViewModel viewModel) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemCount: viewModel.sections.length,
        itemBuilder: (context, index) {
          final isSelected = viewModel.activeTabIndex == index;
          final section = viewModel.sections[index];
          // Extracted short title from number format, e.g. "1. Trách nhiệm" -> "Trách nhiệm"
          final titleParts = section.title.split('. ');
          final shortTitle = titleParts.length > 1 ? titleParts[1] : section.title;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: ChoiceChip(
              label: Text(
                shortTitle,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: Colors.grey.shade100,
              checkmarkColor: Colors.white,
              showCheckmark: false,
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
              ),
              onSelected: (selected) {
                if (selected) {
                  _scrollToSection(index);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlertBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accentSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.secondary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: const TextSpan(
                text: 'Chính sách bảo vệ dữ liệu & quy định chung tại ',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.4),
                children: [
                  TextSpan(
                    text: 'DRIVIO',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  TextSpan(text: '. Vui lòng đọc kỹ các điều khoản để đảm bảo quyền lợi của bạn.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(PolicySection section, GlobalKey key) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Text(
              section.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Divider(color: AppColors.border, height: 24, thickness: 1),
            
            // Section Elements
            ...section.elements.map((element) => _buildElementWidget(element)),
          ],
        ),
      ),
    );
  }

  Widget _buildElementWidget(PolicyContentElement element) {
    switch (element.type) {
      case 'bullet':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4.0, right: 8.0),
                child: Icon(Icons.circle, size: 6, color: AppColors.primary),
              ),
              Expanded(
                child: Text(
                  element.text ?? '',
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      case 'table':
        return _buildTableWidget(element);
      case 'formula':
        return _buildFormulaWidget(element);
      case 'text':
      default:
        // Identify subsection titles like "A. Trách nhiệm của chủ xe" to make them bold
        final isSubTitle = element.text != null && 
            (element.text!.startsWith('A. ') || 
             element.text!.startsWith('B. ') || 
             element.text!.startsWith('C. '));

        return Padding(
          padding: EdgeInsets.only(bottom: isSubTitle ? 8.0 : 12.0, top: isSubTitle ? 8.0 : 0.0),
          child: Text(
            element.text ?? '',
            style: TextStyle(
              fontSize: isSubTitle ? 14.5 : 13.5,
              fontWeight: isSubTitle ? FontWeight.bold : FontWeight.normal,
              color: isSubTitle ? AppColors.primaryDark : AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        );
    }
  }

  Widget _buildTableWidget(PolicyContentElement element) {
    if (element.tableHeaders == null || element.tableRows == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(1.0),
        },
        border: TableBorder.symmetric(
          inside: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        children: [
          // Header Row
          TableRow(
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
            ),
            children: element.tableHeaders!.map((header) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
                child: Text(
                  header,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
              );
            }).toList(),
          ),
          
          // Data Rows
          ...element.tableRows!.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;
            final isEven = index % 2 == 0;

            return TableRow(
              decoration: BoxDecoration(
                color: isEven ? Colors.grey.shade50 : Colors.white,
              ),
              children: row.map((cell) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
                  child: Text(
                    cell,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFormulaWidget(PolicyContentElement element) {
    if (element.formulas == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blueGrey.shade100, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate_outlined, color: Colors.blueGrey.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Bảng tóm tắt công thức tính giá',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.blueGrey.shade800,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          ...element.formulas!.map((formula) {
            final label = formula['label'] ?? '';
            final val = formula['value'] ?? '';

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      val,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12.0,
                        color: AppColors.primaryDark,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAcceptancePanel(PolicyViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!viewModel.hasReadFully)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade800, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Vui lòng cuộn xuống dưới cùng để có thể xác nhận.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Checkbox Agreement row
            Row(
              children: [
                Checkbox(
                  value: viewModel.isAccepted,
                  onChanged: viewModel.hasReadFully
                      ? (val) {
                          if (val != null) {
                            viewModel.setAccepted(val);
                          }
                        }
                      : null, // Vô hiệu hóa checkbox nếu chưa cuộn hết trang
                  activeColor: AppColors.primary,
                ),
                Expanded(
                  child: Text(
                    'Tôi đã đọc kỹ và đồng ý với các Chính sách & Quy định nêu trên.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: viewModel.hasReadFully ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Confirm Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey.shade300,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: viewModel.isAccepted
                  ? () {
                      widget.onAccept?.call();
                      Navigator.of(context).pop();
                    }
                  : null,
              child: const Text(
                'Đồng ý và tiếp tục',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
