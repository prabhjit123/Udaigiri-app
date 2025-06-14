import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'sections/profile_page.dart'; // Adjust path as needed

// --- Custom Drawer Widget ---
class CustomDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final drawerItems = [
      [Icons.dashboard_rounded, "Dashboard"],
      [Icons.build_circle_rounded, "Maintenance"],
      [Icons.restaurant_menu_rounded, "Mess"],
      [Icons.person_rounded, "My Profile"],
      [Icons.groups_rounded, "Meet the Team"],
      [Icons.report_problem_rounded, "Report"],
    ];

    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: Color(0xFF16A085),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 48),
          // Logo at the top (replace with your AssetImage if needed)
          CircleAvatar(
            radius: 44,
            backgroundColor: Colors.transparent,
            child: Image.asset(
              'assets/images/udaigiri_logo.png', // Replace with your logo
              height: 80,
              width: 80,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 36),
          // Drawer menu items
          Expanded(
            child: ListView.builder(
              itemCount: drawerItems.length,
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {
                        onItemSelected(index);
                        Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(left: 8, right: 16),
                        decoration: isSelected
                            ? BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              )
                            : null,
                        child: ListTile(
                          leading: Icon(
                            drawerItems[index][0] as IconData,
                            color: isSelected
                                ? const Color(0xFF16A085)
                                : Colors.white,
                          ),
                          title: Text(
                            drawerItems[index][1] as String,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF16A085)
                                  : Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 0),
                          minLeadingWidth: 32,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// --- Main Dashboard Page ---
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final user = FirebaseAuth.instance.currentUser;
  int _drawerSelected = 0;

  final List<String> showcaseImages = [
    'assets/images/showcase1.jpg',
    'assets/images/showcase2.jpg',
    'assets/images/showcase3.jpg',
  ];

  int _currentIndex = 0; // For carousel indicator

  Widget buildShowcaseCarousel() {
    if (showcaseImages.isEmpty) {
      return Container(
        height: 140,
        alignment: Alignment.center,
        child: const Text('No images available',
            style: TextStyle(color: Colors.grey)),
      );
    }
    return Column(
      children: [
        CarouselSlider(
          items: showcaseImages.map((imgPath) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                imgPath,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            );
          }).toList(),
          options: CarouselOptions(
            height: 140,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            enlargeCenterPage: true,
            viewportFraction: 1,
            enableInfiniteScroll: true,
            scrollPhysics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: showcaseImages.asMap().entries.map((entry) {
            return Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == entry.key
                    ? const Color(0xFF16A085)
                    : const Color(0xFFB0B3D1),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _quickAction({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 90,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF222B45),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double quickActionSpacing =
        MediaQuery.of(context).size.width > 400 ? 24 : 14;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF8F3),
      drawer: CustomDrawer(
        selectedIndex: _drawerSelected,
        onItemSelected: (index) async {
          setState(() => _drawerSelected = index);
          Navigator.pop(context);
          await Future.delayed(const Duration(milliseconds: 250));
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfilePage()),
            );
          }
          // Add navigation for other indices as needed
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF222B45)),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          ),
        ),
        title: null,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF222B45)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info row
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.amberAccent,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    radius: 22,
                    child: user?.photoURL == null
                        ? Text(
                            (user?.displayName ?? 'U').toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 22,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    user?.displayName ?? 'User',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF222B45),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Showcase carousel with indicator
              buildShowcaseCarousel(),
              const SizedBox(height: 28),

              // Quick Actions centered and bold
              const Text(
                "QUICK ACTIONS",
                style: TextStyle(
                  color: Color(0xFF222B45),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _quickAction(
                      icon: Icons.build_circle_rounded,
                      color: Colors.orange,
                      label: "Maintenance Issue",
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Maintenance Issue tapped')),
                        );
                      },
                    ),
                    SizedBox(width: quickActionSpacing),
                    _quickAction(
                      icon: Icons.restaurant_menu_rounded,
                      color: Colors.teal,
                      label: "My Mess",
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('My Mess tapped')),
                        );
                      },
                    ),
                    SizedBox(width: quickActionSpacing),
                    _quickAction(
                      icon: Icons.warning_rounded,
                      color: Colors.red,
                      label: "Emergency",
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Emergency tapped')),
                        );
                      },
                    ),
                    SizedBox(width: quickActionSpacing),
                    _quickAction(
                      icon: Icons.psychology_rounded,
                      color: Colors.purple,
                      label: "Counselling",
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Counselling tapped')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Notifications & Circulars
              const Text(
                "NOTIFICATIONS & CIRCULARS",
                style: TextStyle(
                  color: Color(0xFF8F9BB3),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    _notificationTile(
                      name: "Maintenance Update",
                      detail: "Water supply will be off 2-4 PM today.",
                      icon: Icons.build,
                      color: Colors.orange,
                    ),
                    _notificationTile(
                      name: "New Circular",
                      detail: "Hostel night registration open.",
                      icon: Icons.event,
                      color: Colors.purple,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notificationTile({
    required String name,
    required String detail,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 22),
            radius: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF222B45),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(
                    color: Color(0xFF8F9BB3),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
