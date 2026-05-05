import 'package:flutter/material.dart';

class WifiNetworksScreen extends StatefulWidget {
  static const String id = 'wifi_networks_screen';
  const WifiNetworksScreen({super.key});

  @override
  State<WifiNetworksScreen> createState() => _WifiNetworksScreenState();
}

class _WifiNetworksScreenState extends State<WifiNetworksScreen> {
  final List<Map<String, dynamic>> _allNetworks = [
    {
      'id': 1,
      'name': 'Yemen_4G_Free',
      'location': 'شارع جمال - بجانب شركة النفط',
      'isFavorite': false,
    },
    {
      'id': 2,
      'name': 'Taiz_Net_High',
      'location': 'حي المسبح - عمارة الشريف',
      'isFavorite': true,
    },
    {
      'id': 3,
      'name': 'Al-Saeed_Wifi',
      'location': 'عصيفرة - سوق القات الجديد',
      'isFavorite': false,
    },
    {
      'id': 4,
      'name': 'Saba_Gate_5G',
      'location': 'بوابة تعز - الحوبان',
      'isFavorite': false,
    },
    {
      'id': 5,
      'name': 'Sky_Link_Net',
      'location': 'شارع 26 سبتمبر - الدور الثاني',
      'isFavorite': false,
    },
    {
      'id': 6,
      'name': 'Al-Tahrir_Speed',
      'location': 'وسط التحرير - سوق الصميل',
      'isFavorite': true,
    },
    {
      'id': 7,
      'name': 'Education_Free',
      'location': 'جامعة تعز - حبيل سلمان',
      'isFavorite': false,
    },
    {
      'id': 8,
      'name': 'Golden_Wifi',
      'location': 'شارع الستين - محطة القمامة',
      'isFavorite': false,
    },
    {
      'id': 9,
      'name': 'Hospital_Public',
      'location': 'مستشفى الثورة - قسم الطوارئ',
      'isFavorite': false,
    },
    {
      'id': 10,
      'name': 'Dream_Net_2026',
      'location': 'بئر باشا - جولة الصقر',
      'isFavorite': false,
    },
    {
      'id': 11,
      'name': 'Flash_Connect',
      'location': 'وادي القاضي - حارة النور',
      'isFavorite': false,
    },
    {
      'id': 12,
      'name': 'Smart_Taiz',
      'location': 'حي الروضة - بجانب الجامع',
      'isFavorite': false,
    },
  ];

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
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
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
          body: TabBarView(
            children: [
              _buildWifiList(_allNetworks, theme),
              _buildWifiList(
                _allNetworks.where((n) => n['isFavorite'] == true).toList(),
                theme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWifiList(List<Map<String, dynamic>> networks, ThemeData theme) {
    if (networks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text(
              'لا توجد شبكات متاحة حالياً',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: networks.length,
      itemBuilder: (context, index) {
        return _buildWifiCard(networks[index], theme);
      },
    );
  }

  Widget _buildWifiCard(Map<String, dynamic> network, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.wifi, color: theme.colorScheme.primary, size: 24),
        ),
        title: Text(
          network['name'],
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                network['location'],
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            network['isFavorite'] ? Icons.favorite : Icons.favorite_border,
            color: network['isFavorite'] ? Colors.red : Colors.grey[400],
          ),
          onPressed: () {
            setState(() {
              final originalIndex = _allNetworks.indexWhere(
                (n) => n['id'] == network['id'],
              );
              if (originalIndex >= 0) {
                _allNetworks[originalIndex]['isFavorite'] =
                    !_allNetworks[originalIndex]['isFavorite'];
              }
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  network['isFavorite']
                      ? 'تمت الإزالة من المفضلة'
                      : 'تمت الإضافة للمفضلة',
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                backgroundColor: theme.colorScheme.primary,
              ),
            );
          },
        ),
      ),
    );
  }
}
