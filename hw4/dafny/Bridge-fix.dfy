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
  //system initialization flag
  var initFlag: bool;
  
  //car counters at each side of the bridge
  var Wa: nat, Wb: nat;
  
  //previous car counters at each side of the bridge
  var WPa: nat, WPb: nat;
  
  //previous car arrival
  var previousCar: NextCar;
  
  //car wait timers at each end of the bridge
  var Ta: nat, Tb: nat; 
  
  //light colors at each end of the bridge
  var La: Color, Lb: Color;
  
  //previous light colors at each end of the bridge
  var LPa: Color, LPb: Color;

  function valid() : bool
  //verifies all requirements R-B1 thru B-B8
    reads this;
  {
       initFlag ==> validInitConditions() //R-B5
    && bothLightsNeverGreen()             //R-B1
    && queuesUpdatedCorrectly()           //R-B2, R-B3b, R-B4, R-B5b
    && lightsUpdatedCorrectly()           //R-B3a, R-B5a, R-B6, R-B7, R-B8
  } 
  
  function validInitConditions() : bool
  //verifies R-B5 (and then some)
    reads this;
  {
        initFlag
     && previousCar == N
     && Wa == WPa == Wb == WPb == 0
     && Ta == Tb == 0
     && La == LPa == Lb == LPb == RED
  }
  
  function bothLightsNeverGreen() : bool
  //verifies R-B1
    reads this;
  {
    !(La == GREEN && Lb == GREEN)
  }
  
  function queuesUpdatedCorrectly() : bool
  //verifies R-B2, R-B3b, R-B4, R-B5b
    reads this;
  {
       Wa == WPa
          + (if (previousCar==A || previousCar==T) then 1 else 0)
          - (if (La == GREEN)                      then 1 else 0)
    && Wb == WPb
          + (if (previousCar==B || previousCar==T) then 1 else 0)
          - (if (Lb == GREEN)                      then 1 else 0)
  }
  
  function lightsUpdatedCorrectly() : bool
  //verifies R-B3a, R-B5a, R-B6, R-B7, R-B8
    reads this;
  {
    //R-B7: A gets precedence
    if (LPa == RED && LPb == RED) then
       if (previousCar == A || previousCar == T) then (La == GREEN && Lb == RED)
       else if (previousCar == B)                then (La == RED   && Lb == GREEN)
       else   /*previousCar == N*/                    (La == RED   && Lb == RED)
    else if (LPa == GREEN && LPb == RED) then
       
  }
  
  constructor() 
    ensures validInitConditions();
    modifies this;
  {
    initFlag    := true;
    previousCar := N;
    Wa, Wb      := 0, 0;
    WPa, WPb    := 0, 0;
    Ta, Tb      := 0, 0;
    La, Lb      := RED, RED;
    LPa, LPb    := RED, RED;
  }		
  
  method update(e : NextCar)
    returns(lightA_status : Color, lightB_status : Color, cars_at_A : int, cars_at_B : int)
  {
	  //Update lights
    //Update queues
    //Update queue timers
  }
}

