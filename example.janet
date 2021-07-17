(use ./profiling/profile)

(setdyn :pretty-format "%.40M")
(comment
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
  (pp (total-wo-inner :a)))


(varfnp aa []
  (ev/sleep 0.1337)
  1)


(varfnp aa []
  (ev/sleep 0.2)
  1)

(defnp bb123 []
  (ev/sleep 0.1337)
  1)


(bb123)
(aa)
(defnp slow-adder
  [x y]
  (ev/sleep 0.2000)
  (+ x y))

(slow-adder 3 4)
(print-results)

(reset-profiling!)

global-results
