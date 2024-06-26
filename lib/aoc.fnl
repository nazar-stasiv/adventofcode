(local lume (require :lib.lume))
(local fennel (require :fennel))

(fn string-from [path]
  "return lines read from file at path"
  (icollect [line (io.lines path)] line))

(fn string-last-index-of [s c]
  "returns index of c in s looking backwards or 0 if not found"
  (let [index (string.find (string.reverse s) c 1 true)]
    (if index (- (+ 1 (length s)) index)
        0)))

(fn string-pushback [s]
  "return string with 1st character from s pushed to last position"
  (.. 
   (string.sub s 2 (length s))
   (string.sub s 1 1)))

(fn string-tonumarray [str]
  "return collection of numbers from string str"
  (icollect [s (string.gmatch str (.. "[^ ,]+"))] (tonumber s)))

(fn string-toarray [s]
  "return collection of characters from string s abc->[a b c]"
  (let [result []]
    (for [i 1 (length s)]
      (table.insert result (string.sub s i i)))
    result))

(fn string-ends-with [s c]
  "returns bool indicating if c is in last position of s"
  (if (= c (. (string-toarray s) (length s)))
      true
      false))

(fn string-starts-with [s c]
  "returns bool indicating if c is prefix for s"
  ;;(assert (>= (length s) (length c)))
  (let [n (string.sub s 1 (length c))]
    (= n c)))

(fn string-split [str sep]
  "return strings from str separated at occurrences of sep"
  (icollect [s (string.gmatch str (.. "[^" sep "]+"))] s))

(fn array-to-number [xs]
  "return integer value represented as collection xs of its digits [1 2 3]->123"
  (var result 0)
  (each [_ x (ipairs xs)]
    (set result (+ (tonumber x) (* result 10))))
  result)

(fn math-sum [n]
  "return sum of range numbers from 1 to n"
  (var result 0)
  (for [i 1 n 1]
    (set result (+ result i)))
  result)

(fn math-pow [x i]
  "return exponent exp of value mant x i->xⁱ"
  (if (= i 0) 1
      (= i 1) x
      (* x (math-pow x (- i 1)))))

(fn math-gcd [a b]
  "return greatest common denominator of a and b: 12,9->3"
  (if (= 0 b) a
      (math-gcd b (% a b))))

(fn int [x]
  "return integer representation of x"
  (or (tonumber x)
      (math.tointeger x)))

(fn math-lcm [a b]
  "return least common multiplier of a and b"
  (int (/ (* a b) (math-gcd a b))))

(fn math-fact [n]
  "return factorial of n"
  (if (<= n 1) 1
      (* n (math-fact (- n 1)))))

(fn math-min [t]
  "return smallest element from collection t"
  (table.sort t)
  (. t 1))

(fn take [xs n]
  "return first n elements from collection xs"
  (let [result []]
    (for [i 1 n 1]
      (table.insert result (. xs i)))
    result))

(fn rest [xs]
  "return elements from collection xs starting at index two till end"
  (table.remove xs 1)
  xs)

(fn table-print [xs]
  "print to output elements of xs"
  (print (fennel.view xs)))

(fn table-sum [xs]
  "return sum of elements at xs collection"
  (accumulate [sum 0 _ x (ipairs xs)]
    (if (lume.isarray x)
        (+ sum (table-sum x))
        (+ sum x))))

