class Stack {
  var objArr: array<int>;
  var topOfStack: int;
  
  // TODO: add valid() to the requires/ensures clauses of methods below, where appropriate
  function valid() : bool
    reads this;             // don't change this
  {
	  true // TODO: replace "true" with an object invariant here
  }

  constructor(capacity: int)
    modifies this;          // don't change this
    ensures fresh(objArr);  // don't change this
	// TODO: write requires, ensures clauses if necessary
  {
    objArr := new int[capacity];
    topOfStack := -1;
  }

  function method isEmpty(): bool 
    reads this;
	// TODO: write requires, ensures clauses if necessary
	// functions and function methods don't need ensures clauses; their body is their spec
  {
    topOfStack == -1
  }

  function method isFull(): bool 
    reads this;
	// TODO: write requires, ensures clauses if necessary
  {
    topOfStack == (objArr.Length-1)
  }

  method push(x: int)
    modifies this, objArr;  // don't change this
	// TODO: write requires, ensures clauses if necessary
    ensures objArr == old(objArr);	// we gave you this one for free
  {
    topOfStack := topOfStack + 1;
    objArr[topOfStack] := x;
  }
  
  method pop() returns (elem:int)
    modifies this;          // don't change this
	// TODO: write requires, ensures clauses if necessary
    ensures objArr == old(objArr);	// we gave you this one for free
  {
    elem := objArr[topOfStack];
    topOfStack := topOfStack - 1;
  }  
}

method testStack() {
  var s := new Stack(2);
  assert(s.isEmpty());  // easy to verify
  s.push(1);
  s.push(2);
  assert(s.isFull()); // moderately easy to verify
  var two := s.pop();
  assert(two == 2);   // harder to verify
  var one := s.pop();
  assert(s.isEmpty()); // moderately easy to verify
}
