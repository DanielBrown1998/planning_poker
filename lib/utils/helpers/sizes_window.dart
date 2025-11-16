enum SizeWindow { small, medium, large }

int smallWindowMaxWidth = 400;
int mediumWindowMaxWidth = 700;

SizeWindow getSizeWindow(double width) {
  if (width < smallWindowMaxWidth) {
    return SizeWindow.small;
  } else if (width >= smallWindowMaxWidth && width < mediumWindowMaxWidth) {
    return SizeWindow.medium;
  } else {
    return SizeWindow.large;
  }
}

bool isTall(double height) {
  return height > 900;
}

bool isMedium(double height) {
  return height <= 900 && height > 720;
}

bool isShort(double height) {
  return height <= 720;
}

bool isLargeWindow(double width) {
  return width >= mediumWindowMaxWidth;
}

bool isMediumWindow(double width) {
  return width >= smallWindowMaxWidth && width < mediumWindowMaxWidth;
}

bool isSmallWindow(double width) {
  return width < smallWindowMaxWidth;
}
