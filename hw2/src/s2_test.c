
// secure_coding.c
// unsecure function checker

#include "extend-lang.hpp"     // Extend API

START_EXTEND_CHECKER(secure_coding, simple );

ANALYZE_TREE()
{
    CallSite gets("gets");
    CallSite strcpy("strcpy");
    CallSite strcat("strcat");
    
    if(MATCH(gets))
        OUTPUT_ERROR("buffer overflow "<<"gets() makes no guarantee of safety. "<<"Use fgets() instead."<<" VERY RISKY" << CURRENT_TREE);
    
    if(MATCH(strcpy))
        OUTPUT_ERROR("buffer overflow "<<"strcpy() makes no guarantee of safety. "<<"Use strncpy() instead."<<" [VERY RISKY]" << CURRENT_TREE);
    
    if(MATCH(strcat))
        OUTPUT_ERROR("buffer overflow "<<"strcat() makes no guarantee of safety. "<<"Use strncat() instead."<<" [VERY RISKY]" << CURRENT_TREE);
}



END_EXTEND_CHECKER();

MAKE_MAIN( secure_coding )

// EOF