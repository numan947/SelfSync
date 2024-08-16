import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:selfsync_frontend/feature/memories/model/memories_model.dart';

class MemoriesGridView extends StatelessWidget {
  final List<MemoriesModel> memories; // this data will not be changed
  final Function(MemoriesModel) onMemorySelected;
  final Function(MemoriesModel) onDeleteMemory;
  const MemoriesGridView(
      {super.key, required this.memories, required this.onMemorySelected, required this.onDeleteMemory});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          
          ResponsiveGridList(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            rowMainAxisAlignment: MainAxisAlignment.center,
            desiredItemWidth: 220,
            minSpacing: 10,
            children: memories.map((mem) {
              String startDate = '';
              String endDate = '';
              if (mem.startDate != null) {
                startDate = DateFormat.yMMMd().format(mem.startDate!);
              }
              if (mem.endDate != null) {
                endDate = DateFormat.yMMMd().format(mem.endDate!);
              }
          
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  shadowColor: Colors.purple,
                  surfaceTintColor: Colors.teal[100],
                  child: InkWell(
                    onTap: () {
                      onMemorySelected(mem);
                    },
                    onLongPress: () {
                      onDeleteMemory(mem);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            mem.title,
                            maxLines: 2,
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple),
                          ),
                            const Divider(
                              color: Colors.black,
                              thickness: 2,
                            ),
                          if (mem.startDate != null || mem.endDate != null)
                            const SizedBox(height: 10),
                          if (mem.startDate != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Tooltip(
                                    message: 'Start Date',
                                    child: Icon(Icons.data_exploration)),
                                const SizedBox(width: 5),
                                Text(startDate),
                              ],
                            ),
                          if (mem.endDate != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Tooltip(
                                    message: 'End Date',
                                    child: Icon(Icons.explore_sharp)),
                                const SizedBox(width: 5),
                                Text(endDate),
                              ],
                            ),
                          const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Tooltip(
                                    message: 'Number of Images',
                                    child: Icon(Icons.image)),
                                const SizedBox(width: 5),
                                Text('${mem.imageKeysToUrlMap.length}'),
                                const SizedBox(width: 10),
                                mem.isLocal
                                    ? const Icon(Icons.cloud_off, color: Colors.red)
                                    : const Icon(Icons.cloud_done, color: Colors.green),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
