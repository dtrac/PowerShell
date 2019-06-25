foreach ($i in 1..10) { 
  if ($i % 2) {
    "$i is odd"
    }
  }

# or...

 1..10 | foreach { 
  if ($_ % 2) {
    "$_ is odd"
    }
  }
