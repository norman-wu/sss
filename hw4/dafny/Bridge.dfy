//Input type: Car at A, car at B, cars at both (Two), cars at Neither
datatype NextCar = A | B | T | N;

//Traffic light 
datatype Color = RED | GREEN;

//Main test driver
method Main()
{
  var events : seq<NextCar> := [A,T,N,A,A,B,N,B,T,T,T,A,A,B,B,B,T];
  var bc := new BridgeController();
  
  //execute the event sequence
  var length := |events|;
  var c := length;
  while(c > 0)
    decreases c;
    invariant 0 <= c <= |events|;
    invariant bc.valid();
  {
    var action := events[length-c];
    var lA, lB, wA, wB := bc.update(action);
    print action, ": ", lA, ", ", lB, ", ", wA, ", ", wB, "\n";
    c := c - 1;
  }   
}

/** YOU SHOULD NOT NEED ANY CHANGES ABOVE THIS POINT.
 *   (You can change the event sequence for testing, but the autograder will blow any changes away.)
 *  FILL IN THE BRIDGE CONTROLLER CLASS TO MEET THE SPEC. **/
class BridgeController {
  function valid() : bool
    reads this;
  {
    true		
  } 
  
  constructor() {}		
  
  method update(e : NextCar)
    returns(lightA_status : Color, lightB_status : Color, cars_at_A : int, cars_at_B : int)
  {
	
  }
}
