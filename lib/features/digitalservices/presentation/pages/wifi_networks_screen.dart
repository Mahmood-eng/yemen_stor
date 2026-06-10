import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:go_router/go_router.dart';
import 'package:yemen_stor/core/routes/app_routes.dart';
import 'package:yemen_stor/core/widgets/custom_loading_indicator.dart';

class WifiNetworksScreen extends StatefulWidget {
  static const String id = 'wifi_networks_screen';
  const WifiNetworksScreen({super.key});

  @override
  State<WifiNetworksScreen> createState() => _WifiNetworksScreenState();
}

class _WifiNetworksScreenState extends State<WifiNetworksScreen> {
  // الـ Favorites محفوظة في Firestore لكل مستخدم
  Set<String> _favoriteIds = {};
  bool _favoritesLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  /// جلب المفضلة من Firestore للمستخدم الحالي
  Future<void> _loadFavorites() async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _favoritesLoaded = true);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wifi_favorites')
          .get();
      setState(() {
        _favoriteIds = doc.docs.map((d) => d.id).toSet();
        _favoritesLoaded = true;
      });
    } catch (_) {
      setState(() => _favoritesLoaded = true);
    }
  }

  /// حفظ/إزالة المفضلة في Firestore
  Future<void> _toggleFavorite(String networkId) async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid ?? 'guest')
        .collection('wifi_favorites')
        .doc(networkId);

    setState(() {
      if (_favoriteIds.contains(networkId)) {
        _favoriteIds.remove(networkId);
      } else {
        _favoriteIds.add(networkId);
      }
    });

    if (user != null) {
      if (_favoriteIds.contains(networkId)) {
        await ref.set({'addedAt': FieldValue.serverTimestamp()});
      } else {
        await ref.delete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: theme.colorScheme.surface,
            elevation: 0.5,
            centerTitle: true,
            title: Text(
              'شبكات الواي فاي',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
              onPressed: () => context.pop(),
            ),
            bottom: TabBar(
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: theme.colorScheme.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
              tabs: const [
                Tab(text: 'الشبكات المتاحة'),
                Tab(text: 'المفضلة'),
              ],
            ),
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          body: _favoritesLoaded
              ? TabBarView(
                  children: [
                    _buildWifiListStream(theme, favoritesOnly: false),
                    _buildWifiListStream(theme, favoritesOnly: true),
                  ],
                )
              : const Center(child: CustomLoadingIndicator()),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              context.push(AppRoutes.addPrivateNetwork);
            },
            icon: const Icon(Icons.wifi_tethering),
            label: const Text(
              'أضف شبكتك',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWifiListStream(ThemeData theme, {required bool favoritesOnly}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('networks')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CustomLoadingIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'خطأ في تحميل الشبكات',
              style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'Cairo'),
            ),
          );
        }

        final List<Map<String, dynamic>> allNetworks = [];

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            allNetworks.add({
              'id': doc.id,
              'name': data['name'] ?? 'شبكة جديدة',
              'location': '${data['city'] ?? ''} - ${data['area'] ?? ''}',
              'description':
                  data['description'] ??
                  'شبكة محلية لتغطية فائقة السرعة وكروت مميزة',
              'ownerName': data['ownerName'] ?? 'مالك الشبكة',
              'whatsapp': data['whatsapp'] ?? '',
              'isFavorite': _favoriteIds.contains(doc.id),
            });
          }
        }

        final filtered = favoritesOnly
            ? allNetworks.where((n) => n['isFavorite'] == true).toList()
            : allNetworks;

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  favoritesOnly
                      ? Icons.favorite_border
                      : Icons.wifi_off_rounded,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 10),
                Text(
                  favoritesOnly
                      ? 'لا توجد شبكات في مفضلتك بعد'
                      : 'لا توجد شبكات متاحة حالياً\nيمكنك إضافة شبكتك من القائمة',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[400],
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (context, index) =>
              _buildWifiCard(filtered[index], theme),
        );
      },
    );
  }

  Widget _buildWifiCard(Map<String, dynamic> network, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final isFav = _favoriteIds.contains(network['id'].toString());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isDark
            ? Border.all(color: theme.dividerColor.withValues(alpha: 0.05))
            : null,
      ),
      child: ListTile(
        onTap: () => context.push(AppRoutes.wifiNetworkDetails, extra: network),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.wifi, color: theme.colorScheme.primary, size: 24),
        ),
        title: Text(
          network['name'],
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
        subtitle: Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 12,
              color: Colors.grey,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                network['location'],
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontFamily: 'Cairo',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'متاح',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.red : Colors.grey[400],
              ),
              onPressed: () async {
                await _toggleFavorite(network['id'].toString());
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFav
                            ? 'تمت الإزالة من المفضلة'
                            : 'تمت الإضافة للمفضلة',
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
