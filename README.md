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
(p :measure
   (do (ev/sleep 0.1) 
       (p :inner (ev/sleep 0.5))))
(print-results)
#=># results
k              total    no inner    avg      no inner    total  no inner   nof calls
:all/inner     0.50057  <-          0.50057  TBI         41.66% <-         1
:measure       0.70103  0.20046     0.35052  -0.15005    58.34% 16.68%     2
  :inner       0.50057  <-          0.50057  <-          41.66% <-         1
:all/measure   0.70103  0.20046     0.35052  TBI         58.34% 16.68%     2
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
:all/very-long-name-yeah   0.40073  0.20040     0.40073  TBI         26.08% 13.04%     1
:slow-adder                0.20035  <-          0.20035  <-          13.04% <-         1
:all/slow-adder            0.20035  <-          0.20035  TBI         13.04% <-         1
:all/also-long-name-yeah   0.20033  <-          0.20033  TBI         13.04% <-         1
:aa                        0.20028  <-          0.20028  <-          13.03% <-         1
:all/aa                    0.20028  <-          0.20028  TBI         13.03% <-         1
:all/bb123                 0.53497  0.13424     0.53497  TBI         34.81% 8.74%      1
:bb123                     0.53497  0.13424     0.53497  0.13424     34.81% 8.74%      1
  :very-long-name-yeah     0.40073  0.20040     0.40073  0.20040     26.08% 13.04%     1
    :also-long-name-yeah   0.20033  <-          0.20033  <-          13.04% <-         1
```
