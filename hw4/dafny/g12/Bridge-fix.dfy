//Input type: Car at A, car at B, car at both (Two), car at Neither
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
datatype State = RR | GR | GRW | RG | RGW;
 
class BridgeController {
  //system state
  var state: State;
  
  //car counters at each side of the bridge
  var Wa: nat, Wb: nat;
  
  //previous car arrival
  var car: NextCar;
  
  //how long a queue has been waiting at the red light
  var waitTimer: nat;
  
  //light colors at each end of the bridge
  var La: Color, Lb: Color;

  function valid() : bool
  //verifies all requirements R-B1 thru B-B8
    reads this;
  {
       (validStateImplications())
    && (bothLightsNeverGreen())
  } 
  
  function validStateImplications() : bool
    reads this;
  {
       (state == RR || state == GR || state == GRW || state == RG || state == RGW)
    && (state == RR   ==> validRRConditions())
    && (state == GR   ==> validGRConditions())
    && (state == GRW  ==> validGRWConditions())
    && (state == RG   ==> validRGConditions())
    && (state == RGW  ==> validRGWConditions())
  }
  
  function validRRConditions() : bool
    reads this;
  {
       (car == N)
    && (La == Lb == RED)
    && (Wa == Wb == 0)
    && (waitTimer == 0)
  }
  
  function validGRConditions() : bool
    reads this;
  {
       (car == A || car == N)
    && (La == GREEN && Lb == RED)
    && (Wb == 0)
    && (waitTimer == 0)
  }
  
  function validGRWConditions() : bool
    reads this;
  {
       (La == GREEN && Lb == RED)
    && (0 < Wb)
    && (0 < waitTimer <= 5)
  }
  
  function validRGConditions() : bool
    reads this;
  {
       (car == B || car == N)
    && (La == RED && Lb == GREEN)
    && (Wa == 0)
    && (waitTimer == 0)
  }
  
  function validRGWConditions() : bool
    reads this;
  {
       (La == RED && Lb == GREEN)
    && (0 < Wa)
    && (0 < waitTimer <= 5)
  }
  
  function bothLightsNeverGreen() : bool
    reads this;
  {
    !(La == GREEN && Lb == GREEN)
  }
  
  constructor() 
    ensures state == RR;
    ensures valid();
    modifies this;
  {
    state       := RR;
    car         := N;
    Wa, Wb      := 0, 0;
    waitTimer   := 0;
    La, Lb      := RED, RED;
  }		
  
  method update(e : NextCar)
    returns(lightA_status : Color, lightB_status : Color, cars_at_A : int, cars_at_B : int)
    modifies this;
    requires valid();
    ensures valid();
    ensures car == e;
    ensures Wa == cars_at_A;
    ensures Wb == cars_at_B;
    ensures lightA_status == La;
    ensures lightB_status == Lb;
    ensures Wa == old(Wa)
                  + (if (car==A || car==T) then 1 else 0)
                  - (if (La == GREEN && (old(Wa) > 0 || car == A || car == T)) then 1 else 0);
    ensures Wb == old(Wb)
                  + (if (car==B || car==T) then 1 else 0)
                  - (if (Lb == GREEN && (old(Wb) > 0 || car == B || car == T)) then 1 else 0);
    ensures old(state) == GRW ==> (state != RR && state != GR);
    ensures old(state) == RGW ==> (state != RR && state != RG);
  {
    //store variable locally
    car := e;
    
    //car arrive
    Wa := Wa + (if (car==A || car==T) then 1 else 0);
    Wb := Wb + (if (car==B || car==T) then 1 else 0);
    
    var nextState: State;
    if ( state == RR   )
    {
      if      (Wa >  0 && Wb == 0) { nextState := GR; }
      else if (Wa == 0 && Wb >  0) { nextState := RG; }
      else if (Wa >  0 && Wb >  0) { nextState := GRW; }
      else if (Wa == 0 && Wb == 0) { nextState := RR; }
      else { assert(false); }
    }
    else if ( state == GR   )
    {
      if      (Wa >  0 && Wb == 0) { nextState := GR; }
      else if (Wa == 0 && Wb >  0) { nextState := RG; }
      else if (Wa >  0 && Wb >  0) { nextState := GRW; }
      else if (Wa == 0 && Wb == 0) { nextState := GR; }
      else { assert(false); }
    }
    else if ( state == GRW  )
    {
      if      (Wa >  0 && Wb == 0 && waitTimer == 5) { assert(false); }
      else if (Wa >  0 && Wb == 0 && waitTimer <  5) { assert(false); }
      else if (Wa == 0 && Wb >  0 && waitTimer == 5) { nextState := RG; }
      else if (Wa == 0 && Wb >  0 && waitTimer <  5) { nextState := RG; }
      else if (Wa >  0 && Wb >  0 && waitTimer == 5) { nextState := RGW; }
      else if (Wa >  0 && Wb >  0 && waitTimer <  5) { nextState := GRW; }
      else if (Wa == 0 && Wb == 0 && waitTimer == 5) { assert(false); }
      else if (Wa == 0 && Wb == 0 && waitTimer <  5) { assert(false); }
      else { assert(false); }
    }
    else if ( state == RG   )
    {
      if      (Wa >  0 && Wb == 0) { nextState := GR; }
      else if (Wa == 0 && Wb >  0) { nextState := RG; }
      else if (Wa >  0 && Wb >  0) { nextState := RGW; }
      else if (Wa == 0 && Wb == 0) { nextState := RG; }
      else { assert(false); }
    }
    else if ( state == RGW  )
    {
      if      (Wa >  0 && Wb == 0 && waitTimer == 5) { nextState := GR; }
      else if (Wa >  0 && Wb == 0 && waitTimer <  5) { nextState := GR; }
      else if (Wa == 0 && Wb >  0 && waitTimer == 5) { assert(false); }
      else if (Wa == 0 && Wb >  0 && waitTimer <  5) { assert(false); }
      else if (Wa >  0 && Wb >  0 && waitTimer == 5) { nextState := GRW; }
      else if (Wa >  0 && Wb >  0 && waitTimer <  5) { nextState := RGW; }
      else if (Wa == 0 && Wb == 0 && waitTimer == 5) { assert(false); }
      else if (Wa == 0 && Wb == 0 && waitTimer <  5) { assert(false); }
      else { assert(false); }      
    }
    else { assert(false); }
    
    //lights change based on state
    if      (nextState == RR)                     { La, Lb := RED, RED; }
    else if (nextState == GR || nextState == GRW) { La, Lb := GREEN, RED; }
    else if (nextState == RG || nextState == RGW) { La, Lb := RED, GREEN; }
    else { assert(false); }
    
    //car travels across bridge based on lights
    Wa := Wa - if (La == GREEN && Wa > 0) then 1 else 0;
    Wb := Wb - if (Lb == GREEN && Wb > 0) then 1 else 0;
    
    //Update wait timers
    if (state != nextState) { waitTimer := 0; }
    if (nextState == GRW || nextState == RGW) { waitTimer := waitTimer + 1; }
    else                                      { waitTimer := 0; }     
    
    //set outputs
    state         := nextState;
    lightA_status := La;
    lightB_status := Lb;
    cars_at_A     := Wa;
    cars_at_B     := Wb;
  }
}

