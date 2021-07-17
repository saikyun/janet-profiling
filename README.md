# janet-profiling

## dependencies
janet

## usage
```
git clone https://github.com/Saikyun/janet-profiling
cd janet-profiling
janet example.janet

<...>

# results
k		total	w/o inner	avg	w/o inner	of total %	w/o inner
:a        	0.842	0.091		0.281	0.030		40.20%		4.33%
  :b      	0.751	-||-		0.250	-||-		35.88%		-||-
:b        	1.252	-||-		0.313	-||-		59.80%		-||-
```
