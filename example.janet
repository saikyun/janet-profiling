(use ./time)

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
(print-results)