(fn table-filter [xs x]
  "return array with elements of xs s.t. xsᵢ=x"
  (lume.filter xs #(= x (tonumber $))))

(fn table-count [xs x]
  "return number of x in xs"
  (length (table-filter xs x)))

(fn table-sort [xs]
  "return table sorted in ascending order"
  (table.sort xs)
  xs)

(fn table-join [xs ys]
  "return collection with all ys elements appended to all xs elements"
  (table.move ys 1 (length ys) (+ 1 (length xs)) xs))

(fn table-contains? [t e]
  "return bool indicating if collection t contains element e"
  (if (lume.find t e)
      true
      false))

(fn table-identical-2d? [a b]
  "return bool indicating if 2D collection a has identical elements to b"
  (var result true)
  (for [i 1 (length a) 1]
    (for [j 1 (length (. a i)) 1]
      (when (not= (. (. a i) j)
                  (. (. b i) j))
        (set result false))))
  result)

(fn table-identical? [t1 t2]
  "return bool indicating all t1 elements present in t2 collection"
  (and 
   (= (length t1)
      (length t2))
   (lume.all t1 #(table-contains? t2 $))))

(fn table-zip [t1 t2]
  "return collection of tuples: 1st t1 element, 1st t2 element, then 2nd t1 and 2nd t2, and so on"
  (assert (= (length t1) (length t2)))
  (let [result []]
    (for [i 1 (length t1) 1]
      (when (. t2 i)
        (table.insert result [(. t1 i) (. t2 i)])))
    result))

(fn table-reverse [xs]
  "return collection with xs elements reversed"
  (let [result []]
    (each [_ x (ipairs xs)]
      (table.insert result 1 x))
    result))

(fn table-zero? [t]
  "return bool indicating if all t elements are zeros"
  (and (< 0 (length t))
       (lume.all t #(= 0 $))))

(fn table-range [xs f t]
  "return collection of xs elements starting at index f ending at index t"
  (let [result []]
    (fcollect [i f t 1] (table.insert result (. xs i)))
    result))

(fn table-apply [t1 t2 f]
  "return collection of (f t1 t2) applications to elements of t1 and t2"
  (assert (= (length t1)
             (length t2)))
  (let [result []]
    (for [i 1 (length t1) 1]
      (table.insert result (f (. t1 i) (. t2 i))))
    result))

(fn table-clone [xs]
  "return shallow copy of xs elements"
  (let [res []]
    (each [_ x (pairs xs)]
      (table.insert res x))
    res))

(macro times [t body1 & rest-body]
  `(fcollect [i# 1 ,t 1]
     (do ,body1 ,(unpack rest-body))))

(fn table-group-by [xs n]
  "return n-ary collection of linear xs"
  (assert (= 0 (% (length xs) n)))
  (let [result []
        in (table-clone xs)]
    (while (not= 0 (length in))
      (table.insert result (take in n))
      (times n (rest in)))
    result))

(fn table-transpose [xs]
  "return rows of 2D collection xs as columns"
  (let [result []]
    (for [j 1 (length (. xs 1)) 1]
      (table.insert result j [])
      (for [i 1 (length xs) 1]
        (table.insert (. result j) i (. (. xs i) j))))
    result))

(fn table-replace [t i j v]
  "return collection with i,j element of t replaced with v"
  (let [old (table.remove (. t i) j)]
    (table.insert (. t i) j v)
    old))

(fn table-replace-row [xs i x]
  "return ith row of xs replaced in-place with x"
  (let [old (table.remove xs i)]
    (table.insert xs i x)
    old))

(lambda table-move [pos xs1 xs2 ?n]
  "moves element(s) at pos from xs1 into same pos at collection xs2"
  (if (not ?n)
      (table.insert xs2 pos (table.remove xs1 pos))
      (let [tmp []]
        (for [i 1 ?n]
          (table.insert tmp 1 (table.remove xs1 pos)))
        (for [i 1 ?n]
          (table.insert xs2 pos (table.remove tmp 1)))))
  nil)

(fn table-tostring [xs]
  "joins elements of xs with empty string"
  (if xs
      (table.concat xs "")
      ""))

(fn table-unique [t]
  "returns unique set of [x y] elements of t"
  (let [res []]
    (each [_ e (ipairs t)]
      (let [exists (lume.filter res
                                (fn [[x y]]
                                  (and (= x (. e 1))
                                       (= y (. e 2)))))]
        (when (or (= exists nil)
                  (= 0 (length exists)))
          (table.insert res e))))
    res))

(fn first [xs]
  "return element from collection xs at index of one"
  (. xs 1))

(fn last [xs]
  "return last element from collection xs"
  (. xs (length xs)))

(fn fold [t]
  "return sum of values of t"
  (lume.reduce t (fn [acc x] (+ acc x))))

(fn empty? [xs]
  "return bool indicating if xs contains any elements or is empty"
  (or (= nil xs)
      (= 0 (length xs))))

(fn table-contains-2d? [t e]
  "return bool indicating if collection t contains table e"
  (let [xs (lume.filter t #(table-identical? $ e))]
    (not (empty? xs))))

(fn range [s len]
  "return collection of consecutive numbers starting at s till length len"
  (fcollect [i s (+ s len) 1] i))

(fn range-to [s e]
  "return collection of consecutive numbers starting at s ending at e"
  (fcollect [i (math.min s e) (math.max s e) 1] i))

(fn range-of [x n]
  "return length n collection of x"
  (let [res []]
    (for [i 1 n]
      (table.insert res x))
    res))

(fn todecimal [t]
  "returns decimal number of bitarray: [1 1 1 1]->15"
  (let [res []
        len  (length t)]
    (each [i v (ipairs t)]
      (table.insert res (* v (math-pow 2 (- len i)))))
    (table-sum res)))

(fn dec [x]
  "return 1 decrement of x"
  (- x 1))

(fn inc [x]
  "return 1 increment of x"
  (+ x 1))

(fn read-matrix [xs ?n]
  "return 2d array or characters"
  (let [res []]
    (each [_ x (ipairs xs)]
      (let [el (string-toarray x)]
        (if ?n (table.insert res (lume.map el #(tonumber $)))
            (table.insert res el))))
    res))

(fn table-tonumber [xs]
  "returns elements of table converting to numbers"
  (lume.map xs #(tonumber $)))

(fn table-unpack [xs]
  "returns elements of table"
  (let [u (or table.unpack unpack)]
    (u xs)))

(fn table-min [xs]
  "return minimum entry of xs"
  (math.min (table-unpack (table-tonumber xs))))

(fn table-max [xs]
  "return maximum entry of xs"
  (let [xn (table-tonumber xs)]
    (if (< 8000 (length xn))
        (do (table.sort xn)
            (. xn (length xn)))
        (math.max (table-unpack xn)))))

(fn table-exclude [xs j]
  "returns all xs elements but at pos j"
  (lume.filter xs (fn [i v] (not= j i))))

(fn table-flatten [xs]
  "returns linear collection of xs rows"  
  (let [res []]
    (each [_ x (ipairs xs)]
      (each [_ y (ipairs x)]
        (table.insert res y)))
    res))

(fn table-sum-if [xs pred]
  "return sum of xs elements if xᵢ satisfies pred condition"
  (accumulate [sum 0 _ x (ipairs xs)]
    (if (lume.isarray x)
        (+ sum (table-sum-if x pred))
        (if (pred x)
            (+ sum x)
            (+ sum 0)))))

(fn runtime []
  "returns lua runtime version"
  (case _G._VERSION
    "Lua 5.1" 5.1
    "Lua 5.2" 5.2
    "Lua 5.3" 5.3
    "Lua 5.4" 5.4))

(fn int/ [x y]
  "returns integer division like // operator"
  (math.floor (/ x y)))

(fn dist2rd [[Hx Hy] {:x Tx :y Ty}]
  "x₁y₁ distance² to x₂y₂ on plane <=2 for any adjacent points"
  (lume.distance Hx Hy Tx Ty true))

{: string-from
 : string-last-index-of
 : string-pushback
 : string-tonumarray
 : string-toarray
 : string-ends-with
 : string-starts-with
 : string-split
 : array-to-number
 : math-sum
 : math-pow
 : math-gcd
 : math-lcm
 : math-fact
 : math-min
 : table-print
 : table-sum
 : table-filter
 : table-count
 : table-sort
 : table-join
 : table-identical-2d?
 : table-identical?
 : table-zip
 : table-reverse
 : table-contains?
 : table-zero?
 : table-range
 : table-apply
 : table-clone
 : table-group-by
 : table-transpose
 : table-replace
 : table-replace-row
 : table-move
 : table-tostring
 : table-unique
 : first
 : last
 : take
 : rest
 : fold
 : empty?
 : table-contains-2d?
 : range
 : range-to
 : range-of
 : todecimal
 : dec
 : inc
 : read-matrix
 : table-unpack
 : table-tonumber
 : table-min
 : table-max
 : table-exclude
 : table-flatten
 : table-sum-if
 : runtime
 : int/
 : dist2rd
 : int}
