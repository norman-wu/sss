class Stack {
  var objArr: array<int>;
  var topOfStack: int;
  
  // TODO: add valid() to the requires/ensures clauses of methods below, where appropriate
  function valid() : bool
    reads this;             // don't change this
  {
    if (objArr == null)
      then false
    else if (objArr.Length < 1)
      then false
    else if (topOfStack < -1 || topOfStack >= objArr.Length)
      then false
    //else if ( !isEmpty() && !isFull() && !(0 <= topOfStack <= objArr.Length-2))
    //  then false
    else
      true
  }

  constructor(capacity: int)
    modifies this;          // don't change this
    ensures fresh(objArr);  // don't change this
  // TODO: write requires, ensures clauses if necessary
    requires capacity > 0;
    ensures valid();
    ensures objArr.Length == capacity;
    ensures isEmpty();
  {
    objArr := new int[capacity];
    topOfStack := -1;
  }

  function method isEmpty(): bool 
    reads this;
  // TODO: write requires, ensures clauses if necessary
    requires valid();
    ensures valid();
  // functions and function methods don't need ensures clauses; their body is their spec
  {
    topOfStack == -1
  }

  function method isFull(): bool 
    reads this;
  // TODO: write requires, ensures clauses if necessary
   requires valid();
   ensures valid();
  {
    topOfStack == (objArr.Length-1)
  }

  method push(x: int)
    modifies this, objArr;  // don't change this
  // TODO: write requires, ensures clauses if necessary
    requires valid();
    requires !isFull();
    ensures valid();
    ensures objArr == old(objArr);  // we gave you this one for free
    ensures topOfStack == old(topOfStack)+1;
    ensures objArr[topOfStack] == x;
  {
    topOfStack := topOfStack + 1;
    objArr[topOfStack] := x;
  }
  
  method pop() returns (elem:int)
    modifies this;          // don't change this
  // TODO: write requires, ensures clauses if necessary
    requires valid();
    requires !isEmpty();
    ensures valid();
    ensures objArr == old(objArr);  // we gave you this one for free
    ensures topOfStack == old(topOfStack)-1;
    ensures elem == old(objArr[old(topOfStack)]);
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
