import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/constants.dart';

class AccessoriesScreen extends StatefulWidget {
  const AccessoriesScreen({super.key});

  @override
  State<AccessoriesScreen> createState() => _AccessoriesScreenState();
}

class _AccessoriesScreenState extends State<AccessoriesScreen> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: AppBar(
        title: const Text('🎀 配件收藏'),
        backgroundColor: Colors.amber.shade100,
        foregroundColor: Colors.amber.shade900,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatsBar(state),
            const SizedBox(height: 16),
            _buildCatPreview(state),
            const SizedBox(height: 20),
            _buildAccessoriesGrid(state),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsBar(AppState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade300, Colors.orange.shade300],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('🔥', '連續記帳', '${state.streak} 天'),
          Container(width: 1, height: 36, color: Colors.white54),
          _statItem('💰', '累計存款', '\$${state.totalSaved.toInt()}'),
        ],
      ),
    );
  }

  Widget _statItem(String icon, String label, String value) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500)),
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ],
    );
  }

  Widget _buildCatPreview(AppState state) {
    final equipped = state.equippedAccessories;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('🐱 我的招財貓',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800)),
          const SizedBox(height: 12),
          if (equipped.isEmpty)
            Text('還沒有裝備配件喔～',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: equipped.map((id) {
                final acc = kAccessories.where((a) => a.id == id).firstOrNull;
                if (acc == null) return const SizedBox.shrink();
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(acc.emoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 6),
                      Text(acc.name,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade800)),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 8),
          Text('已裝備 ${equipped.length} 個配件',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildAccessoriesGrid(AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('全部配件',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.amber.shade800)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: kAccessories.length,
          itemBuilder: (context, index) {
            final acc = kAccessories[index];
            final unlocked = state.unlockedAccessories.contains(acc.id);
            final equipped = state.equippedAccessories.contains(acc.id);
            return _accessoryCard(state, acc, unlocked, equipped);
          },
        ),
      ],
    );
  }

  Widget _accessoryCard(
      AppState state, AccessoryDef acc, bool unlocked, bool equipped) {
    final progress = _getProgress(state, acc);

    return GestureDetector(
      onTap: unlocked ? () => state.toggleAccessory(acc.id) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: equipped
              ? Colors.amber.shade50
              : unlocked
                  ? Colors.white
                  : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: equipped
                ? Colors.amber.shade400
                : unlocked
                    ? Colors.amber.shade200
                    : Colors.grey.shade300,
            width: equipped ? 2.5 : 1,
          ),
          boxShadow: equipped
              ? [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Text(
                    acc.emoji,
                    style: TextStyle(
                      fontSize: 36,
                      color: unlocked ? null : Colors.grey,
                    ),
                  ),
                  if (unlocked)
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: equipped ? Colors.amber : Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        equipped ? Icons.star : Icons.check,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                acc.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: unlocked ? Colors.amber.shade800 : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              if (unlocked)
                Text(
                  equipped ? '已裝備 ✅' : '點擊裝備',
                  style: TextStyle(
                    fontSize: 11,
                    color: equipped ? Colors.amber.shade700 : Colors.grey.shade500,
                    fontWeight: equipped ? FontWeight.w600 : FontWeight.normal,
                  ),
                )
              else ...[
                Text(
                  acc.description,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor:
                        AlwaysStoppedAnimation(Colors.amber.shade400),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  double _getProgress(AppState state, AccessoryDef acc) {
    if (acc.reqType == 'streak') {
      return (state.streak / acc.reqValue).clamp(0.0, 1.0);
    } else if (acc.reqType == 'savings') {
      return (state.totalSaved / acc.reqValue).clamp(0.0, 1.0);
    }
    return 0;
  }
}
