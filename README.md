# janet-profiling

## dependencies
janet

## installation

```
jpm install https://github.com/Saikyun/janet-profiling
```

## basic usage

start a repl by running `janet`

```clojure
(use profiling/profile)
(p :measure (ev/sleep 0.1))
(p :inner (ev/sleep 0.5))
(p :measure
   (do (ev/sleep 0.1) 
       (p :inner (ev/sleep 0.5))))
(print-results)
# results
k              total    no inner    avg      no inner    total  no inner   nof calls
:all/inner     1.00129  <-          0.50065  0.50065     58.85% <-         2
:inner         0.50065  <-          0.50065  <-          29.43% <-         1
:measure       0.70010  0.19945     0.35005  0.09973     41.15% 11.72%     2
  :inner       0.50065  <-          0.50065  <-          29.43% <-         1
:all/measure   0.70010  0.19945     0.35005  0.09973     41.15% 11.72%     2
nil
```

## example

look at [example.janet](./example.janet)

```
git clone https://github.com/Saikyun/janet-profiling
cd janet-profiling
janet example.janet
# results
k                          total    no inner    avg      no inner    total  no inner   nof calls
:all/very-long-name-yeah   0.40071  0.20037     0.40071  0.20037     26.07% 13.04%     1
:all/aa                    0.20036  <-          0.20036  0.20036     13.04% <-         1
:aa                        0.20036  <-          0.20036  <-          13.04% <-         1
:all/also-long-name-yeah   0.20034  <-          0.20034  0.20034     13.04% <-         1
:all/slow-adder            0.20034  <-          0.20034  0.20034     13.04% <-         1
:slow-adder                0.20034  <-          0.20034  <-          13.04% <-         1
:all/bb123                 0.53501  0.13430     0.53501  0.13430     34.81% 8.74%      1
:bb123                     0.53501  0.13430     0.53501  0.13430     34.81% 8.74%      1
  :very-long-name-yeah     0.40071  0.20037     0.40071  0.20037     26.07% 13.04%     1
    :also-long-name-yeah   0.20034  <-          0.20034  <-          13.04% <-         1
```
