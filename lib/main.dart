import 'package:flutter/material.dart';
import 'dart:async'; 
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Thay 'pressStart2pTextTheme' bằng phông mày muốn
        textTheme: GoogleFonts.pressStart2pTextTheme(), 
      ),
      home: PeakClimber(),
    ));

class PeakClimber extends StatefulWidget {
  @override
  _PeakClimberState createState() => _PeakClimberState();
}

class _PeakClimberState extends State<PeakClimber> {
  int _seconds = 1500; // 25 phút x 60 giây
  Timer? _timer;
  double _climberPositionRatioX = 0.5; // 0.5 là chính giữa màn hình
  double _climberPositionRatioY = 0.99; // 0.8 là gần đáy màn hình
  bool _isClimbing = false;
  bool _isFinished = false;

  void _startTimer() {
    setState(() => _isClimbing = true);
    
    // Đổi thành 50 mili giây (mỗi giây chạy 20 lần cho nó mượt)
    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      setState(() {
        if (_seconds > 0) {
          // Cứ sau 20 lần chạy (50 * 50ms = 1000ms) thì mới trừ 1 giây đồng hồ
          if (timer.tick % 50 == 0) {
            _seconds--;
          }

          // NGƯỜI LEO: Trừ số cực nhỏ để nó trượt đi từ từ
          if (_climberPositionRatioY > 0.05) {
            _climberPositionRatioY -= (0.7 / (1500 * 20));
          }

          // LỰỜN LÁCH THEO ĐƯỜNG CONG
          if (_climberPositionRatioY <= 0.75 && _climberPositionRatioY > 0.6) {
            _climberPositionRatioX -= 0.000005; 
          } 
          // Khúc cua 2: Cua gắt sang phải
          else if (_climberPositionRatioY <= 0.6 && _climberPositionRatioY > 0.45) {
            _climberPositionRatioX += 0.0002;
          }
          // Khúc cua 3: Cua ngược lại sang trái
          else if (_climberPositionRatioY <= 0.45 && _climberPositionRatioY > 0.3) {
            _climberPositionRatioX -= 0.0003;
          }
          // Khúc cua 4: Đoạn thẳng cuối cùng lên đỉnh
          else if (_climberPositionRatioY <= 0.3) {
            _climberPositionRatioX += 0.0001;
          }
        } else {
          _timer?.cancel();
          _isClimbing = false;
          _isFinished = true; //hiện màn hình chúc mừng
        }
      });
    });
  }
  // Hàm dừng và reset đồng hồ
  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isClimbing = false;
      _seconds = 1500; // Reset về 25 phút
    });
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E3192), // Màu xanh tím than ở trên
              Color(0xFF1BFFFF), // Màu xanh cyan ở dưới
            ],
          ),
        ),
        child: Stack(
          children: [
            // Lớp 1: Con đường mòn (Nền)
            Positioned.fill(
              child: Opacity(
                opacity: 0.4,
                child: Image.asset('assets/trail@2x.png', fit: BoxFit.contain),
              ),
            ),
            
            // Lớp 2: Người leo núi
            Align(
              alignment: Alignment(
                (_climberPositionRatioX * 2) - 1, 
                (_climberPositionRatioY * 2) - 1,
              ),
              child: Image.asset(
                'assets/adventurer.png',
                width: 70, 
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.person, color: Colors.white, size: 50),
              ),
            ),

            // Lớp 3: Nội dung chính (Đồng hồ & Nút bấm)
            Center(
              child: _isFinished
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.stars, color: Colors.yellow, size: 100),
                        const SizedBox(height: 20),
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(seconds: 1),
                          builder: (context, double value, child) {
                            return Transform.translate(
                              offset: Offset(sin(DateTime.now().millisecondsSinceEpoch / 50) * 3, 0),
                              child: Text(
                                "CONGRATULATION!",
                                style: GoogleFonts.pressStart2p(
                                  fontSize: 24,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 15 + (sin(DateTime.now().millisecondsSinceEpoch / 200) * 10),
                                      color: Colors.yellowAccent,
                                      offset: const Offset(0, 0),
                                    ),
                                    Shadow(
                                      blurRadius: 25 + (sin(DateTime.now().millisecondsSinceEpoch / 200) * 15),
                                      color: Colors.orange,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        
                        Text(
                          "u reached the flow state",
                          style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 20,
                              fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                          onPressed: () => setState(() {
                            _isFinished = false;
                            _climberPositionRatioY = 0.99;
                            _climberPositionRatioX = 0.5;
                            _seconds = 1500;
                          }),
                          child: const Text("replay", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "THE PEAK VL CLIMBER",
                          style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 2),
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          _formatTime(_seconds),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 65,
                              fontWeight: FontWeight.w200),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isClimbing ? Colors.grey : Colors.orange,
                              ),
                              onPressed: _isClimbing ? null : _startTimer,
                              child: Text(_isClimbing ? "OTW" : "START"),
                            ),
                            if (_isClimbing) ...[
                              const SizedBox(width: 20),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent),
                                onPressed: _stopTimer,
                                child: const Text("STOP"),
                              ),
                            ]
                          ],
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
            ),
          ],
        ),
      ), // Đóng Container
    ); // Đóng Scaffold
  }
}