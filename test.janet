(use ./profiling/profile)
(p :measure (ev/sleep 0.1))
(p :inner (ev/sleep 0.5))
(p :measure
   (do (ev/sleep 0.1) 
       (p :inner (ev/sleep 0.5))))
(print-results)