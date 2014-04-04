#include "extend-lang.hpp"     // Extend API

// s4_doublefree.cpp
// doulbe freee Extend checker

START_EXTEND_CHECKER( s4_doublefree, int_store );

enum State{
    m,
    f
};

ANALYZE_TREE()
{
    CallSite malloc("malloc");
    CallSite free("free");
    Pointer p1, p2;
    int v;
	
    if(MATCH(malloc(p1))) {
        SET_STATE(p1, m);
    }
    
    if(MATCH(p2=p1)) {
        COPY_STATE(p2, p1);
    }
    
    if(MATCH(free(p1))){
        GET_STATE(p1, v);
        if(v == m)
            SET_STATE(p1, f);
        else
            OUTPUT_ERROR("DOUBLE FREE!!"<<" [VERY RISKY]" << CURRENT_TREE);
    }
    
}


END_EXTEND_CHECKER();

MAKE_MAIN( s4_doublefree )
