import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/forklift_service.dart';
import 'new_order.dart';
import 'forklift_list.dart';
import 'about.dart';
import 'package:intl/intl.dart';

class DaftarUnit extends StatefulWidget {
  const DaftarUnit({super.key});

  @override
  State<DaftarUnit> createState() => _DaftarUnitState();
}

class _DaftarUnitState extends State<DaftarUnit>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _forklifts = [];
  bool _isLoading = true;
  String? _error;
  late PageController _pageController;
  int _currentPage = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Simplified color scheme
  final Color primaryDark = const Color(0xFF1A1D29);
  final Color accentPink = const Color(0xFFE91E63);
  final Color accentPurple = const Color(0xFF9C27B0);
  final Color lightGray = const Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9); // Make it wider

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _loadAvailableForklifts();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableForklifts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final forklifts = await ForkliftService.getAvailableForklifts();
      setState(() {
        _forklifts = forklifts;
        _isLoading = false;
      });
      _fadeController.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startAutoSlide() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _forklifts.isNotEmpty && _pageController.hasClients) {
        _currentPage = (_currentPage + 1) % _forklifts.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
        _startAutoSlide();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryDark,
              const Color(0xFF2D1B69),
              accentPurple.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildEnhancedAppBar(),
              Expanded(
                child: _isLoading
                    ? _buildSimpleLoadingState()
                    : _error != null
                        ? _buildSimpleErrorState()
                        : RefreshIndicator(
                            onRefresh: _loadAvailableForklifts,
                            color: accentPink,
                            child: _forklifts.isEmpty
                                ? _buildSimpleEmptyState()
                                : _buildMainContent(),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Enhanced back button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 20),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const About()),
                );
              },
            ),
          ),
          const SizedBox(width: 16),

          // Enhanced title section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daftar Unit',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Lihat daftar unit forklift yang tersedia',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Stats badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentPink, accentPurple],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: accentPink.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              '${_forklifts.length} Unit',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(accentPink),
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Memuat data forklift...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 24),
            Text(
              'Terjadi kesalahan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Error tidak diketahui',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loadAvailableForklifts,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentPink,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.white54,
          ),
          const SizedBox(height: 24),
          Text(
            'Tidak ada unit tersedia',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Silakan coba lagi nanti',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildHeader(),
            const SizedBox(height: 40),
            _buildMainCard(),
            const SizedBox(height: 40),
            _buildFeatures(),
            const Spacer(),
            _buildCTAButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'FORKLIFT KITA',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (index) => Container(
              width: 16,
              height: 4,
              margin: EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: accentPink,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Sewa Forklift terbaik untuk bisnis anda. Bandingkan Penawaran harga Forklift dari berbagai supplier terbaik. Belanja Order Unit dengan Mudah.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMainCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: lightGray,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Forklift Kita',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: primaryDark,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 300, // Adjusted height for a larger image
                child: _buildCarousel(),
              ),
              if (_forklifts
                  .isNotEmpty) // Only show arrows if there are forklifts
                Positioned(
                  left: 0,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: primaryDark),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                  ),
                ),
              if (_forklifts
                  .isNotEmpty) // Only show arrows if there are forklifts
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward_ios, color: primaryDark),
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _forklifts.length,
            itemBuilder: (context, index) {
              final forklift = _forklifts[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[100],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: forklift['gambar'] != null
                                ? CachedNetworkImage(
                                    imageUrl:
                                        'http://10.0.0.8:3000/images/${forklift['gambar']}',
                                    fit: BoxFit
                                        .contain, // Changed to contain for better visibility
                                    placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.forklift,
                                      size:
                                          50, // Larger icon for error/placeholder
                                      color: Colors.grey,
                                    ),
                                  )
                                : Icon(
                                    Icons.forklift,
                                    size: 50, // Larger icon for placeholder
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        forklift['nama_unit'] ?? '-',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16, // Larger font size
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4), // Increased padding
                        decoration: BoxDecoration(
                          color: forklift['status'] == 'tersedia'
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          forklift['status'] == 'tersedia'
                              ? 'Tersedia'
                              : 'Disewa',
                          style: TextStyle(
                            color: forklift['status'] == 'tersedia'
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 12, // Larger font size
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${forklift['kapasitas']} ton',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        'Rp ${formatRupiah(forklift['harga_per_jam'])}/jam',
                        style: TextStyle(
                          color: accentPink,
                          fontWeight: FontWeight.bold,
                          fontSize: 14, // Larger font size
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _forklifts.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: _currentPage == index ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == index ? accentPink : Colors.grey[400],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFeatureItem(Icons.schedule, 'Sewa\nFleksibel'),
          _buildFeatureItem(Icons.attach_money, 'Harga\nKompetitif'),
          _buildFeatureItem(Icons.verified, 'Unit\nTerawat'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accentPink.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 24,
            color: accentPink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCTAButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accentPink, accentPurple],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: accentPink.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 18),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ForkliftList(),
              ),
            );
          },
          child: const Text(
            'Ingin melakukan pemesanan?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String formatRupiah(dynamic harga) {
    final intHarga = int.tryParse(harga.toString()) ?? 0;
    return NumberFormat('#,###', 'id_ID').format(intHarga);
  }
}
