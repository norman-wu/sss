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
  
  //how long a queue has been waiting at the red light
  var waitTimer: nat;
  
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
    && timerUpdatedCorrectly()
  } 
  
  function validInitConditions() : bool
  //verifies R-B5 (and then some)
    reads this;
  {
        initFlag
     && previousCar == N
     && Wa == WPa == Wb == WPb == 0
     && waitTimer == 0
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
    //R-B7: "A" gets precedence when lights are red
    if (LPa == RED && LPb == RED) then
       if (previousCar == A || previousCar == T) then (La == GREEN && Lb == RED)
       else if (previousCar == B)                then (La == RED && Lb == GREEN)
       else if (previousCar == N)                then (La == RED && Lb == RED)
       else false
    //R-
    else if (LPa == GREEN && LPb == RED) then
       if (previousCar == A || previousCar == T || Wa > 0) && waitTimer  < 5                 then (La == GREEN && Lb == RED)
       else if (previousCar != A && previousCar != T && Wa == 0 && Wb > 0) || waitTimer >= 5 then (La == RED && Lb == GREEN)
       else if (previousCar == N && Wa == Wb == 0)                                           then (La == RED && Lb == RED)
       else false
    else if (LPa == RED && LPb == GREEN) then
       if (previousCar == B || previousCar == T || Wb > 0) && waitTimer  < 5                 then (La == RED && Lb == GREEN)
       else if (previousCar != B && previousCar != T && Wb == 0 && Wa > 0) || waitTimer >= 5 then (La == GREEN && Lb == RED)
       else if (previousCar == N && WPa == Wb == 0)                                          then (La == RED && Lb == RED)
       else false   
    else false  
  }
  
  function timerUpdatedCorrectly(): bool
    reads this;
  {
    if (Wa > 0 && La == RED) || (Wb > 0 && Lb == RED) then waitTimer >  0
    else                                                   waitTimer == 0
  }
  
  constructor() 
    ensures validInitConditions();
    modifies this;
  {
    initFlag    := true;
    previousCar := N;
    Wa, Wb      := 0, 0;
    WPa, WPb    := 0, 0;
    waitTimer   := 0;
    La, Lb      := RED, RED;
    LPa, LPb    := RED, RED;
  }		
  
  method update(e : NextCar)
    returns(lightA_status : Color, lightB_status : Color, cars_at_A : int, cars_at_B : int)
    modifies this;
    ensures initFlag == false;
    ensures valid();
  {
    //update state
    initFlag := false;
    previousCar := e;
    WPa := Wa;
    WPb := Wb;
    LPa := La;
    LPb := Lb;
    
    //cars arrive
    if      (e == A) { Wa := Wa + 1; }
    else if (e == B) { Wb := Wb + 1; }
    else if (e == T)
    {
      Wa := Wa + 1;
      Wb := Wb + 1;
    }
    
    //lights change
    //both lights start red
    if (La == RED && Lb == RED)
    {
      assert Wa <= 1 && Wb <= 1;
      assert waitTimer == 0;
      
      //side A takes precedence
      if (Wa == 1)
      {
        La := GREEN;
        Lb := RED;
      }
      else if (Wb == 1)
      {
        La := RED;
        Lb := GREEN;
      }
      
    }
    else if (La == GREEN && Lb == RED)
    {
      //if wait timer > 5, switch lights
      //if no cars at A, but cars at B, switch lights
      if (waitTimer >= 5 || (Wa == 0 && Wb > 0))
      {
        La := RED;
        Lb := GREEN;
      }
      //if there are no cars on either side, turn both to RED
      else if (Wa == Wb == 0)
      {
        La := RED;
        Lb := RED;
      }
    }
    else if (La == RED && Lb == GREEN)
    {
      //if wait timer > 5, switch lights
      //if no cars at B, but cars at A, switch lights
      if (waitTimer >= 5 || (Wa > 0 && Wb == 0))
      {
        La := GREEN;
        Lb := RED;
      }
      //if there are no cars on either side, turn both to RED
      else if (Wa == Wb == 0)
      {
        La := RED;
        Lb := RED;
      }
      
    }
    else { assert false; }
    
    //car travels across bridge
    if (La == GREEN) { Wa := Wa - 1; }
    else if (Lb == GREEN) { Wb := Wb - 1; }
    
    //Update queue timers
    if (La == Lb == RED)
    {
      waitTimer := 0;
    }
    else if (La != LPa && Lb != LPb)
    {
      waitTimer := 0;
    }
    else if (La == RED && Wa > 0)
    {
      waitTimer := waitTimer + 1;
    }
    else if (Lb == RED && Wb > 0)
    {
      waitTimer := waitTimer + 1;
    }
  }
}

