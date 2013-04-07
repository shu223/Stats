##What's "Stats"

"Stats" is a class to display set of parameters that indicate the load status (such as memory usage, the number of UIView subclasses, etc…) **in app**.

- [Tutorial in English](http://d.hatena.ne.jp/shu223/20111118/1321576538)
- [Tutorial in Japanese](http://d.hatena.ne.jp/shu223/20110428/1303930059)


##Parameters and the units

From top to bottom,

- The variation of memory usage [kB]
- The total memory usage [kB]
- The variation of CPU time [msec]
- The number of UIView subclasses


##How to use

1. Add Stats.h, Stats.m to your project
2. Import Stats.h
3. As with UILabel, add wherever you like.

A full Xcode demo project is included in the "StatsDemo" directory..
