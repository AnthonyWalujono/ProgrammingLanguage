-- A Virtual Machine (VM) for Arithmetic (template)

-----------------------
-- Data types of the VM
-----------------------

-- Natural numbers
data NN = O | S NN
  deriving (Eq,Show) -- for equality and printing

-- Integers
data II = II NN NN
  deriving (Eq,Show) -- for equality and printing

-- Positive integers (to avoid dividing by 0)
data PP = I | T PP
  deriving (Eq,Show)


-- Rational numbers
data QQ =  QQ II PP
  deriving (Eq, Show)

------------------------
-- Arithmetic on the  VM
------------------------

----------------
-- NN Arithmetic
----------------

-- add natural numbers
addN :: NN -> NN -> NN
addN O m = m
addN (S n) m = S (addN n m)

-- multiply natural numbers
multN :: NN -> NN -> NN
multN O m = O
multN (S n) m = addN (multN n m) m

subN :: NN -> NN -> NN
subN O n = O
subN n O = n
subN (S n) (S m) = subN n m

----------------
-- II Arithmetic
----------------

-- Addition: (a-b)+(c-d)=(a+c)-(b+d)
addI :: II -> II -> II
addI (II a b) (II c d) = II (addN a c) (addN b d)

-- Multiplication: (a-b)*(c-d)=(ac+bd)-(ad+bc)
multI :: II -> II -> II
multI (II a b) (II c d) = II (addN (multN a c) (multN b d)) (addN (multN a d) (multN b c))

-- Subtraction: (a-b)-(c-d)=(a+d)-(b+c)
subtrI :: II -> II -> II
subtrI (II a b) (II c d) = II (addN a d) (addN b c)

-- Negation: -(a-b)=(b-a)
negI :: II -> II
negI (II a b) = II (b) (a)

----------------
-- QQ Arithmetic
----------------

-- add positive numbers
addP :: PP -> PP -> PP
addP I m = (T m)
addP (T n) m = T (addP n m)

-- multiply positive numbers
--multP :: PP -> PP -> PP
multP :: PP -> PP -> PP
multP I n = n
multP (T n) m = addP m (multP n m)

-- convert numbers of type PP to numbers of type II
--ii_pp :: PP -> II
ii_pp I = II (S O) O
ii_pp (T n) = addI (II (S O) O) (ii_pp(n))

-- Addition: (a/b)+(c/d)=(ad+bc)/(bd)
addQ :: QQ -> QQ -> QQ
addQ (QQ a b) (QQ c d) = QQ (addI(multI(a)(ii_pp(d))) (multI(ii_pp(b))(c))) (multP(b)(d))

-- Multiplication: (a/b)*(c/d)=(ac)/(bd)
multQ :: QQ -> QQ -> QQ
multQ (QQ a b) (QQ c d) = QQ (multI(a) (c)) (multP(b) (d))
----------------
-- Normalisation
----------------

normalizeI :: II -> II
normalizeI (II a b) = II (nn_int(int_nn(a)-int_nn(b))) (O)

----------------------------------------------------
-- Converting between VM-numbers and Haskell-numbers
----------------------------------------------------

-- Precondition: Inputs are non-negative
nn_int :: Integer -> NN
nn_int 0 = O
nn_int n = if n < 0 then error "interger is not a natural num"
              else (addN (S O) (nn_int (n - 1)))

int_nn :: NN->Integer
int_nn O = 0
int_nn (S n) = 1 + (int_nn n)

ii_int :: Integer -> II
--ii_int 0 = (II(S O) (S O))
--or
ii_int 0 = II O O
ii_int n = II (nn_int(n)) O

int_ii :: II -> Integer
int_ii (II O O) = 0
--int_ii (Something like S n) = 1 + (int_ii something like n)
int_ii (II (S O) O) = 1 + (int_ii (II O O))

-- Precondition: Inputs are positive
pp_int :: Integer -> PP
pp_int 1 = I
pp_int n = T(pp_int(n - 1))

int_pp :: PP->Integer
int_pp I = 1
int_pp (T n) = 1 + int_pp n

--float_qq :: QQ -> Float

------------------------------
-- Normalisation by Evaluation
------------------------------

--nbv :: II -> II

----------
-- Testing
----------

main = do
  -- test addN
  print $ addN (S (S O)) (S O)
  -- test multN
  print $ multN (S (S O)) (S (S (S O)))
  -- test addP
  print $ addP (T I) (T I)
  -- test multP
  print $ multP (T (T I)) ( T ( T ( T I)))
  -- Results should be T (T (T I))
  -- test addI
  print $ addI (II (S (S O)) (S O)) (II (S (S (S O))) (S (S O)))
  -- test multI
  print $ multI (II (S (S O)) (S O)) (II (S (S (S O))) (S (S O)))
  -- test subtrI
  print $ subtrI (II (S (S O)) (S O)) (II (S (S (S O))) (S (S O)))
  -- test negI
  print $ negI (II (S (S (S O))) (S (S O)))
  --test addQ
  print $ addQ (QQ (II (S O) (O)) (T I)) (QQ (II (S (S O)) (O)) (T I))
  --test multQ
  print $ multQ (QQ (II (S O) (O)) (T I)) (QQ (II (S O) (O)) (T I))
  -- testing int_nn
  print $ int_nn (S(S(S O)))
  -- testing nn_int
  print $ nn_int (4)
  -- testing ii_int
  print $ ii_int (5)
  -- testing int_ii
  --print $ int_ii (II (S (S O)) (S O)) -- this one is having trouble printing
  --testing pp_int
  print $ pp_int (4)
  -- testing int_pp
  print $ int_pp (T(T I))
  -- testing