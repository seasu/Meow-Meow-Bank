# Animation Recipes — Flutter Tinder-Style UI

## Spring-Back Card
```dart
final spring = SpringDescription(mass: 1, stiffness: 300, damping: 20);
_controller.animateWith(SpringSimulation(spring, currentOffset, 0, velocity));
```

## Pulse Effect
```dart
_controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
  ..repeat(reverse: true);
_scale = Tween(begin: 1.0, end: 1.15).animate(
  CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
);
```

## Staggered List Entry
```dart
final delay = index * 0.1;
final value = Interval(delay, delay + 0.4, curve: Curves.easeOut);
```
