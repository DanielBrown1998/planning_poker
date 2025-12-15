import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planning_poker/model/choices.dart';
import 'package:planning_poker/view/components/app_bar_planning_poker.dart';
import 'package:planning_poker/view/components/card.dart';
import 'package:planning_poker/view/components/table.dart';
import 'package:planning_poker/viewmodel/home_viewmodel.dart';
import 'package:planning_poker/utils/helpers/sizes_window.dart';
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
  late final HomeViewModel viewModel;
  late final Stream<List<ChoiceAndUser>> _partnersChoicesStream;
  late final StreamSubscription<List<ChoiceAndUser>>
  _partnersChoicesSubscriptionListener;

  //Mock Reference to store choices by partners
  List<ChoiceAndUser> choicesByPartners = [];

  @override
  void initState() {
    super.initState();
    // Initialize CarouselController and AnimationController
    _carouselController = CarouselSliderController();
    _animationController = AnimationController(vsync: this, duration: duration);

    // Initialize HomeViewModel
    viewModel = context.read<HomeViewModel>();
    // Listen to changes in HomeViewModel
    viewModel.addListener(() {
      setState(() {});
    });

    _partnersChoicesStream = viewModel
        .partnersChoicesRepository
        .partnersChoicesStreamController
        .stream;

    _partnersChoicesSubscriptionListener = _partnersChoicesStream.listen((
      choiceAndUser,
    ) {
      // Handle incoming partner choices here
      viewModel.insertChoiceInCardsFromPartners(choiceAndUser);
      setState(() {});
    });

    //Mocked function to simulate getting choices from partners
    viewModel.getChoicesByPartners(8).listen((choiceAndUser) {
      choicesByPartners.add(choiceAndUser);
      viewModel.partnersChoicesStreamController.sink.add(choicesByPartners);
    });
    // Add WidgetsBinding observer

    WidgetsBinding.instance.addObserver(this);
    // Animate opacityText after a short delay
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    viewModel.removeListener(() {
      setState(() {});
    });
    _partnersChoicesSubscriptionListener.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void reassemble() {
    super.reassemble();
    viewModel.resetState();
    // ignore: invalid_use_of_protected_member
    if (!viewModel.hasListeners) {
      viewModel.addListener(() => setState(() {}));
    }
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final appBarHeight = size.height * 0.2;
    // final widthWindowIsLarge = isLargeWindow(size.width);
    // final widthWindowIsMedium = isMediumWindow(size.width);

    final sizeWindow = getSizeWindow(size.width);
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
        colorBase: Colors.green.withAlpha(200),
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
                        Colors.green.withAlpha(200),
                        Colors.green.withAlpha(200),
                        Colors.green.withAlpha(200),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned.directional(
                textDirection: TextDirection.ltr,
                width: size.width,
                height: size.height * .5,
                top: 30,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: StreamBuilder(
                    initialData: choicesByPartners,
                    stream: _partnersChoicesStream,

                    builder: (context, snapshot) {
                      final tableCache = TablePoker(
                        cards: viewModel.cardsFromPartners,
                      );
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.white.withAlpha(200),
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return tableCache;
                        }
                        if (!snapshot.hasData ||
                            snapshot.data == null ||
                            snapshot.data!.isEmpty) {
                          return tableCache;
                        }
                        viewModel.insertChoiceInCardsFromPartners(
                          snapshot.data!,
                        );
                        return tableCache;
                      }
                      return tableCache;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 36.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 0,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_drop_down_sharp,
                        color: viewModel
                            .optionsCardsPoker[viewModel.choicedTime]
                            .colorCard
                            .withAlpha(200),
                        size: 35,
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: isTall(size.height)
                              ? 240
                              : (isMedium(size.height) ? 200 : 160),
                        ),
                        child: CarouselSlider(
                          key: ValueKey<String>('carousel_cards'),
                          items: List.generate(
                            viewModel.optionsCardsPoker.length,
                            (index) {
                              return Draggable<CardPoker>(
                                onDragCompleted: () {},
                                affinity: Axis.vertical,
                                rootOverlay: true,
                                axis: Axis.vertical,
                                childWhenDragging:
                                    viewModel.optionsCardsPoker[index],
                                feedback: SizedBox(
                                  height: size.width * .3,
                                  width: size.width * .225,
                                  child: viewModel.optionsCardsPoker[index],
                                ),
                                data: viewModel.optionsCardsPoker[index],
                                child: viewModel.optionsCardsPoker[index],
                              );
                            },
                          ),
                          carouselController: _carouselController,
                          options: CarouselOptions(
                            height: size.height * 0.625,
                            animateToClosest: true,
                            enlargeCenterPage: sizeWindow == SizeWindow.large
                                ? false
                                : true,
                            enableInfiniteScroll: true,
                            initialPage: 0,
                            viewportFraction: sizeWindow == SizeWindow.large
                                ? .3
                                : (sizeWindow == SizeWindow.medium ? .35 : .4),
                            aspectRatio: 1 / (size.height / size.width),
                            scrollDirection: Axis.horizontal,
                            scrollPhysics: const BouncingScrollPhysics(),
                            autoPlay: false,
                            onPageChanged: (index, reason) {
                              viewModel.flipCardAtIndex(
                                index,
                                viewModel.choicedTime,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
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
