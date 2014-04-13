
class Stack {
  var objArr: array<int>;
  var topOfStack: int;
  
  // TODO: add valid() to the requires/ensures clauses of methods below, where appropriate
  function valid() : bool
    reads this;             // don't change this
  {
    if (objArr == null)
      then false
    else if (topOfStack < -1 || topOfStack >= objArr.Length)
      then false
    else if (isFull() && topOfStack != (objArr.Length-1))
      then false
    else if (isEmpty() && topOfStack != -1)
      then false
    else
      true
  }

  constructor(capacity: int)
    requires capacity > 0;
    modifies this;          // don't change this
    ensures fresh(objArr);  // don't change this
    ensures valid();
    ensures objArr.Length == capacity;
	// TODO: write requires, ensures clauses if necessary
    ensures isEmpty();
  {
    objArr := new int[capacity];
    topOfStack := -1;
  }

  function method isEmpty(): bool 
    reads this;
   // TODO: write requires, ensures clauses if necessary
    requires objArr != null;
	// functions and function methods don't need ensures clauses; their body is their spec
  {
    topOfStack == -1
  }

  function method isFull(): bool 
    reads this;
	// TODO: write requires, ensures clauses if necessary
   requires objArr != null;
  {
    topOfStack == (objArr.Length-1)
  }

  method push(x: int)
    modifies this, objArr;  // don't change this
	// TODO: write requires, ensures clauses if necessary
    requires valid();
    requires topOfStack < objArr.Length-2;
    ensures valid();
    ensures objArr == old(objArr);	// we gave you this one for free
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
    ensures -1 <= topOfStack < objArr.Length;
    ensures objArr == old(objArr);	// we gave you this one for free
  {
    elem := objArr[topOfStack];
    topOfStack := topOfStack - 1;
  }  
}

