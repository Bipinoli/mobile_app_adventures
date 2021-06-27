import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


void main() {
  runApp(CustomDrawerApp());
}

class CustomDrawerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CustomDrawer()
    );
  }
}

class CustomDrawer extends StatefulWidget {
  @override
  _CustomSliderState createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomDrawer> with SingleTickerProviderStateMixin {
  final heightShrinkFactor = 0.7; // of total height
  final maxHorizTranslateFactor = 0.4; // of total width

  late AnimationController controller;
  late Animation animation;

  bool colorSwitched = false;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void handleButtonPress() {
    controller.isDismissed ? controller.forward(): controller.reverse();
  }

  void handleColorChange() {
    setState(() {
      colorSwitched = !colorSwitched;
    });
  }

  double mix(double lo, double hi, double percent) {
    return lo + (hi - lo) * percent;
  }

  Color _getFrontWidgetColor() => colorSwitched ? Colors.greenAccent: Colors.lightBlue;
  Color _getBackWidgetColor() => colorSwitched ? Colors.lightBlue: Colors.greenAccent;

  Widget _buildColorSwitcherWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FloatingActionButton(
          backgroundColor: _getFrontWidgetColor(),
          onPressed: handleColorChange,
        )
      ),
    );
  }

  Widget _backContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _getBackWidgetColor(),
      ),
      child: _buildColorSwitcherWidget(context),
    );
  }

  Widget _backContainerWithTexture(BuildContext context, ui.Image texture) {
    return Stack(
      children: [
        ShaderMask(
          blendMode: BlendMode.multiply,
          shaderCallback: (rect) => ImageShader(texture,
              TileMode.mirror, TileMode.mirror, Matrix4.identity().storage),
          child: Container(
              decoration: BoxDecoration(
                color: _getBackWidgetColor(),
              ),
        )),
        _buildColorSwitcherWidget(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(
          children: [
            FutureBuilder(
              future: loadTextureImage(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _backContainer(context);
                }
                final ui.Image image = snapshot.data as ui.Image;
                return _backContainerWithTexture(context, image);
              },
            ),
            AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                final screenWidth = MediaQuery.of(context).size.width;
                final screenHeight = MediaQuery.of(context).size.height;
                final offsetX = screenWidth * maxHorizTranslateFactor * animation.value;
                final height =  mix(screenHeight, screenHeight * heightShrinkFactor, animation.value);
                final width = height * (screenWidth / screenHeight);
                return Positioned(
                  left: offsetX,
                  bottom: (screenHeight - height)/2,
                  child: Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      color: _getFrontWidgetColor(),
                      borderRadius: BorderRadius.all(Radius.circular(32.0 * animation.value)),
                    ),
                  ),
                );
              },
            ),
            Positioned(
                bottom: 32,
                right: 32,
                child: FloatingActionButton(
                  backgroundColor: Color(0xFFFFD166),
                    onPressed: handleButtonPress)
            ),
          ],
        )
    );
  }
}


Future<ui.Image> loadTextureImage() async {
  final bytes = await rootBundle.load("assets/images/wave_texture.jpg");
  return decodeImageFromList(bytes.buffer.asUint8List());
}

