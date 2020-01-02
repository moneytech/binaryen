(module
  (memory 10 10)
  (func $basic (param $p i32)
    (local $x i32)
    (local.set $x (i32.const 10))
    (call $basic (i32.add (local.get $x) (local.get $x)))
  )
  (func $split (param $p i32)
    (local $x i32)
    (if (i32.const 1)
      (local.set $x (i32.const 10))
    )
    (call $basic (i32.add (local.get $x) (local.get $x)))
  )
  (func $split-but-join (param $p i32)
    (local $x i32)
    (if (i32.const 1)
      (local.set $x (i32.const 10))
      (local.set $x (i32.const 10))
    )
    (call $basic (i32.add (local.get $x) (local.get $x)))
  )
  (func $split-but-join-different (param $p i32)
    (local $x i32)
    (if (i32.const 1)
      (local.set $x (i32.const 10))
      (local.set $x (i32.const 20))
    )
    (call $basic (i32.add (local.get $x) (local.get $x)))
  )
  (func $split-but-join-different-b (param $p i32)
    (local $x i32)
    (if (i32.const 1)
      (local.set $x (i32.const 10))
      (local.set $x (local.get $p))
    )
    (call $basic (i32.add (local.get $x) (local.get $x)))
  )
  (func $split-but-join-init0 (param $p i32)
    (local $x i32)
    (if (i32.const 1)
      (local.set $x (i32.const 0))
    )
    (call $basic (i32.add (local.get $x) (local.get $x)))
  )
  (func $later (param $p i32)
    (local $x i32)
    (local.set $x (i32.const 10))
    (call $basic (i32.add (local.get $x) (local.get $x)))
    (local.set $x (i32.const 22))
    (call $basic (i32.add (local.get $x) (local.get $x)))
    (local.set $x (i32.const 39))
  )
  (func $later2 (param $p i32) (result i32)
    (local $x i32)
    (local.set $x (i32.const 10))
    (local.set $x (i32.add (local.get $x) (local.get $x)))
    (local.get $x)
  )
  (func $two-ways-but-identical (param $p i32) (result i32)
    (local $x i32)
    (local $y i32)
    (local.set $x (i32.const 10))
    (if (i32.const 1)
      (local.set $y (i32.const 11))
      (local.set $y (i32.add (local.get $x) (i32.const 1)))
    )
    (local.set $y (i32.add (local.get $x) (local.get $y)))
    (local.get $y)
  )
  (func $two-ways-but-almost-identical (param $p i32) (result i32)
    (local $x i32)
    (local $y i32)
    (local.set $x (i32.const 10))
    (if (i32.const 1)
      (local.set $y (i32.const 12)) ;; 12, not 11...
      (local.set $y (i32.add (local.get $x) (i32.const 1)))
    )
    (local.set $y (i32.add (local.get $x) (local.get $y)))
    (local.get $y)
  )
  (func $deadloop (param $p i32) (result i32)
    (local $x i32)
    (local $y i32)
    (loop $loop ;; we look like we depend on the other, but we don't actually
      (local.set $x (if (result i32) (i32.const 1) (i32.const 0) (local.get $y)))
      (local.set $y (if (result i32) (i32.const 1) (i32.const 0) (local.get $x)))
      (br $loop)
    )
  )
  (func $deadloop2 (param $p i32)
    (local $x i32)
    (local $y i32)
    (loop $loop ;; we look like we depend on the other, but we don't actually
      (local.set $x (if (result i32) (i32.const 1) (i32.const 0) (local.get $y)))
      (local.set $y (if (result i32) (i32.const 1) (i32.const 0) (local.get $x)))
      (call $deadloop2 (local.get $x))
      (call $deadloop2 (local.get $y))
      (br $loop)
    )
  )
  (func $deadloop3 (param $p i32)
    (local $x i32)
    (local $y i32)
    (loop $loop ;; we look like we depend on the other, but we don't actually
      (local.set $x (if (result i32) (i32.const 1) (i32.const 0) (local.get $x)))
      (local.set $y (if (result i32) (i32.const 1) (i32.const 0) (local.get $y)))
      (call $deadloop2 (local.get $x))
      (call $deadloop2 (local.get $y))
      (br $loop)
    )
  )
  (func $through-tee (param $x i32) (param $y i32) (result i32)
    (local.set $x
      (local.tee $y
        (i32.const 7)
      )
    )
    (return
      (i32.add
        (local.get $x)
        (local.get $y)
      )
    )
  )
  (func $through-tee-more (param $x i32) (param $y i32) (result i32)
    (local.set $x
      (i32.eqz
        (local.tee $y
          (i32.const 7)
        )
      )
    )
    (return
      (i32.add
        (local.get $x)
        (local.get $y)
      )
    )
  )
  (func $multipass (param $0 i32) (param $1 i32) (param $2 i32) (result i32)
   (local $3 i32)
   (if
    (local.get $3)
    (local.set $3 ;; this set is completely removed, allowing later opts
     (i32.const 24)
    )
   )
   (if
    (local.get $3)
    (local.set $2
     (i32.const 0)
    )
   )
   (local.get $2)
  )
  (func $through-fallthrough (param $x i32) (param $y i32) (result i32)
    (local.set $x
      (block (result i32)
        (nop)
        (local.tee $y
          (i32.const 7)
        )
      )
    )
    (return
      (i32.add
        (local.get $x)
        (local.get $y)
      )
    )
  )
  (func $simd-load (result v128)
   (local $x v128)
   (local.set $x (v8x16.load_splat (i32.const 0)))
   (local.get $x)
  )
)
