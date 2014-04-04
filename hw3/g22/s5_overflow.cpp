

// s5_overflow.cpp
// strncat off-by-one error overflow Extend checker

#include "extend-lang.hpp"     // Extend API

START_EXTEND_CHECKER( s5_overflow, int_store );

ANALYZE_TREE()
{
    CallSite strncat("strncat");
	Array a;
	Expr b;
	Const_int x;
    
    if(MATCH(strncat(a,b,x)))
    {
        //get the first arguement des string size and third arguemnt length of second stringget_size_of_type(a)
        
        if(get_size_of_type((array_type_t const *) get_type_of_tree(a))
           <= x.llval())
        {
            OUTPUT_ERROR("the size of source string is potentionally larger than destination string, will lead buffer overflow"<<" [VERY RISKY]" << CURRENT_TREE);
        }
    }
    
}

END_EXTEND_CHECKER();

MAKE_MAIN( s5_overflow )

// EOF