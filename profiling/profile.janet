(def global-timers @{})
(def global-results @{})
(def global-stack @[])

(defn create-or-push
  [arr v]
  (array/push (or arr @[]) v))

(defn add-value
  [m v]
  (update (or m @{})
          :times
          create-or-push v))

(defmacro p
  ```
  Time the execution of `form` using `os/clock` before and after,
  and store the result in `timers` (defaults to `(dyn :profile/timers global-timers)`).
  To see all stored results one can use `print-results`.
  ```
  [tag form &opt timers]
  (default timers (dyn :profile/timers global-timers))
  (with-syms [start result end]
    ~(do
       (array/push ',global-stack :inner)
       (array/push ',global-stack ,tag)
       (def ,start (os/clock))
       (def ,result (defer (do (array/pop ',global-stack)
                             (array/pop ',global-stack))
                      (def res ,form)
                      (def ,end (os/clock))
                      (update-in ',timers ',global-stack add-value (- ,end ,start))

                      res))
       ,result)))

(defmacro defnp
  ```
  Like `defn`, but wraps the body with a call to `(p ,name (do ,;body))`
  ```
  [name & more]
  (def len (length more))
  (def fstart
    (fn recur [i]
      (def {i ith} more)
      (def t (type ith))
      (if (= t :tuple)
        i
        (if (< i len) (recur (+ i 1))))))
  (def body-start (inc (fstart 0)))

  (def before-body (array/slice more 0 body-start))
  (def body (array/slice more body-start))

  ~(defn ,name
     ,;before-body
     (p ,(keyword name) (do ,;body))))


(defmacro varfnp
  ```
  Like `varfn`, but wraps the body with a call to `(p ,name (do ,;body))`
  ```
  [name & more]
  (def len (length more))
  (def fstart
    (fn recur [i]
      (def {i ith} more)
      (def t (type ith))
      (if (= t :tuple)
        i
        (if (< i len) (recur (+ i 1))))))
  (def body-start (inc (fstart 0)))

  (def before-body (array/slice more 0 body-start))
  (def body (array/slice more body-start))

  ~(varfn ,name
     ,;before-body
     (p ,(keyword name) (do ,;body))))

(defn calc-avg
  [res-path times total results]
  (def nof (length times))
  (def avg (/ total nof))

  (def old-nof (get-in results [;res-path :nof] 0))
  (def old-avg (get-in results [;res-path :avg] 0))

  (def total-nof (+ nof old-nof))

  (def new-ratio (/ nof total-nof))
  (def old-ratio (/ old-nof total-nof))

  (def new-avg (+ (* new-ratio avg)
                  (* old-ratio old-avg)))

  (put-in results [;res-path :avg] new-avg)
  (put-in results [;res-path :nof] total-nof))

(defn consume
  [path &opt timers results]
  (default timers global-timers)
  (default results global-results)

  (def path (if (keyword? path)
              [path]
              path))

  (def inner-path [:inner ;(interpose :inner path)])

  (loop [k :keys (get-in timers [;inner-path :inner] {})]
    (put-in results [;path :inner k] k)
    (consume [;path k] timers results))

  (def times (get-in timers [;inner-path :times]))

  (when times
    (if (empty? times)
      (get-in results [;path :avg])
      (do
        (def total (+ ;times))

        (update-in results [;path :total] |(+ (or $ 0) total))
        (update-in results [(keyword (string "all/" (last path))) :total] |(+ (or $ 0) total))
        (update results :results/grand-total |(+ (or $ 0) total))

        (calc-avg path times total results)
        (calc-avg [(keyword (string "all/" (last path)))] times total results)

        (update-in timers [;inner-path :times] array/clear)))))


(defn avg
  [path &opt timers results]
  (default timers global-timers)
  (default results global-results)
  (def path (if (keyword? path)
              [path]
              path))

  (consume path timers results)

  (get-in results [;path :avg]))

(defn total-time
  [&opt timers results]
  (default timers global-timers)
  (default results global-results)

  (loop [k :keys timers]
    (consume k timers results))

  (get results :results/grand-total 0))
#
#
#
##



(setdyn :pretty-format "%.40M")

(defn total-wo-inner
  [path &opt timers results]
  (default timers global-timers)
  (default results global-results)

  (def path (if (keyword? path)
              [path]
              path))

  (consume path timers results)

  (- (get-in results [;path :total])
     (+ ;(map |(get-in results [;path $ :total])
              (get-in results [;path :inner] [])))))

(defn avg-wo-inner
  [path &opt timers results]
  (default timers global-timers)
  (default results global-results)

  (def path (if (keyword? path)
              [path]
              path))

  (consume path timers results)

  (- (get-in results [;path :avg])
     (+ ;(map |(get-in results [;path $ :avg])
              (get-in results [;path :inner] [])))))

(defn total
  [path &opt timers results]
  (default timers global-timers)
  (default results global-results)

  (def path (if (keyword? path) [path] path))

  (consume path timers results)

  (get-in results [;path :total]))

(defn print-path
  [path indent results longest-key]
  (default indent 0)

  (print (string/format (string "%-" longest-key "s") (string (string/repeat " " indent)
                                                              ":" (last path)))
         (string/format "%.03f" (total path)) "\t"
         (if (get-in results [;path :inner])
           (string/format "%.03f" (total-wo-inner path))
           "<-")
         "\t\t" (string/format "%.03f" (avg path))
         "\t"
         (if (get-in results [;path :inner])
           (string/format "%.03f" (avg-wo-inner path))
           "<-")
         "\t\t"
         (string/format "%.02f%%" (* 100 (/ (total path) (total-time results))))

         "\t\t"

         (if (get-in results [;path :inner])
           (string/format "%.02f%%" (* 100 (/ (total-wo-inner path) (total-time results))))
           "<-"))

  (loop [#k :keys (get-in results [;path :inner] []
         [k _] :in (-> (sort-by (fn [[k v]]
                                  (get v :total 0))
                                (pairs (get-in results [;path :inner] [])))
                       reverse)]
    (print-path [;path k] (+ indent 2) results longest-key)))

(defn width-of-key
  [[k v]]
  (var d (inc (length (string k))))
  (loop [ik :in (get v :inner [])]
    (set d (max d (+ 2 (width-of-key [ik (get v ik)])))))
  d)

(defn print-results
  [&opt timers results]
  (default timers global-timers)
  (default results global-results)

  (loop [k :keys (get timers :inner [])]
    (consume k timers results))

  (def longest-key (inc (max 0
                             ;(map (fn [[k v]]
                                     (+ (width-of-key [k v])))
                                   (filter |(not= (first $) :results/grand-total) (pairs results))))))

  (print "# results")
  (print (string/format (string "%-" (+ longest-key 0) "s") "k")
         "total\tw/o inner\tavg\tw/o inner\tof total %\tw/o inner")

  (loop [[k v] :in (-> (sort-by (fn [[k v]]
                                  (get v :total 0))
                                (pairs results))
                       reverse)
         :when (not= k :results/grand-total)]
    (print-path [k] 0 results longest-key)))


(defn reset-profiling!
  []
  (def timers (dyn :profile/timers global-timers))

  (loop [k :keys timers]
    (put timers k nil))

  (loop [k :keys global-results]
    (put global-results k nil)))

##
#
#
#
#



(defn float-almost-equal
  [f1 f2]
  (< (math/abs (- f1 f2)) 0.0000001))

(let [timers @{}
      results @{}
      random-numbers (seq [i :range [0 1000]]
                       (* i (math/random)))]
  (put-in timers [:inner :aa :times] (array ;random-numbers))
  (def res1 (avg :aa timers results))

  (var checked 0)
  (while (< checked (length random-numbers))
    (def end (min (length random-numbers)
                  (+ checked (math/floor (* 10 (math/random))))))
    (put-in timers [:inner :aa2 :times] (array/slice random-numbers checked end))
    (avg :aa2 timers results)
    (set checked end))

  (def res2 (avg :aa2 timers results))

  # it shouldn't matter if avg is called once
  # or many times (barring rounding errors)
  (assert (float-almost-equal res1 res2)
          (string "avgs: " res1 " not equal to " res2))

  # grand total of all calculations should be same
  (def s1 (+ ;random-numbers ;random-numbers))
  (def s2 (total-time timers results))

  (assert (float-almost-equal s1 s2)
          (string "totals: " s1 " not equal to " s2)))

#
#
#
#
# examples

(comment
  (do

    (loop [_ :range [0 3]]
      (p :a (do (ev/sleep 0.03)
              (+ 1 (p :b
                      (do (ev/sleep 0.25)
                        (+ 2 3)))))))

    (p :b (do (ev/sleep 0.5)
            (+ 1 2 3)))

    (print "total :a")
    (pp (total :a))
    (print "total :a without inner")
    (pp (total-wo-inner :a))

    (defnp adder
      [x y]
      (ev/sleep 0.5)
      (+ x y))

    (adder 5 5)

    (print-results))

  #  
)
