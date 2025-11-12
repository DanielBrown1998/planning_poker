import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planning_poker/ui/components/app_bar_planning_poker.dart';
// import 'package:planning_poker/ui/components/card.dart';
import 'package:planning_poker/ui/state/home_state.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final duration = const Duration(milliseconds: 400);
  late final CarouselSliderController _carouselController;
  late final AnimationController _animationController;
  late final HomeState homeState;
  late Color colorBase;
  @override
  void initState() {
    super.initState();
    // Initialize CarouselController and AnimationController
    _carouselController = CarouselSliderController();
    _animationController = AnimationController(vsync: this, duration: duration);

    // Initialize HomeState
    homeState = context.read<HomeState>();
    homeState.initialize();
    // Listen to changes in HomeState
    homeState.addListener(() {
      setState(() {});
    });
    colorBase = homeState.colorsCards[homeState.choicedTime];
    // Add WidgetsBinding observer
    WidgetsBinding.instance.addObserver(this);
    // Animate opacityText after a short delay
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    homeState.removeListener(() {});
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void reassemble() {
    super.reassemble();
    homeState.reset();
    homeState.addListener(() => setState(() {}));
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final appBarHeight = size.height * 0.2;

    return Scaffold(
      appBar: AppBarPlanningPoker(
        title: FittedBox(
          fit: BoxFit.fill,
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: 42,
              color: Colors.white70,
              fontFamily: GoogleFonts.playfairDisplay().fontFamily,
            ),
          ),
        ),
        colorBase: colorBase,
        animationController: _animationController,
        height: appBarHeight,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: AnimatedContainer(
                  duration: duration,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colorBase.withAlpha(20),
                        colorBase.withAlpha(50),
                        colorBase.withAlpha(130),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.directional(
                textDirection: TextDirection.ltr,
                width: size.width,
                height: size.height * .15,
                top: 30,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: duration,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset.zero,
                              end: const Offset(0.0, 0.5),
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        homeState.actualDescriptionCard,
                        //to ensure the AnimatedSwitcher detects changes
                        key: ValueKey<String>(homeState.actualDescriptionCard),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          color: colorBase,
                          fontFamily: GoogleFonts.rubik().fontFamily,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 36.0),

                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 500),
                    child: CarouselSlider(
                      items: List.generate(homeState.valueCards.length, (
                        index,
                      ) {
                        return homeState.cardsPoker[index];
                      }),
                      carouselController: _carouselController,
                      options: CarouselOptions(
                        height: size.height * 0.6,
                        animateToClosest: true,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: true,
                        initialPage: 0,
                        aspectRatio: 1 / (size.height / size.width),
                        scrollDirection: Axis.horizontal,
                        scrollPhysics: const BouncingScrollPhysics(),
                        autoPlay: false,
                        onPageChanged: (index, reason) {
                          homeState.updateBaseTime(
                            homeState.cardsPoker[index].cardValue,
                          );
                          colorBase = homeState.updateColor(
                            homeState.cardsPoker[index].cardValue,
                          );
                          homeState.flipCardAtIndex(index);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
