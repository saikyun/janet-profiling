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
(p :measure (ev/sleep 0.5))
(print-results)
#=>
# results
k            total		w/o inner	avg	w/o inner	of total %	w/o inner	nof calls
:all/measure 0.50062	<-		0.50062	<-		100.00%		<-		1
:measure     0.50062	<-		0.50062	<-		100.00%		<-		1
nil
```

## example

look at [example.janet](./example.janet)

```
git clone https://github.com/Saikyun/janet-profiling
cd janet-profiling
janet example.janet
# results
k                        total		w/o inner	avg	w/o inner	of total %	w/o inner	nof calls
:all/very-long-name-yeah 0.40070	0.20037		0.40070	<-		26.07%		13.04%		1
:slow-adder              0.20035	<-		0.20035	<-		13.04%		<-		1
:all/slow-adder          0.20035	<-		0.20035	<-		13.04%		<-		1
:all/aa                  0.20035	<-		0.20035	<-		13.04%		<-		1
:aa                      0.20035	<-		0.20035	<-		13.04%		<-		1
:all/also-long-name-yeah 0.20033	<-		0.20033	<-		13.04%		<-		1
:all/bb123               0.53500	0.13430		0.53500	<-		34.81%		8.74%		1
:bb123                   0.53500	0.13430		0.53500	0.13430		34.81%		8.74%		1
  :very-long-name-yeah   0.40070	0.20037		0.40070	0.20037		26.07%		13.04%		1
    :also-long-name-yeah 0.20033	<-		0.20033	<-		13.04%		<-		1
```
