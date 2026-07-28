import "package:fluent_ui/fluent_ui.dart";

class CustomTreeView extends StatefulWidget {
  const CustomTreeView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onItemSelected,
  });

  final List<CustomTreeViewItem> items;
  final Widget Function(CustomTreeViewItem item) itemBuilder;
  final void Function(CustomTreeViewItem item, bool selected) onItemSelected;

  @override
  State<CustomTreeView> createState() => _CustomTreeViewState();
}

class _CustomTreeViewState extends State<CustomTreeView> {
  List<_VisibleTreeItem> _buildVisibleItems() {
    final visible = <_VisibleTreeItem>[];

    void visit(List<CustomTreeViewItem> nodes, int depth) {
      for (final node in nodes) {
        if (node.deleted) {
          continue;
        }

        visible.add(_VisibleTreeItem(item: node, depth: depth));

        if (node.expanded && node.children.isNotEmpty) {
          visit(node.children, depth + 1);
        }
      }
    }

    visit(widget.items, 0);
    return visible;
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = _buildVisibleItems();

    return ListView.builder(
      itemCount: visibleItems.length,
      itemBuilder: (context, index) {
        final visibleItem = visibleItems[index];
        final item = visibleItem.item;
        final hasChildren = item.children.isNotEmpty;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 16.0 * visibleItem.depth),
              Checkbox(
                checked: item.finished,
                onChanged: (checked) {
                  final isSelected = checked ?? false;
                  widget.onItemSelected(item, isSelected);
                },
              ),
              SizedBox(
                width: 24,
                child: hasChildren
                    ? IconButton(
                        icon: Icon(
                          item.expanded
                              ? FluentIcons.chevron_down
                              : FluentIcons.chevron_right,
                        ),
                        onPressed: () {
                          setState(() {
                            item.expanded = !item.expanded;
                          });
                        },
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(width: 4),
              Expanded(child: widget.itemBuilder(item)),
            ],
          ),
        );
      },
    );
  }
}

class _VisibleTreeItem {
  const _VisibleTreeItem({required this.item, required this.depth});

  final CustomTreeViewItem item;
  final int depth;
}

abstract class CustomTreeViewItem {
  final int id;
  final String title;
  final String description;
  final bool finished;
  bool expanded;
  final bool deleted;
  final int? priority;
  final List<CustomTreeViewItem> children;

  CustomTreeViewItem({
    required this.id,
    required this.title,
    this.description = "",
    this.finished = false,
    this.expanded = true,
    this.deleted = false,
    this.priority,
    this.children = const [],
  });
}
