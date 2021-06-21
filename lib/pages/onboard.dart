import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:klinix/ui/widgets/swiper_pagination.dart';

class OnboardPage extends StatefulWidget {
  @override
  _OnboardPageState createState() => _OnboardPageState();
}

class _OnboardPageState extends State<OnboardPage> {
  final SwiperController _swiperController = SwiperController();
  final int _pageCount = 3;
  int _currentIndex = 0;
  final List<String> titles = ["", "", ""];
  final List<String> images = [
    "assets/images/onboarding1.png",
    "assets/images/onboarding2.png",
    "assets/images/onboarding3.png"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Expanded(
              child: Swiper(
            index: _currentIndex,
            controller: _swiperController,
            itemCount: _pageCount,
            onIndexChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            loop: false,
            itemBuilder: (context, index) {
              return _buildPage(title: titles[index], icon: images[index]);
            },
            pagination: SwiperPagination(
                builder: CustomPaginationBuilder(
                    activeColor: Variables.primaryColor,
                    activeSize: Size(10.0, 20.0),
                    size: Size(10.0, 15.0),
                    color: Colors.grey.shade600)),
          )),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Container(
      margin: const EdgeInsets.only(right: 16.0, bottom: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TextButton(
            style: TextButton.styleFrom(primary: Variables.primaryColor),
            child: Text("Atla"),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
          ),
          IconButton(
            color: Variables.primaryColor,
            icon: Icon(
              _currentIndex < _pageCount - 1
                  ? Icons.navigate_next_sharp
                  : Icons.check_circle_sharp,
              size: 40,
            ),
            onPressed: () async {
              if (_currentIndex < _pageCount - 1)
                _swiperController.next();
              else {
                Navigator.of(context).pushReplacementNamed('/home');
              }
            },
          )
        ],
      ),
    );
  }

  Widget _buildPage({String title, String icon}) {
    final TextStyle titleStyle =
        TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 40.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          image: DecorationImage(
            image: AssetImage(icon),
            fit: BoxFit.cover,
            //colorFilter: ColorFilter.mode(Colors.black38, BlendMode.multiply)
          )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            title,
            textAlign: TextAlign.center,
            style: titleStyle.copyWith(color: Variables.primaryColor),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
